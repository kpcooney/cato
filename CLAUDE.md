# CLAUDE.md — Cato: Your AI Personal Trainer

> **What is this file?** This is the single source of truth for the Cato iOS app. Read it fully before making any changes. Reference it when making architectural decisions. If something contradicts this file, this file wins.

---

## Project Summary

Cato is a native iOS personal trainer app. Users create workout programs using natural language (or URLs), and Cato coaches them through sessions with voice interaction, manages progression automatically, and syncs Apple Watch health data. Named after the Latin "catus" — skilled, wise, disciplined.

**App Store positioning:** "Cato — Your AI Personal Trainer"
**Tagline:** "Skilled. Wise. Relentless."

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift |
| UI | SwiftUI |
| Local persistence | SwiftData |
| Cloud backend | CloudKit (private database) |
| Auth | Apple Sign-In only |
| Workout parsing | Claude API (Anthropic Messages API) |
| Voice recognition | SFSpeechRecognizer (on-device only) |
| Text-to-speech | AVSpeechSynthesizer |
| Health data | HealthKit (read-only in v1) |
| Min iOS | 17.0+ |
| Target device | iPhone (iPad later) |
| Watch | Apple Watch Series 4+ (optional) |

---

## Commands

```bash
# Build
xcodebuild -scheme Cato -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Test
xcodebuild -scheme Cato -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test

# Clean
xcodebuild -scheme Cato clean
```

---

## Coding Conventions

- **Architecture**: MVVM. Views in SwiftUI, business logic in ViewModels, data access in Services.
- **Naming**: Swift API Design Guidelines. Types are `UpperCamelCase`, properties/methods are `lowerCamelCase`.
- **SwiftData models**: Use `@Model` macro. Define relationships explicitly.
- **CloudKit**: All models sync via SwiftData + CloudKit integration. Use `CKReference` for parent-child relationships.
- **No third-party dependencies** unless absolutely necessary. Prefer Apple frameworks.
- **Error handling**: Use Swift's typed throws where possible. Never force unwrap in production code. Use `guard let` for early returns.
- **Async/await**: Use structured concurrency. No completion handlers for new code.
- **Accessibility**: Every interactive element needs an accessibility label. Support Dynamic Type everywhere.
- **Voice lines**: All text that Cato speaks to the user must come from `CatoPersona.swift`. Never hardcode voice strings in Views or ViewModels.

---

## Project Structure

```
Cato/
├── App/
│   ├── CatoApp.swift                   # App entry point, scene configuration
│   └── ContentView.swift               # Root view with tab navigation
├── Persona/
│   └── CatoPersona.swift               # ALL of Cato's voice lines and persona text
├── Models/
│   ├── WorkoutProgram.swift
│   ├── ProgramWeek.swift
│   ├── ProgramDay.swift
│   ├── ProgramActivity.swift
│   ├── ActivityTarget.swift
│   ├── ProgressionRule.swift
│   ├── WorkoutSession.swift
│   ├── CompletedActivity.swift
│   ├── CompletedSet.swift
│   ├── CompletedTarget.swift
│   ├── SessionHealthMetrics.swift
│   ├── ProgressionEvent.swift
│   └── Enums.swift
├── Views/
│   ├── Today/
│   │   ├── TodayView.swift             # Home tab: today's workout, start button
│   │   └── WorkoutSummaryCard.swift
│   ├── Programs/
│   │   ├── ProgramListView.swift       # All programs list
│   │   ├── ProgramDetailView.swift     # Single program detail/edit
│   │   ├── ProgramBuilderView.swift    # Manual program creation form
│   │   └── NaturalLanguageInputView.swift  # NL/URL input screen
│   ├── Session/
│   │   ├── ActiveSessionView.swift     # Main workout tracking screen
│   │   ├── SetLogView.swift            # Rep logging (tap buttons)
│   │   ├── RestTimerView.swift         # Countdown timer between sets
│   │   └── SessionCompleteView.swift   # Post-workout summary
│   ├── History/
│   │   ├── HistoryListView.swift       # Chronological workout log
│   │   └── SessionDetailView.swift     # Single session drill-down
│   └── Settings/
│       └── SettingsView.swift
├── ViewModels/
│   ├── ProgramViewModel.swift
│   ├── SessionViewModel.swift
│   ├── HistoryViewModel.swift
│   └── ProgressionEngine.swift
├── Services/
│   ├── CloudKitService.swift           # CloudKit CRUD and sync
│   ├── ClaudeAPIService.swift          # Anthropic API for workout parsing
│   ├── VoiceRecognitionService.swift   # SFSpeechRecognizer wrapper
│   ├── CatoSpeechService.swift         # AVSpeechSynthesizer + persona voice lines
│   ├── HealthKitService.swift          # HealthKit queries and observation
│   └── ProgressionService.swift        # Post-session progression evaluation
├── Utilities/
│   ├── ExerciseDatabase.swift          # Local DB of ~200+ common exercise names
│   ├── WeightRounding.swift            # Round to nearest plate increment
│   └── Extensions/
└── Resources/
    └── exercises.json                  # Seed data for exercise name autocomplete
```

