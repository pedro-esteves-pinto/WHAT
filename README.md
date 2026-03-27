# WHAT — Wim Hof Auto Tracker

An iOS app that guides practitioners through Wim Hof Method (WHM) breathing sessions with real-time heart rate tracking.

## Architecture

The app follows a simple **Model–View–State** architecture:

- **Models** (SwiftData) — Persistent records for sessions, cycles, and heart rate samples
- **State** — An `@Observable` state machine drives the session, with a `Codable` config struct
- **Views** (SwiftUI) — Reactive UI bound to the state machine and SwiftData queries
- **Services** — HealthKit integration and UserDefaults persistence

```mermaid
graph TD
    A[HomeView] -->|configure| B[ConfigView]
    A -->|start session| C[SessionContainerView]
    A -->|view history| D[HistoryListView - date grouped]

    C --> E[PowerBreathingView]
    C --> F[RetentionView]
    C --> G[RecoveryView]
    C --> H[PostSessionView]

    E --> I[BreathingCircle]
    C --> J[HeartRateDisplay]

    D --> K[SessionDetailView]
    K --> L[HRChartView]

    subgraph State
        M[SessionStateMachine]
        N[SessionConfig]
    end

    subgraph Services
        O[UserDefaultsStore]
        P[HealthKitManager]
    end

    subgraph Models
        Q[Session]
        R[CycleRecord]
        S[HeartRateSample]
    end

    C ---|drives| M
    A ---|persists config| O
    C ---|saves session| Q
    Q --- R
    Q --- S
```

## Session State Machine

The session is driven by a single `@Observable` class (`SessionStateMachine`) with a `Phase` enum. A single `CADisplayLink` timer drives all phases — no per-phase timer lifecycle to manage.

```mermaid
stateDiagram-v2
    [*] --> notStarted
    notStarted --> powerBreathing : start()

    powerBreathing --> retention : breathCount reaches target
    retention --> recovery : user taps "I Breathed"
    recovery --> powerBreathing : 15s elapsed\n(more cycles)
    recovery --> completed : 15s elapsed\n(last cycle)

    completed --> [*]
```

### Phase Details

| Phase | Driver | Transition |
|-------|--------|------------|
| **Power Breathing** | Math-based breath progress from elapsed time (avoids animation drift) | Auto-transitions when breath count reaches `breathsPerCycle` |
| **Retention** | Elapsed timer | User taps "I Breathed" — retention duration logged |
| **Recovery** | 15-second countdown | Auto-transitions to next cycle or `completed` |

## Data Model

```mermaid
erDiagram
    Session ||--o{ CycleRecord : "has cycles"
    Session ||--o{ HeartRateSample : "has HR samples"

    Session {
        UUID id
        Date date
        Int numberOfCycles
        Int breathsPerCycle
        Double cadence
        Double totalDurationSeconds
    }

    CycleRecord {
        Int cycleIndex
        Double retentionDurationSeconds
        Date startTimestamp
        Date retentionStartTimestamp
        Date retentionEndTimestamp
        Date recoveryEndTimestamp
    }

    HeartRateSample {
        Date timestamp
        Double bpm
    }
```

Relationships use `@Relationship(deleteRule: .cascade)` — deleting a `Session` removes all child records.

`SessionConfig` is a separate `Codable` struct stored in `UserDefaults` (not SwiftData) to remember the user's last choices.

## History & Persistence

Sessions are saved to SwiftData when the user taps "Done" on the post-session screen. The history view groups sessions by date with section headers, showing the time and summary for each session. Swipe-to-delete removes sessions (cascade deletes all child cycle records and heart rate samples).

```mermaid
flowchart LR
    A[Session Completes] --> B[Save Session + CycleRecords to SwiftData]
    B --> C[HistoryListView]
    C -->|grouped by date| D[Section per day]
    D -->|tap| E[SessionDetailView]
    D -->|swipe| F[Delete Session cascade]
```

## Session Flow

```mermaid
sequenceDiagram
    participant U as User
    participant H as HomeView
    participant SM as SessionStateMachine
    participant DB as SwiftData

    U->>H: Configure & tap Start
    H->>SM: start()
    loop For each cycle
        SM->>SM: powerBreathing (CADisplayLink ticks)
        SM->>SM: retention (timer running)
        U->>SM: endRetention()
        SM->>SM: recovery (15s countdown)
    end
    SM->>SM: completed
    SM->>DB: Save Session + CycleRecords
    U->>H: Dismiss
```

## Project Structure

```
WHAT/
├── WHAT/
│   ├── WHATApp.swift              # App entry point, ModelContainer setup
│   ├── Models/
│   │   ├── Session.swift          # SwiftData — root session record
│   │   ├── CycleRecord.swift      # SwiftData — per-cycle timestamps + retention
│   │   └── HeartRateSample.swift  # SwiftData — timestamped HR reading
│   ├── State/
│   │   ├── SessionConfig.swift    # Codable value type for config
│   │   └── SessionStateMachine.swift  # @Observable — drives all phases + timers
│   ├── Services/
│   │   ├── HealthKitManager.swift # HealthKit auth + HR streaming (Phase 4)
│   │   └── UserDefaultsStore.swift
│   ├── Views/
│   │   ├── HomeView.swift
│   │   ├── ConfigView.swift
│   │   ├── Session/
│   │   │   ├── SessionContainerView.swift
│   │   │   ├── PowerBreathingView.swift
│   │   │   ├── BreathingCircle.swift
│   │   │   ├── RetentionView.swift
│   │   │   └── RecoveryView.swift
│   │   ├── PostSession/
│   │   │   └── PostSessionView.swift
│   │   ├── History/
│   │   │   ├── HistoryListView.swift
│   │   │   └── SessionDetailView.swift
│   │   └── Components/
│   │       └── HeartRateDisplay.swift
│   └── Charts/
│       └── HRChartView.swift      # Swift Charts (Phase 5)
├── WHATTests/                     # Unit + integration tests
├── WHATUITests/                   # UI tests
├── project.yml                    # XcodeGen project definition
└── .swiftlint.yml                 # SwiftLint configuration
```

## Testing Strategy

- **Unit tests (XCTest)**: State machine transitions, breathing math, config validation, UserDefaults persistence
- **Integration tests**: In-memory `ModelContainer` for SwiftData persistence
- **UI tests (XCUITest)**: Key user flows — configure session, start session, view history
- **Snapshot tests**: SwiftUI view regression testing via swift-snapshot-testing

## Building

```bash
# Generate Xcode project
xcodegen generate

# Build
xcodebuild -project WHAT.xcodeproj -scheme WHAT \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' build

# Run tests
xcodebuild -project WHAT.xcodeproj -scheme WHATTests \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' test
```
