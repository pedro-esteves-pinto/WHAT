@testable import WHAT
import XCTest

final class SessionStateMachineTests: XCTestCase {
    func testInitialPhaseIsNotStarted() {
        let machine = SessionStateMachine(config: .default)
        XCTAssertEqual(machine.phase, .notStarted)
    }

    func testStartBeginsWithPowerBreathing() {
        let machine = makeStateMachine()
        machine.start()
        XCTAssertEqual(machine.phase, .powerBreathing(cycleIndex: 0))
    }

    func testBreathCountIncrements() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 1, breathsPerCycle: 3, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()
        XCTAssertEqual(machine.breathCount, 0)

        // After 1.5 seconds at 1 breath/sec, should have 1 breath completed
        currentTime = time.addingTimeInterval(1.5)
        machine.tick()
        XCTAssertEqual(machine.breathCount, 1)
    }

    func testTransitionToPowerBreathingToRetention() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 1, breathsPerCycle: 2, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()

        // After 2 breaths (2 seconds at 1 bps), should transition to retention
        currentTime = time.addingTimeInterval(2.0)
        machine.tick()
        XCTAssertEqual(machine.phase, .retention(cycleIndex: 0))
    }

    func testEndRetentionTransitionsToRecovery() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 1, breathsPerCycle: 2, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()
        currentTime = time.addingTimeInterval(2.0)
        machine.tick()
        XCTAssertEqual(machine.phase, .retention(cycleIndex: 0))

        currentTime = time.addingTimeInterval(5.0)
        machine.tick()
        machine.endRetention()
        XCTAssertEqual(machine.phase, .recovery(cycleIndex: 0))
        XCTAssertEqual(machine.cycleRecords[0].retentionDurationSeconds, 3.0, accuracy: 0.1)
    }

    func testRecoveryTransitionsToNextCycleOrCompleted() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 1, breathsPerCycle: 2, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()
        // Finish breathing
        currentTime = time.addingTimeInterval(2.0)
        machine.tick()
        // End retention
        currentTime = time.addingTimeInterval(5.0)
        machine.tick()
        machine.endRetention()
        XCTAssertEqual(machine.phase, .recovery(cycleIndex: 0))

        // After 15 seconds of recovery, should complete (only 1 cycle)
        currentTime = time.addingTimeInterval(20.1)
        machine.tick()
        XCTAssertEqual(machine.phase, .completed)
    }

    func testMultipleCyclesLoop() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 2, breathsPerCycle: 2, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()

        // Cycle 1: breathing
        currentTime = time.addingTimeInterval(2.0)
        machine.tick()
        XCTAssertEqual(machine.phase, .retention(cycleIndex: 0))

        // Cycle 1: retention
        currentTime = time.addingTimeInterval(5.0)
        machine.tick()
        machine.endRetention()
        XCTAssertEqual(machine.phase, .recovery(cycleIndex: 0))

        // Cycle 1: recovery ends → cycle 2 begins
        currentTime = time.addingTimeInterval(20.1)
        machine.tick()
        XCTAssertEqual(machine.phase, .powerBreathing(cycleIndex: 1))

        // Cycle 2: breathing
        currentTime = time.addingTimeInterval(22.1)
        machine.tick()
        XCTAssertEqual(machine.phase, .retention(cycleIndex: 1))

        // Cycle 2: retention
        currentTime = time.addingTimeInterval(25.0)
        machine.tick()
        machine.endRetention()
        XCTAssertEqual(machine.phase, .recovery(cycleIndex: 1))

        // Cycle 2: recovery ends → completed
        currentTime = time.addingTimeInterval(40.1)
        machine.tick()
        XCTAssertEqual(machine.phase, .completed)
        XCTAssertEqual(machine.cycleRecords.count, 2)
    }

    func testBreathProgressOscillates() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 1, breathsPerCycle: 10, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()

        // At 25% through a breath (inhaling), progress should be ~0.5
        currentTime = time.addingTimeInterval(0.25)
        machine.tick()
        XCTAssertEqual(machine.breathProgress, 0.5, accuracy: 0.01)

        // At 50% through a breath (peak), progress should be ~1.0
        currentTime = time.addingTimeInterval(0.5)
        machine.tick()
        XCTAssertEqual(machine.breathProgress, 1.0, accuracy: 0.01)

        // At 75% through a breath (exhaling), progress should be ~0.5
        currentTime = time.addingTimeInterval(0.75)
        machine.tick()
        XCTAssertEqual(machine.breathProgress, 0.5, accuracy: 0.01)
    }

    func testCycleRecordTimestamps() {
        let time = Date()
        var currentTime = time
        let config = SessionConfig(numberOfCycles: 1, breathsPerCycle: 2, cadence: 1.0)
        let machine = SessionStateMachine(config: config)
        machine.timeSource = { currentTime }

        machine.start()
        XCTAssertEqual(machine.cycleRecords.count, 1)
        XCTAssertNotNil(machine.cycleRecords[0].startTimestamp)

        currentTime = time.addingTimeInterval(2.0)
        machine.tick()
        XCTAssertNotNil(machine.cycleRecords[0].retentionStartTimestamp)

        currentTime = time.addingTimeInterval(5.0)
        machine.tick()
        machine.endRetention()
        XCTAssertNotNil(machine.cycleRecords[0].retentionEndTimestamp)
    }

    // MARK: - Helpers

    private func makeStateMachine(config: SessionConfig = .default) -> SessionStateMachine {
        let machine = SessionStateMachine(config: config)
        let time = Date()
        machine.timeSource = { time }
        return machine
    }
}