---

## Development Phases

> **CURRENT PHASE: 2**
> Update this marker as you complete each phase.

### Phase 1 — Foundation ✅ COMPLETE
Build the skeleton: data models, CloudKit, auth, navigation.

**Tasks:**
- [x] Create Xcode project with bundle ID and CloudKit capability
- [x] Define all SwiftData `@Model` classes from the Data Models section below
- [x] Define all enums in `Enums.swift`
- [x] Configure CloudKit container and enable SwiftData + CloudKit sync
- [x] Implement Apple Sign-In flow
- [x] Build 4-tab navigation shell (Today, Programs, History, Settings)
- [x] Create `CatoPersona.swift` with all voice line strings
- [x] Stub all Service classes with protocols

**Done when:** App launches, user can sign in with Apple, four empty tabs are visible, all models compile and sync to CloudKit.

**Status:** ✅ Complete (2026-02-17) — See PHASE1_COMPLETE.md for details.

### Phase 2 — Program Management
Users can create and manage workout programs.

**Tasks:**
- [ ] Build `ProgramListView` with create/edit/delete/archive
- [ ] Build `ProgramBuilderView` — manual form-based program creation for strength activities
- [ ] Build `ProgramDetailView` — view/edit existing programs
- [ ] Populate `exercises.json` with ~200 common exercise names
- [ ] Build `ExerciseDatabase.swift` with search/autocomplete
- [ ] Implement `ClaudeAPIService` — send text/URL, receive structured JSON
- [ ] Build `NaturalLanguageInputView` — text field and URL input
- [ ] Build post-parse review screen (editable structured view of parsed program)
- [ ] Active program toggle (only one active at a time)

**Done when:** User can create a program manually or via natural language/URL, review and edit the parsed result, save it, and set it as active.

### Phase 3 — Active Workout Session
Cato coaches the user through a workout.

**Tasks:**
- [ ] Build `ActiveSessionView` — exercise display, set tracking, rest timer
- [ ] Build `SetLogView` — tap-to-log rep buttons [1] [2] [3] [4] [5] [+]
- [ ] Build `RestTimerView` — countdown with skip option
- [ ] Implement `SessionViewModel` — manage session state, log sets, advance exercises
- [ ] Implement `VoiceRecognitionService` — on-device SFSpeechRecognizer
- [ ] Implement `CatoSpeechService` — TTS using voice lines from CatoPersona
- [ ] Smart listening: pause during rest, resume 5 sec before rest ends
- [ ] Weight override mid-session (voice and tap)
- [ ] Build `SessionCompleteView` — post-workout summary
- [ ] Voice-off mode: full tap-only experience with haptic/sound rest alerts

**Done when:** User can start a workout, complete all sets via voice or tap, hear Cato's coaching cues, see rest timers, override weight, and complete the session with a summary.

### Phase 4 — Progression Engine
Cato adjusts targets based on performance.

**Tasks:**
- [ ] Implement `ProgressionService` — evaluate rules against completed sets
- [ ] Percentage increase logic with plate-increment rounding
- [ ] Fixed increment logic
- [ ] Rep increase logic (with optional rep ceiling + weight bump)
- [ ] Deload logic (N consecutive failures → reduce weight for M sessions)
- [ ] Log `ProgressionEvent` for every progression decision
- [ ] Cato announces progression at session end (voice + on-screen)
- [ ] Integrate with `SessionViewModel` — run progression after session completion

