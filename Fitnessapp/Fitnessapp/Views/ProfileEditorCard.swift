import SwiftUI

struct ProfileEditorCard: View {
    let profile: UserFitnessProfile
    let isSaving: Bool
    let saveAction: (UserFitnessProfile) -> Void

    @State private var dailyCalorieTarget: Int
    @State private var workoutDuration: Int
    @State private var weightKg: Double
    @State private var age: Int
    @State private var fitnessLevel: FitnessLevel

    init(
        profile: UserFitnessProfile,
        isSaving: Bool,
        saveAction: @escaping (UserFitnessProfile) -> Void
    ) {
        self.profile = profile
        self.isSaving = isSaving
        self.saveAction = saveAction
        _dailyCalorieTarget = State(initialValue: profile.dailyCalorieTarget)
        _workoutDuration = State(initialValue: profile.dailyWorkoutDurationMinutes)
        _weightKg = State(initialValue: profile.weightKg)
        _age = State(initialValue: profile.age)
        _fitnessLevel = State(initialValue: profile.fitnessLevel)
    }

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Fitness Profile", systemImage: "slider.horizontal.3")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                VStack(spacing: 12) {
                    profileNumberField("Daily calorie target", value: $dailyCalorieTarget, suffix: "kcal")
                    profileNumberField("Workout duration", value: $workoutDuration, suffix: "min")
                    profileDoubleField("Current weight", value: $weightKg, suffix: "kg")
                    profileNumberField("Age", value: $age, suffix: "years")

                    Picker("Fitness level", selection: $fitnessLevel) {
                        ForEach(FitnessLevel.allCases, id: \.rawValue) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .colorScheme(.dark)
                    .tint(FitnessTheme.primary)
                }

                Button(action: save) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .tint(FitnessTheme.ink)
                        }

                        Label("Update Profile", systemImage: "checkmark.circle.fill")
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(FitnessTheme.primary)
                .disabled(isSaving)
            }
        }
    }

    private func profileNumberField(_ title: String, value: Binding<Int>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FitnessTheme.textMuted)

            HStack {
                TextField(title, value: value, format: .number)
                    .keyboardType(.numberPad)
                    .foregroundStyle(FitnessTheme.text)
                    .tint(FitnessTheme.primary)

                Text(suffix)
                    .foregroundStyle(FitnessTheme.textMuted)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 48)
            .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
            .overlay {
                RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                    .stroke(FitnessTheme.border, lineWidth: 1)
            }
        }
    }

    private func profileDoubleField(_ title: String, value: Binding<Double>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FitnessTheme.textMuted)

            HStack {
                TextField(title, value: value, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .foregroundStyle(FitnessTheme.text)
                    .tint(FitnessTheme.primary)

                Text(suffix)
                    .foregroundStyle(FitnessTheme.textMuted)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 48)
            .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
            .overlay {
                RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                    .stroke(FitnessTheme.border, lineWidth: 1)
            }
        }
    }

    private func save() {
        saveAction(
            UserFitnessProfile(
                userId: profile.userId,
                username: profile.username,
                email: profile.email,
                dailyCalorieTarget: max(1, dailyCalorieTarget),
                dailyWorkoutDurationMinutes: max(1, workoutDuration),
                weightKg: max(1, weightKg),
                age: max(1, age),
                fitnessLevel: fitnessLevel,
                onboardingCompleted: true,
                createdAt: profile.createdAt,
                updatedAt: profile.updatedAt
            )
        )
    }
}
