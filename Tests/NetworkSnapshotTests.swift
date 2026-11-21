import Foundation

/// Unit test suite for `NetworkSnapshot`.
public enum NetworkSnapshotTests {
    public static func run() throws -> Int {
        var count = 0

        // Test 1: Snapshot initialization with values
        let iface = NetworkInterface(name: "en0", index: 1, type: .wifi)
        let now = Date()
        let snapshot = NetworkSnapshot(
            receivedBytes: 15_000_000,
            transmittedBytes: 5_000_000,
            timestamp: now,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: iface
        )

        assert(snapshot.receivedBytes == 15_000_000, "Received bytes must match")
        assert(snapshot.transmittedBytes == 5_000_000, "Transmitted bytes must match")
        assert(snapshot.timestamp == now, "Timestamp must match")
        assert(snapshot.monotonicTimeNanoseconds == 1_000_000_000, "Monotonic time must match")
        assert(snapshot.interface == iface, "Interface must match")
        count += 1

        // Test 2: Baseline zero snapshot
        let zeroSnapshot = NetworkSnapshot.zero
        assert(zeroSnapshot.receivedBytes == 0, "Baseline received bytes must be 0")
        assert(zeroSnapshot.transmittedBytes == 0, "Baseline transmitted bytes must be 0")
        assert(zeroSnapshot.interface == nil, "Baseline interface must be nil")
        count += 1

        // Test 3: Snapshot equality and hashing
        let snapshotA = NetworkSnapshot(
            receivedBytes: 1000,
            transmittedBytes: 500,
            timestamp: now,
            monotonicTimeNanoseconds: 500,
            interface: iface
        )
        let snapshotB = NetworkSnapshot(
            receivedBytes: 1000,
            transmittedBytes: 500,
            timestamp: now,
            monotonicTimeNanoseconds: 500,
            interface: iface
        )
        let snapshotC = NetworkSnapshot(
            receivedBytes: 2000,
            transmittedBytes: 500,
            timestamp: now,
            monotonicTimeNanoseconds: 500,
            interface: iface
        )

        assert(snapshotA == snapshotB, "Identical snapshots must be equal")
        assert(snapshotA != snapshotC, "Snapshots with different bytes must not be equal")
        assert(snapshotA.hashValue == snapshotB.hashValue, "Equal snapshots must have identical hash values")
        count += 1

        return count
    }
}
