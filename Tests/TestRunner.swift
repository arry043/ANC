import Foundation

/// Executable test harness executing all Phase 02 and Phase 03 unit test suites.
@main
struct TestRunner {
    static func main() async {
        print("==================================================")
        print(" ARRY Network Counter — Unit Test Execution       ")
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

        // 6. NetworkPathStateTests (Phase 03)
        do {
            let passed = try NetworkPathStateTests.run()
            print("  [PASS] NetworkPathStateTests:      \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkPathStateTests:      Failed with error: \(error)")
            totalFailed += 1
        }

        // 7. NetworkPathManagerTests (Phase 03)
        do {
            let passed = try await NetworkPathManagerTests.run()
            print("  [PASS] NetworkPathManagerTests:    \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkPathManagerTests:    Failed with error: \(error)")
            totalFailed += 1
        }

        // 8. ApplicationCoordinatorTests (Phase 02, 03 & 04)
        do {
            let passed = try await ApplicationCoordinatorTests.run()
            print("  [PASS] ApplicationCoordinatorTests:        \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] ApplicationCoordinatorTests:        Failed with error: \(error)")
            totalFailed += 1
        }

        // 9. NetworkInterfaceProviderTests (Phase 04)
        do {
            let passed = try await NetworkInterfaceProviderTests.run()
            print("  [PASS] NetworkInterfaceProviderTests:       \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkInterfaceProviderTests:       Failed with error: \(error)")
            totalFailed += 1
        }

        // 10. NetworkInterfaceSelectorTests (Phase 04)
        do {
            let passed = try NetworkInterfaceSelectorTests.run()
            print("  [PASS] NetworkInterfaceSelectorTests:       \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkInterfaceSelectorTests:       Failed with error: \(error)")
            totalFailed += 1
        }

        // 11. NetworkSnapshotIntegrationTests (Phase 04)
        do {
            let passed = try await NetworkSnapshotIntegrationTests.run()
            print("  [PASS] NetworkSnapshotIntegrationTests:     \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkSnapshotIntegrationTests:     Failed with error: \(error)")
            totalFailed += 1
        }

        // 12. NetworkSpeedCalculatorTests (Phase 05)
        do {
            let passed = try await NetworkSpeedCalculatorTests.run()
            print("  [PASS] NetworkSpeedCalculatorTests:         \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] NetworkSpeedCalculatorTests:         Failed with error: \(error)")
            totalFailed += 1
        }

        // 13. SpeedFormatterTests (Phase 06)
        do {
            let passed = try SpeedFormatterTests.run()
            print("  [PASS] SpeedFormatterTests:                 \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] SpeedFormatterTests:                 Failed with error: \(error)")
            totalFailed += 1
        }

        // 14. DominantDirectionEngineTests (Phase 07)
        do {
            let passed = try await DominantDirectionEngineTests.run()
            print("  [PASS] DominantDirectionEngineTests:        \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] DominantDirectionEngineTests:        Failed with error: \(error)")
            totalFailed += 1
        }

        // 15. MenuBarRendererTests (Phase 08)
        do {
            let passed = try MenuBarRendererTests.run()
            print("  [PASS] MenuBarRendererTests:                \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] MenuBarRendererTests:                Failed with error: \(error)")
            totalFailed += 1
        }

        // 16. MenuBarManagerTests (Phase 08)
        do {
            let passed = try await MenuBarManagerTests.run()
            print("  [PASS] MenuBarManagerTests:                 \(passed) assertion checks passed")
            totalPassed += passed
        } catch {
            print("  [FAIL] MenuBarManagerTests:                 Failed with error: \(error)")
            totalFailed += 1
        }

        let endTime = DispatchTime.now()
        let elapsedMilliseconds = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0

        print("--------------------------------------------------")
        print("Test Execution Summary:")
        print("  Total Passed: \(totalPassed) assertions across 16 test suites")
        print("  Total Failed: \(totalFailed)")
        print(String(format: "  Execution Duration: %.2f ms", elapsedMilliseconds))
        print("==================================================")

        if totalFailed > 0 {
            exit(1)
        } else {
            print("ALL UNIT TESTS PASSED SUCCESSFULLY.")
            exit(0)
        }
    }
}