**Done when:** After completing a session, Cato correctly evaluates progression rules, updates targets for the next session, logs events, and announces changes.

### Phase 5 — HealthKit & History
Capture Apple Watch data and display workout history.

**Tasks:**
- [ ] Implement `HealthKitService` — request auth, query HR and calories
- [ ] Start HKWorkoutSession when workout begins (if Watch available)
- [ ] Observe heart rate samples via HKAnchoredObjectQuery during session
- [ ] Aggregate metrics at session end (avg/max/min HR, calories)
- [ ] Graceful degradation when no Watch connected (nil metrics, no errors)
- [ ] Build `HistoryListView` — chronological log with session cards
- [ ] Build `SessionDetailView` — drill into exercises, sets, health metrics, progression events
- [ ] Per-activity history view (all instances of a specific exercise)
- [ ] Filter history by program and date range

**Done when:** Workout sessions display in history with full detail. If Apple Watch is connected, HR and calories appear alongside performance data.

### Phase 6 — Polish & App Store
Final refinements and release prep.

**Tasks:**
- [ ] Build `SettingsView` — units, voice toggle, TTS speed, HealthKit permissions
- [ ] Onboarding flow (Cato introduces itself on first launch)
- [ ] Error handling audit — network failures, empty states, edge cases
- [ ] Offline mode testing — ensure full session works without connectivity
- [ ] App Store assets — icon, screenshots, description, keywords
- [ ] TestFlight beta distribution

**Done when:** App is polished, handles all edge cases, and is ready for TestFlight.

---

## Cato's Trainer Persona

Cato has a consistent voice across all interactions. All voice lines live in `CatoPersona.swift`.

### Personality
- **Direct**: Doesn't waste words. "Rest 60 seconds." not "Great job! You've earned a rest!"
- **Encouraging but not soft**: "Solid set." "That's a PR." "Missed one rep — we'll get it next time."
- **Knowledgeable**: When adjusting weight or deloading, Cato explains briefly why.
- **Consistent**: Same calm, confident tone always. No mood swings.

### Voice Line Reference

```swift
// Session start
"Let's get to work. First up: \(exercise). \(sets) sets of \(reps) at \(weight)."

// Set complete (success)
"Set \(n) done. \(reps) at \(weight). Solid."

// Set complete (failure)
"Got \(actual) of \(target). Noted. Rest up."

// Rest timer
"Rest \(duration) seconds."     // start
"30 seconds."                    // 30s remaining
"10 seconds."                    // 10s remaining
"Let's go."                      // timer done

// Next exercise
"Next: \(exercise). \(sets) sets of \(reps) at \(weight)."

// Exercise complete
"\(exercise) done. Moving to \(nextExercise)."

// Session complete
"Done. \(minutes) minutes, \(exerciseCount) exercises, \(totalSets) sets. Good session."

// Progression
"You hit all your reps this week. \(exercise) goes up to \(newWeight) next session."

// Deload
"Three misses in a row on \(exercise). Dropping to \(newWeight) for the next \(n) sessions. We'll build back."

// Today tab greeting
"Push Day today. Ready when you are."  // training day
"Rest day. Recover up."                 // rest day

// Error
"Can't reach the server. Try again or build it manually."

// Weight override confirmation
"Got it. Using \(newWeight)."

// Skip confirmation
"Skipping \(exercise). Next: \(nextExercise)."
```

### Persona Rules
- No emojis in voice or session UI text.
- No jokes or small talk during sessions.
- Slightly warmer in summaries and history (e.g., "Strong week.").
- Never uses gendered language.
- Voice is optional — user can disable entirely in Settings.

---

## Data Models

> **Design principle: Workout-type agnostic.** The `ActivityTarget` system uses flexible metric/value/unit fields instead of rigid sets/reps/weight. v1 implements strength training. The same schema supports cardio, running, intervals, and timed holds without changes.

### Enums

