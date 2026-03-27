# Guidelines

- Use Red/Green TDD
- Maintain a README.md document explaining the Architecture of the system and its main flows. Use mermaid diagrams liberaly to make things easier to understand
- Use **SwiftLint** for static analysis and style enforcement, configured via `.swiftlint.yml` at the project root
- Use **SwiftFormat** for automatic code formatting
- **Unit tests (XCTest)**: Focus on state machine transitions, breathing animation math, model validation, and UserDefaultsStore persistence. Abstract the time source (CADisplayLink) for testability.
- **UI tests (XCUITest)**: Cover key user flows — configure session, start session, complete retention, view history.
- **Integration tests**: Use in-memory `ModelContainer` to test SwiftData persistence in isolation.
- **Snapshot tests**: Use **swift-snapshot-testing** for SwiftUI view regression testing.
- Before concluding any change make sure to update the documentation and run all the tests. Only in the case of success should the change be considered done.
