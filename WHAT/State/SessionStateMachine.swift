import Foundation
import Observation

@Observable
final class SessionStateMachine {
    enum Phase: Equatable {
        case notStarted
        case powerBreathing(cycleIndex: Int)
        case retention(cycleIndex: Int)
        case recovery(cycleIndex: Int)
        case completed
    }

    private(set) var phase: Phase = .notStarted
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var breathCount: Int = 0
    private(set) var breathProgress: Double = 0
    private(set) var retentionTime: TimeInterval = 0
    private(set) var recoveryTimeRemaining: TimeInterval = 15

    let config: SessionConfig
    private(set) var cycleRecords: [CycleRecord] = []
    private var sessionStartDate: Date?

    private var phaseStartTime: TimeInterval = 0
    private var displayLink: Any?
    private var totalElapsed: TimeInterval = 0
    private var startTime: Date?

    var timeSource: (() -> Date)?

    private var now: Date {
        timeSource?() ?? Date()
    }

    static let recoveryDuration: TimeInterval = 15

    init(config: SessionConfig) {
        self.config = config
    }

    func start() {
        let currentTime = now
        startTime = currentTime
        sessionStartDate = currentTime
        totalElapsed = 0
        beginPowerBreathing(cycleIndex: 0, at: currentTime)
        startDisplayLink()
    }

    func endRetention() {
        guard case let .retention(cycleIndex) = phase else { return }
        let currentTime = now
        let record = cycleRecords[cycleIndex]
        record.retentionEndTimestamp = currentTime
        record.retentionDurationSeconds = retentionTime
        beginRecovery(cycleIndex: cycleIndex, at: currentTime)
    }

    func stop() {
        stopDisplayLink()
        phase = .completed
    }

    var totalDuration: TimeInterval {
        totalElapsed
    }

    var sessionStart: Date? {
        sessionStartDate
    }

    // MARK: - Phase transitions

    private func beginPowerBreathing(cycleIndex: Int, at time: Date) {
        phase = .powerBreathing(cycleIndex: cycleIndex)
        breathCount = 0
        breathProgress = 0
        phaseStartTime = totalElapsed

        let record = CycleRecord(cycleIndex: cycleIndex, startTimestamp: time)
        if cycleIndex < cycleRecords.count {
            cycleRecords[cycleIndex] = record
        } else {
            cycleRecords.append(record)
        }
    }

    private func beginRetention(cycleIndex: Int, at time: Date) {
        phase = .retention(cycleIndex: cycleIndex)
        retentionTime = 0
        phaseStartTime = totalElapsed
        cycleRecords[cycleIndex].retentionStartTimestamp = time
    }

    private func beginRecovery(cycleIndex: Int, at time: Date) {
        phase = .recovery(cycleIndex: cycleIndex)
        recoveryTimeRemaining = Self.recoveryDuration
        phaseStartTime = totalElapsed
    }

    // MARK: - Tick

    func tick() {
        guard let startTime else { return }
        totalElapsed = now.timeIntervalSince(startTime)

        let phaseElapsed = totalElapsed - phaseStartTime

        switch phase {
        case let .powerBreathing(cycleIndex):
            updateBreathing(phaseElapsed: phaseElapsed, cycleIndex: cycleIndex)
        case .retention:
            retentionTime = phaseElapsed
        case let .recovery(cycleIndex):
            let remaining = Self.recoveryDuration - phaseElapsed
            recoveryTimeRemaining = max(0, remaining)
            if remaining <= 0 {
                let nextCycle = cycleIndex + 1
                if nextCycle < config.numberOfCycles {
                    cycleRecords[cycleIndex].recoveryEndTimestamp = now
                    beginPowerBreathing(cycleIndex: nextCycle, at: now)
                } else {
                    cycleRecords[cycleIndex].recoveryEndTimestamp = now
                    stop()
                }
            }
        default:
            break
        }
    }

    private func updateBreathing(phaseElapsed: TimeInterval, cycleIndex: Int) {
        let breathDuration = 1.0 / config.cadence
        let totalBreaths = phaseElapsed / breathDuration
        let currentBreath = Int(totalBreaths)

        if currentBreath >= config.breathsPerCycle {
            breathCount = config.breathsPerCycle
            breathProgress = 0
            beginRetention(cycleIndex: cycleIndex, at: now)
            return
        }

        breathCount = currentBreath
        let fraction = totalBreaths - Double(currentBreath)
        // 0→1 on inhale (first half), 1→0 on exhale (second half)
        breathProgress = fraction < 0.5
            ? fraction * 2.0
            : (1.0 - fraction) * 2.0
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        #if !targetEnvironment(simulator) || true
            let link = CADisplayLinkProxy { [weak self] in
                self?.tick()
            }
            displayLink = link
        #endif
    }

    private func stopDisplayLink() {
        if let link = displayLink as? CADisplayLinkProxy {
            link.invalidate()
        }
        displayLink = nil
    }

    deinit {
        stopDisplayLink()
    }
}

// MARK: - CADisplayLink wrapper

import QuartzCore

final class CADisplayLinkProxy {
    private var displayLink: CADisplayLink?
    private let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
        self.displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func tick() {
        callback()
    }

    func invalidate() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