```swift
enum ProgramType: String, Codable {
    case strength, cardio, hybrid, flexibility, custom
}

enum SourceType: String, Codable {
    case manual, naturalLanguage, url
}

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
}

enum DayType: String, Codable {
    case training, rest, activeRecovery
}

enum ActivityType: String, Codable {
    case strength, cardio, distance, timed, custom
}

enum TargetMetric: String, Codable {
    case reps, weight, distance, duration, pace, calories, heartRateZone
}

enum TargetUnit: String, Codable {
    case count, lbs, kg, miles, km, meters
    case seconds, minutes, hours
    case minPerMile, minPerKm
    case bpm
}

enum ProgressionType: String, Codable {
    case percentage, fixedIncrement, repIncrease
}

enum ProgressionUnit: String, Codable {
    case percent, lbs, kg, reps
    case seconds, minutes, miles, km
}

enum ProgressionFrequency: String, Codable {
    case perSession, perWeek, perCycle
}

enum ConditionType: String, Codable {
    case allTargetsMet, rpeBelow, custom
}

enum SessionStatus: String, Codable {
    case inProgress, completed, abandoned
}
```

### WorkoutProgram

```swift
@Model
class WorkoutProgram {
    var id: UUID
    var name: String                          // "Starting Strength", "Couch to 5K"
    var programDescription: String?
    var programType: ProgramType              // .strength, .cardio, .hybrid, etc.
    var sourceType: SourceType                // .manual, .naturalLanguage, .url
    var sourceText: String?                   // Original input or URL
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool                        // Only one active at a time

    @Relationship(deleteRule: .cascade)
    var weeks: [ProgramWeek]

    @Relationship(deleteRule: .cascade)
    var defaultProgressionRules: [ProgressionRule]
}
```

### ProgramWeek

```swift
@Model
class ProgramWeek {
    var id: UUID
    var weekNumber: Int                       // 1-indexed
    var isDeloadWeek: Bool

    @Relationship(deleteRule: .cascade)
    var days: [ProgramDay]

    var program: WorkoutProgram?
}
```

### ProgramDay

```swift
@Model
class ProgramDay {
    var id: UUID
    var dayOfWeek: DayOfWeek                  // .monday through .sunday
    var name: String?                         // "Push Day", "Easy Run", "Rest"
    var dayType: DayType                      // .training, .rest, .activeRecovery
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var activities: [ProgramActivity]         // Empty for rest days

    var week: ProgramWeek?
}
```

### ProgramActivity

Core abstraction — represents any prescribed activity, any workout type.

```swift
@Model
class ProgramActivity {
    var id: UUID
    var activityName: String                  // "Barbell Bench Press", "Tempo Run"
    var activityType: ActivityType            // .strength, .cardio, .distance, .timed
    var orderIndex: Int
    var restBetweenSets: TimeInterval?        // For set-based activities
    var restAfterActivity: TimeInterval?
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var targets: [ActivityTarget]

    var progressionRuleOverride: ProgressionRule?
    var day: ProgramDay?
}
```

### ActivityTarget

The flexible target system. Each activity has one or more targets defining what "done" means.

```swift
@Model
class ActivityTarget {
    var id: UUID
    var metric: TargetMetric                  // .reps, .weight, .distance, .duration, .pace
    var value: Double                         // Target value
    var unit: TargetUnit                      // .count, .lbs, .miles, .seconds, etc.
    var repeatCount: Int?                     // Sets (strength), intervals (cardio)

    var activity: ProgramActivity?
}
```

**Usage examples by workout type:**

```
// Strength: Bench Press 5x5 at 185 lbs
ActivityTarget(metric: .reps,   value: 5,   unit: .count, repeatCount: 5)
ActivityTarget(metric: .weight, value: 185,  unit: .lbs,   repeatCount: nil)

// Running (future): 5-mile tempo run at 8:30/mile
ActivityTarget(metric: .distance, value: 5,   unit: .miles,      repeatCount: nil)
ActivityTarget(metric: .pace,     value: 8.5, unit: .minPerMile,  repeatCount: nil)

// Intervals (future): 8 x 400m in 90 seconds
ActivityTarget(metric: .distance, value: 400, unit: .meters,  repeatCount: 8)
ActivityTarget(metric: .duration, value: 90,  unit: .seconds, repeatCount: 8)

// Timed (future): 3 x 60s plank
ActivityTarget(metric: .duration, value: 60, unit: .seconds, repeatCount: 3)
```

### ProgressionRule

