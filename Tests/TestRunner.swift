import Foundation

/// Executable test harness executing all Phase 02 unit test suites.
@main
struct TestRunner {
    static func main() async {
        print("==================================================")
        print(" ARRY Network Counter — Phase 02 Test Execution   ")
        print("==================================================")

        var totalPassed = 0
        var totalFailed = 0
        let startTime = DispatchTime.now()

        // 1. NetworkSpeedTests
        do {
            let passed = try NetworkSpeedTests.run()
            print("  [PASS] NetworkSpeedTests:          \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkSpeedTests:          Failed with error: \(error)")
            totalFailed += 1
        }

        // 2. NetworkSnapshotTests
        do {
            let passed = try NetworkSnapshotTests.run()
            print("  [PASS] NetworkSnapshotTests:       \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkSnapshotTests:       Failed with error: \(error)")
            totalFailed += 1
        }

        // 3. NetworkInterfaceTests
        do {
            let passed = try NetworkInterfaceTests.run()
            print("  [PASS] NetworkInterfaceTests:      \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkInterfaceTests:      Failed with error: \(error)")
            totalFailed += 1
        }

        // 4. DisplayConfigurationTests
        do {
            let passed = try DisplayConfigurationTests.run()
            print("  [PASS] DisplayConfigurationTests:   \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] DisplayConfigurationTests:   Failed with error: \(error)")
            totalFailed += 1
        }

        // 5. AppPreferencesTests
        do {
            let passed = try AppPreferencesTests.run()
            print("  [PASS] AppPreferencesTests:        \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] AppPreferencesTests:        Failed with error: \(error)")
            totalFailed += 1
        }

        // 6. ApplicationCoordinatorTests
        do {
            let passed = try await ApplicationCoordinatorTests.run()
            print("  [PASS] ApplicationCoordinatorTests: \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] ApplicationCoordinatorTests: Failed with error: \(error)")
            totalFailed += 1
        }

        let endTime = DispatchTime.now()
        let elapsedMilliseconds = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0

        print("--------------------------------------------------")
        print("Test Execution Summary:")
        print("  Total Passed: \(totalPassed) assertions across 6 test suites")
        print("  Total Failed: \(totalFailed)")
        print(String(format: "  Execution Duration: %.2f ms", elapsedMilliseconds))
        print("==================================================")

        if totalFailed > 0 {
            exit(1)
        } else {
            print("ALL PHASE 02 UNIT TESTS PASSED SUCCESSFULLY.")
            exit(0)
        }
    }
}
