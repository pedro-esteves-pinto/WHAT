import Foundation
import HealthKit

// MARK: - Protocol

protocol HeartRateProvider {
    var isAvailable: Bool { get }
    var onHeartRateUpdate: ((Double) -> Void)? { get set }
    func requestAuthorization() async -> Bool
    func startMonitoring()
    func stopMonitoring() -> [HeartRateSample]
}

// MARK: - HealthKit Implementation

final class HealthKitManager: HeartRateProvider {
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var collectedSamples: [HeartRateSample] = []

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var onHeartRateUpdate: ((Double) -> Void)?

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }

        let heartRateType = HKQuantityType(.heartRate)
        let read: Set<HKObjectType> = [heartRateType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: read)
            return true
        } catch {
            return false
        }
    }

    func startMonitoring() {
        guard isAvailable else { return }
        collectedSamples = []
        startHeartRateQuery()
    }

    func stopMonitoring() -> [HeartRateSample] {
        stopHeartRateQuery()
        return collectedSamples
    }

    // MARK: - Heart Rate Query

    private func startHeartRateQuery() {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date(),
            end: nil,
            options: .strictStartDate
        )

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.processHeartRateSamples(samples)
        }

        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.processHeartRateSamples(samples)
        }

        healthStore.execute(query)
        heartRateQuery = query
    }

    private func stopHeartRateQuery() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }

    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        for sample in quantitySamples {
            let bpm = sample.quantity.doubleValue(for: bpmUnit)
            let hrSample = HeartRateSample(timestamp: sample.startDate, bpm: bpm)
            collectedSamples.append(hrSample)

            DispatchQueue.main.async { [weak self] in
                self?.onHeartRateUpdate?(bpm)
            }
        }
    }
}