```swift
@Model
class ProgressionRule {
    var id: UUID
    var targetMetric: TargetMetric            // Which metric to progress
    var type: ProgressionType                 // .percentage, .fixedIncrement, .repIncrease
    var value: Double                         // 10 = 10% or 10 lbs or 1 rep
    var unit: ProgressionUnit                 // .percent, .lbs, .kg, .reps, etc.
    var conditionType: ConditionType          // .allTargetsMet, .rpeBelow, .custom
    var conditionThreshold: Double?           // e.g., RPE < 8
    var consecutiveSuccesses: Int             // Must pass N sessions in a row
    var frequency: ProgressionFrequency       // .perSession, .perWeek, .perCycle
    var failuresBeforeDeload: Int?            // e.g., 3 consecutive failures
    var deloadPercentage: Double?             // e.g., reduce by 10%
    var deloadDuration: Int?                  // Sessions at reduced weight

    var program: WorkoutProgram?
    var activity: ProgramActivity?
}
```

### WorkoutSession

```swift
@Model
class WorkoutSession {
    var id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var status: SessionStatus                 // .inProgress, .completed, .abandoned
    var notes: String?

    var program: WorkoutProgram?
    var programDay: ProgramDay?

    @Relationship(deleteRule: .cascade)
    var completedActivities: [CompletedActivity]

    @Relationship(deleteRule: .cascade)
    var healthMetrics: SessionHealthMetrics?
}
```

### CompletedActivity

```swift
@Model
class CompletedActivity {
    var id: UUID
    var activityName: String                  // Denormalized for history readability
    var activityType: ActivityType
    var skipped: Bool
    var notes: String?

    var programActivity: ProgramActivity?
    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade)
    var sets: [CompletedSet]                  // For set-based activities

    @Relationship(deleteRule: .cascade)
    var completedTargets: [CompletedTarget]   // For continuous activities (future)
}
```

### CompletedSet

```swift
@Model
class CompletedSet {
    var id: UUID
    var setNumber: Int                        // 1-indexed
    var targetReps: Int                       // Prescribed
    var completedReps: Int                    // Actual
    var targetWeight: Double
    var actualWeight: Double                  // May differ if user overrode
    var weightUnit: TargetUnit
    var isFailure: Bool                       // completedReps < targetReps
    var rpe: Double?                          // Rate of Perceived Exertion (optional, future)
    var timestamp: Date

    var completedActivity: CompletedActivity?
}
```

### CompletedTarget (future use — continuous activities)

```swift
@Model
class CompletedTarget {
    var id: UUID
    var metric: TargetMetric
    var targetValue: Double
    var actualValue: Double
    var unit: TargetUnit
    var timestamp: Date

    var completedActivity: CompletedActivity?
}
```

### SessionHealthMetrics

```swift
@Model
class SessionHealthMetrics {
    var id: UUID
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var minHeartRate: Double?
    var activeCalories: Double?
    var totalCalories: Double?
    var duration: TimeInterval

    // Heart rate samples stored as parallel arrays for SwiftData compatibility
    var heartRateSampleTimestamps: [Date]
    var heartRateSampleValues: [Double]       // bpm values matching timestamps

    var session: WorkoutSession?
}
```

### ProgressionEvent

```swift
@Model
class ProgressionEvent {
    var id: UUID
    var activityName: String
    var date: Date
    var metric: TargetMetric
    var previousValue: Double
    var newValue: Double
    var unit: TargetUnit
    var reason: String                        // "All reps completed", "Deload: 3 failures"

    var session: WorkoutSession?
}
```

---

## Feature Specifications

### Natural Language Program Builder

**Input methods:**
1. Free text — user types a workout description
2. URL — user pastes a link to a workout article

**Pipeline:**
```
User input (text or URL)
  → If URL: fetch page content
  → Send to Claude API with structured prompt requesting JSON matching our data models
  → Parse JSON into WorkoutProgram + weeks + days + activities + targets + rules
  → Present editable review screen to user
  → User confirms → save to SwiftData/CloudKit
```

**Claude API details:**
- Endpoint: Anthropic Messages API `/v1/messages`
- Model: `claude-sonnet-4-20250514`
- Only called during program creation, never during workouts
- System prompt must define the exact JSON schema matching ActivityTarget model
- Response includes optional `clarifications` array for ambiguous inputs
- API key: bundled for dev, proxy for App Store release
- Error handling: network failure → retry option; parse failure → manual fallback

