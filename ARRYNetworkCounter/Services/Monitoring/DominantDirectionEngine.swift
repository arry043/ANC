import Foundation

/// Decision outcome produced by evaluating a speed measurement against direction switching hysteresis rules.
public struct DirectionDecision: Sendable, Equatable, Hashable {
    /// The resulting active traffic direction.
    public let direction: NetworkDirection

    /// Indicates whether this evaluation caused an actual transition in dominant direction.
    public let didSwitch: Bool

    /// The pending candidate direction undergoing confirmation, if any.
    public let candidateDirection: NetworkDirection?

    /// Number of consecutive qualifying samples observed for the pending candidate.
    public let confirmationCount: Int

    /// Creates a new `DirectionDecision`.
    public init(
        direction: NetworkDirection,
        didSwitch: Bool,
        candidateDirection: NetworkDirection? = nil,
        confirmationCount: Int = 0
    ) {
        self.direction = direction
        self.didSwitch = didSwitch
        self.candidateDirection = candidateDirection
        self.confirmationCount = confirmationCount
    }
}

/// Configuration parameters governing direction switching hysteresis, noise thresholds, and sample confirmation.
public struct DirectionSwitchingConfiguration: Sendable, Equatable, Hashable {
    /// Relative percentage margin required for the opposite direction to exceed current speed (e.g. 0.10 for 10%).
    public let relativeMargin: Double

    /// Minimum absolute difference in bytes per second required to exceed current speed (noise floor).
    public let absoluteThresholdBytesPerSecond: Double

    /// Number of consecutive qualifying samples required to commit a direction switch.
    public let requiredConsecutiveSamples: Int

    /// Default direction adopted upon startup, reset, or idle state.
    public let defaultDirection: NetworkDirection

    /// Creates a new `DirectionSwitchingConfiguration`.
    ///
    /// - Parameters:
    ///   - relativeMargin: Percentage margin (default: 0.10, i.e. 10%).
    ///   - absoluteThresholdBytesPerSecond: Absolute B/s threshold (default: 10,000.0 B/s).
    ///   - requiredConsecutiveSamples: Required consecutive sample count (default: 2).
    ///   - defaultDirection: Direction when idle or reset (default: .download).
    public init(
        relativeMargin: Double = 0.10,
        absoluteThresholdBytesPerSecond: Double = 10_000.0,
        requiredConsecutiveSamples: Int = 2,
        defaultDirection: NetworkDirection = .download
    ) {
        self.relativeMargin = relativeMargin
        self.absoluteThresholdBytesPerSecond = absoluteThresholdBytesPerSecond
        self.requiredConsecutiveSamples = requiredConsecutiveSamples
        self.defaultDirection = defaultDirection
    }

    /// Standard production configuration conforming to ADR-007 and ADR-035.
    public static let `default` = DirectionSwitchingConfiguration()
}

/// Deterministic decision engine determining whether download or upload is the dominant network traffic direction.
///
/// Implements hysteresis to prevent rapid visual flapping in single-direction and automatic display modes.
/// An opposite direction must exceed the current direction by both a relative margin (10%) and an absolute noise
/// floor (10 KB/s) for consecutive samples (2) before triggering a switch.
public actor DominantDirectionEngine {
    /// Active configuration parameters.
    public private(set) var configuration: DirectionSwitchingConfiguration

    /// Currently active dominant network direction.
    public private(set) var currentDirection: NetworkDirection

    /// Pending candidate direction awaiting consecutive sample confirmation, if any.
    public private(set) var pendingCandidate: NetworkDirection?

    /// Number of consecutive qualifying samples accumulated for `pendingCandidate`.
    public private(set) var consecutiveCandidateCount: Int

    /// Creates a new `DominantDirectionEngine`.
    ///
    /// - Parameter configuration: Switching parameters (defaults to `.default`).
    public init(configuration: DirectionSwitchingConfiguration = .default) {
        self.configuration = configuration
        self.currentDirection = configuration.defaultDirection
        self.pendingCandidate = nil
        self.consecutiveCandidateCount = 0
    }

    /// Evaluates a speed measurement and determines the dominant direction according to hysteresis rules.
    ///
    /// - Parameter measurement: Current speed measurement.
    /// - Returns: A `DirectionDecision` detailing the active direction and whether a switch occurred.
    public func evaluate(_ measurement: SpeedMeasurement) -> DirectionDecision {
        let dl = measurement.downloadBytesPerSecond
        let ul = measurement.uploadBytesPerSecond

        // 1. Idle condition: both directions have zero or non-positive traffic
        if dl <= 0 && ul <= 0 {
            let previous = currentDirection
            currentDirection = configuration.defaultDirection
            pendingCandidate = nil
            consecutiveCandidateCount = 0
            let didSwitch = (currentDirection != previous)
            return DirectionDecision(
                direction: currentDirection,
                didSwitch: didSwitch,
                candidateDirection: nil,
                confirmationCount: 0
            )
        }

        // Current speed vs opposite direction speed
        let currentSpeed = (currentDirection == .download) ? dl : ul
        let oppositeSpeed = (currentDirection == .download) ? ul : dl
        let oppositeDirection = currentDirection.opposite

        // 2. Candidate qualification check
        // We apply a micro-epsilon (1e-7) to account for standard IEEE 754 binary floating-point representation limits.
        let epsilon = 1e-7
        let exceedsCurrent = oppositeSpeed > currentSpeed
        let requiredRelativeSpeed = currentSpeed * (1.0 + configuration.relativeMargin)
        let relativePasses = oppositeSpeed >= (requiredRelativeSpeed - epsilon)
        let absolutePasses = (oppositeSpeed - currentSpeed) >= (configuration.absoluteThresholdBytesPerSecond - epsilon)

        if exceedsCurrent && relativePasses && absolutePasses {
            // Opposite qualifies as candidate
            if pendingCandidate == oppositeDirection {
                consecutiveCandidateCount += 1
            } else {
                pendingCandidate = oppositeDirection
                consecutiveCandidateCount = 1
            }

            if consecutiveCandidateCount >= configuration.requiredConsecutiveSamples {
                // Consecutive confirmation reached: switch direction!
                currentDirection = oppositeDirection
                pendingCandidate = nil
                consecutiveCandidateCount = 0
                return DirectionDecision(
                    direction: currentDirection,
                    didSwitch: true,
                    candidateDirection: nil,
                    confirmationCount: 0
                )
            } else {
                // Pending confirmation
                return DirectionDecision(
                    direction: currentDirection,
                    didSwitch: false,
                    candidateDirection: pendingCandidate,
                    confirmationCount: consecutiveCandidateCount
                )
            }
        } else {
            // Opposite does not qualify: reset pending candidate to maintain stability
            pendingCandidate = nil
            consecutiveCandidateCount = 0
            return DirectionDecision(
                direction: currentDirection,
                didSwitch: false,
                candidateDirection: nil,
                confirmationCount: 0
            )
        }
    }

    /// Resets the engine state to its default direction and clears any pending candidates.
    public func reset() {
        currentDirection = configuration.defaultDirection
        pendingCandidate = nil
        consecutiveCandidateCount = 0
    }

    /// Updates configuration and resets state to default.
    public func updateConfiguration(_ newConfiguration: DirectionSwitchingConfiguration) {
        self.configuration = newConfiguration
        self.currentDirection = newConfiguration.defaultDirection
        self.pendingCandidate = nil
        self.consecutiveCandidateCount = 0
    }
}
