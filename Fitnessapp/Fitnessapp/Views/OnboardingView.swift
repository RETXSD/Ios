import SwiftUI

struct OnboardingView: View {
    let username: String
    let email: String
    let isSaving: Bool
    let onComplete: (UserFitnessProfile) -> Void

    @State private var userId = ""
    @State private var calorieTarget = ""
    @State private var workoutDuration = ""
    @State private var weightKg = ""
    @State private var age = ""
    @State private var fitnessLevel: FitnessLevelOption = .beginner

    init(
        profile: UserFitnessProfile,
        isSaving: Bool,
        onComplete: @escaping (UserFitnessProfile) -> Void
    ) {
        self.username = profile.username
        self.email = profile.email
        self.isSaving = isSaving
        self.onComplete = onComplete
        _userId = State(initialValue: profile.userId)
        _fitnessLevel = State(initialValue: FitnessLevelOption(fitnessLevel: profile.fitnessLevel))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    OnboardingHeaderView(username: username)

                    FitnessCard {
                        VStack(spacing: 16) {
                            LabeledContent("Email", value: email.isEmpty ? "Not set" : email)
                                .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                            onboardingTextField(
                                title: "Daily calorie target",
                                placeholder: "Example: 500",
                                text: $calorieTarget,
                                keyboardType: .numberPad,
                                unit: "kcal"
                            )

                            onboardingTextField(
                                title: "Workout duration",
                                placeholder: "Example: 30",
                                text: $workoutDuration,
                                keyboardType: .numberPad,
                                unit: "min"
                            )

                            onboardingTextField(
                                title: "Current weight",
                                placeholder: "Example: 70",
                                text: $weightKg,
                                keyboardType: .decimalPad,
                                unit: "kg"
                            )

                            onboardingTextField(
                                title: "Age",
                                placeholder: "Example: 20",
                                text: $age,
                                keyboardType: .numberPad,
                                unit: "years"
                            )

                            Picker("Fitness level", selection: $fitnessLevel) {
                                ForEach(FitnessLevelOption.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)

                            if !isFormValid {
                                Text("Fill all fields with valid numbers to save your profile.")
                                    .font(.caption)
                                    .foregroundStyle(FitnessTheme.textMuted)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    Button(action: submit) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(FitnessTheme.ink)
                            }

                            Label("Save Profile", systemImage: "checkmark.circle.fill")
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(FitnessPrimaryButtonStyle())
                    .disabled(isSaving || !isFormValid)
                }
                .padding()
            }
            .background { FitnessTheme.pageBackground }
            .navigationTitle("Setup")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var parsedCalorieTarget: Int? {
        positiveInt(from: calorieTarget)
    }

    private var parsedWorkoutDuration: Int? {
        positiveInt(from: workoutDuration)
    }

    private var parsedWeightKg: Double? {
        positiveDouble(from: weightKg)
    }

    private var parsedAge: Int? {
        positiveInt(from: age)
    }

    private var isFormValid: Bool {
        parsedCalorieTarget != nil &&
            parsedWorkoutDuration != nil &&
            parsedWeightKg != nil &&
            parsedAge != nil
    }

    private func submit() {
        guard
            let parsedCalorieTarget,
            let parsedWorkoutDuration,
            let parsedWeightKg,
            let parsedAge
        else {
            return
        }

        onComplete(
            UserFitnessProfile(
                userId: userId,
                username: username,
                email: email,
                dailyCalorieTarget: parsedCalorieTarget,
                dailyWorkoutDurationMinutes: parsedWorkoutDuration,
                weightKg: parsedWeightKg,
                age: parsedAge,
                fitnessLevel: fitnessLevel.firebaseLevel,
                onboardingCompleted: true,
                createdAt: nil,
                updatedAt: nil
            )
        )
    }

    private func onboardingTextField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FitnessTheme.text)

            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(FitnessTheme.textMuted.opacity(0.78))
                    }

                    TextField("", text: text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(FitnessTheme.text)
                        .tint(FitnessTheme.primary)
                        .accessibilityLabel(title)
                }

                Text(unit)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FitnessTheme.primary)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 54)
            .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
            .overlay {
                RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                    .stroke(FitnessTheme.border, lineWidth: 1)
            }
        }
    }

    private func positiveInt(from text: String) -> Int? {
        guard let value = Int(text.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 else {
            return nil
        }

        return value
    }

    private func positiveDouble(from text: String) -> Double? {
        let normalizedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let value = Double(normalizedText), value > 0 else {
            return nil
        }

        return value
    }
}

private extension FitnessLevelOption {
    init(fitnessLevel: FitnessLevel) {
        switch fitnessLevel {
        case .beginner:
            self = .beginner
        case .intermediate:
            self = .intermediate
        case .advanced:
            self = .advanced
        }
    }

    var firebaseLevel: FitnessLevel {
        switch self {
        case .beginner:
            return .beginner
        case .intermediate:
            return .intermediate
        case .advanced:
            return .advanced
        }
    }
}