**Defaults when not specified:**
- Rest between sets: 60s (90s for heavy compounds)
- Weight unit: user's preference from Settings
- Progression: none unless explicitly stated

**Manual program creation** is also available via form-based UI for users who prefer to build programs directly.

### Active Workout Session

#### Session Flow

```
Start Workout
  → Load today's ProgramDay (based on schedule + last session)
  → Cato announces first exercise
  → LOOP:
      → User does set
      → User reports reps (voice OR tap)
      → Cato logs set, confirms
      → If more sets: start rest timer → countdown → resume
      → If last set: move to next activity
  → All activities done → Cato summarizes session
  → Progression engine runs
```

#### Input Methods — Voice and Manual Are Co-Equal

Users can complete an entire workout without speaking. Every voice command has a tap equivalent. Both work simultaneously — no mode switching needed.

| Action | Voice | Tap |
|--------|-------|-----|
| Log reps | "Got 5" / "Done" / just the number | Tap [1] [2] [3] [4] [5] [+] buttons |
| Log failure | "Only got 3" | Tap [3] — app detects below target |
| Skip exercise | "Skip" | [ Skip Exercise ] button |
| Next exercise | "Next" | [ Next ] button or swipe |
| Adjust weight | "Use 195" / "Add 10 pounds" | Tap weight display → number input |
| Pause | "Pause" | Tap pause icon |
| Resume | "Resume" | Tap resume |
| What's next | "What's next?" | Visible on rest screen |
| End workout | "End workout" | [ End Workout ] button |
| Skip rest | — | [ Skip Rest ] button |

**Voice-off mode:** Toggled in Settings → Voice. When off, Cato doesn't listen or speak. Rest cues are visual + optional haptic/sound. This is a first-class experience, not degraded.

#### Voice Engine Details

**Speech recognition (SFSpeechRecognizer):**
- On-device only: `requiresOnDeviceRecognition = true`
- Locale: `en-US`
- Restart recognition task every 60 seconds (Apple limitation)
- Smart listening: pause during rest timers, resume 5 sec before rest ends
- Handle interruptions (calls, Siri) gracefully

**Text-to-speech (AVSpeechSynthesizer):**
- Audio session: `.playback` with `.duckOthers` (plays over music at reduced volume)
- Rate adjustable in Settings
- All spoken text comes from `CatoPersona.swift`

**Battery:** ~10-15% per hour of active listening. Smart pausing cuts this significantly.

#### Session UI

**During a set:**
```
┌─────────────────────────────────┐
│ Barbell Bench Press             │
│ Set 3 of 5                      │
│                                 │
│         185 lbs                 │  ← Tappable to override weight
│        Target: 5 reps           │
│                                 │
│   ┌─────────────────────────┐   │
│   │  🎤 Cato is listening   │   │  ← Hidden when voice off
│   └─────────────────────────┘   │
│                                 │
│   [1] [2] [3] [4] [5] [+]      │  ← Always visible
│                                 │
│   [ Skip Exercise ]            │
└─────────────────────────────────┘
```

**During rest:**
```
┌─────────────────────────────────┐
│ Rest                            │
│                                 │
│           0:42                  │
│                                 │
│ Next: Barbell Squat             │
│ 5 x 5 @ 225 lbs                │
│                                 │
│   [ Skip Rest ]                │
└─────────────────────────────────┘
```

### Progression Engine

Runs after each completed session.

**Algorithm per activity:**
1. Get applicable ProgressionRule (activity override or program default)
2. Evaluate condition against completed sets
3. Condition met → calculate new target → apply to next occurrence → log event → announce
4. Condition not met → increment failure count → check deload threshold
5. Deload triggered → reduce target → hold for N sessions → log event → announce

**Three progression types (v1):**

| Type | Example | Calculation |
|------|---------|-------------|
| Percentage | +10% if all reps hit | `newWeight = weight × 1.10`, rounded to nearest 2.5 lbs / 1.25 kg |
| Fixed increment | +5 lbs each session | `newWeight = weight + 5` |
| Rep increase | +1 rep/set each week | `newReps = reps + 1`, with optional ceiling + weight bump |

**Frequencies:** per session, per week, per cycle.

**Deload:** After N consecutive failures, reduce target by X% for M sessions, then resume progression from deloaded value.

**Every decision logged as a `ProgressionEvent`** — visible in session summary, history, and per-activity views.

### Apple Watch & HealthKit

**Read access requested for:**
- Heart rate
- Active energy burned
- Basal energy burned
- Workout data

**During session:**
1. Start `HKWorkoutSession` if Watch connected
2. Observe HR via `HKAnchoredObjectQuery`
3. At session end: aggregate avg/max/min HR, active + total calories
4. Store in `SessionHealthMetrics`

**No Watch:** Session works normally. `healthMetrics` is nil. Cato omits health data from summary. No errors.

**v1 is read-only.** Cato does not write workouts back to HealthKit.

### History & Progress Tracking

**Log view (v1):** Chronological list of sessions.

Each session card shows: date, program/day name, duration, exercise count, set count, HR, calories, progression flags.

**Drill-down:** Every exercise with all sets (target vs actual), failure flags, health metrics, progression events, notes, Cato's summary line.

**Per-activity history:** All instances of a specific exercise across all sessions. Shows weight/reps over time with progression markers.

**Charts/graphs are post-v1.** Data model supports them.

### Multiple Programs

- One active at a time — determines what "Start Workout" loads
- Create via NL, URL, or manual builder
- Edit, duplicate, archive (soft-delete), or delete (permanent, with confirmation)
- Switching programs preserves all history
- History entries always reference their source program

---

## Navigation

Four tabs:

| Tab | Purpose | Key Elements |
|-----|---------|-------------|
| Today | Home — today's workout | Cato greeting, workout card, "Start Workout" button, streak |
| Programs | Manage programs | Program list, create new, detail/edit |
| History | Workout log | Session list, filters, drill-down to detail |
| Settings | Preferences | Units, voice toggle, TTS speed, HealthKit, account |

---

## CloudKit Schema

All in user's private database.

| Record Type | Key Relationships | Indexes |
|-------------|-------------------|---------|
| WorkoutProgram | — | isActive, createdAt |
| ProgramWeek | → WorkoutProgram | programRef |
| ProgramDay | → ProgramWeek | weekRef, dayOfWeek |
| ProgramActivity | → ProgramDay | dayRef |
| ActivityTarget | → ProgramActivity | activityRef |
| ProgressionRule | → WorkoutProgram, → ProgramActivity (optional) | programRef |
| WorkoutSession | → WorkoutProgram, → ProgramDay | programRef, date |
| CompletedActivity | → WorkoutSession, → ProgramActivity | sessionRef |
| CompletedSet | → CompletedActivity | activityRef |
| CompletedTarget | → CompletedActivity | activityRef |
| SessionHealthMetrics | → WorkoutSession | sessionRef |
| ProgressionEvent | → WorkoutSession | activityName, date |

---

## Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Launch to interactive | < 2 seconds |
| Voice command to response | < 500ms |
| CloudKit sync | Background, non-blocking |
| Session start | < 1 second |
| Offline | Full session tracking works. Syncs when online. NL parsing needs network. |
| Privacy | No data outside CloudKit. HealthKit on-device only. Speech on-device only. Claude API gets workout text only. |
| Accessibility | VoiceOver, Dynamic Type, high contrast. All voice commands have tap equivalents. |

---

## Future Considerations (Out of v1 Scope)

These are NOT to be implemented but should not be blocked by architectural decisions:

1. **Cardio / running** — data model ready via ActivityType + TargetMetric. Needs UI + GPS.
2. **Apple Watch companion app** — log sets from the wrist.
3. **Write to HealthKit** — save workouts to Apple Health.
4. **Social / sharing** — share programs via CloudKit public DB.
5. **Exercise video library** — form guides.
6. **Warm-up / cool-down sets** — non-working sets.
7. **Supersets / circuits** — grouped activities.
8. **Custom exercises** — user-defined beyond seed DB.
9. **Export** — CSV / PDF history.
10. **Notifications** — "Cato: Push Day tomorrow."
11. **Siri Shortcuts** — "Tell Cato to start my workout."
12. **Charts** — weight/volume/HR/pace graphs over time.
13. **iPad / Mac** — expanded layouts.
14. **Monetization** — subscriptions, StoreKit 2.
15. **Persona customization** — adjust Cato's coaching style.
16. **Multi-language** — Cato speaks user's language.
