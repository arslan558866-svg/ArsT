import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView().tabItem { Label("Сегодня", systemImage: "figure.strengthtraining.traditional") }
            PlanView().tabItem { Label("Программа", systemImage: "calendar") }
            ProgressViewScreen().tabItem { Label("Прогресс", systemImage: "chart.line.uptrend.xyaxis") }
            ProfileView().tabItem { Label("Профиль", systemImage: "person.crop.circle") }
        }
        .tint(.navy)
    }
}

struct TodayView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var selectedDay = "A"
    @State private var week = 1
    @State private var left = 0
    @State private var right = 0
    @State private var back = 0
    @State private var energy = 7
    @State private var notes = ""
    @State private var exercises = TrainingPlan.makeExercises(for: "A")
    @State private var showingSaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image("BearMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 190)
                        .listRowBackground(Color.navy)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("СОЗДАЙ СЕБЯ").font(.title2.bold()).foregroundStyle(Color.gold)
                        Text("Твоё тело. Твоя дисциплина. Твой результат.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section("Текущая тренировка") {
                    Picker("День", selection: $selectedDay) {
                        Text("Понедельник · A").tag("A")
                        Text("Среда · B").tag("B")
                        Text("Пятница · C").tag("C")
                    }.onChange(of: selectedDay) { _, value in
                        exercises = TrainingPlan.makeExercises(for: value)
                    }
                    Stepper("Неделя программы: \(week)", value: $week, in: 1...12)
                }
                Section("Упражнения") {
                    ForEach($exercises) { $exercise in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(exercise.name).font(.headline)
                                Spacer()
                                Text(exercise.prescription).font(.caption).foregroundStyle(.secondary)
                            }
                            ExerciseMotionCard(name: exercise.name)
                            ForEach($exercise.sets) { $set in
                                HStack {
                                    Text("Подход")
                                    Spacer()
                                    TextField("кг", value: $set.weightKg, format: .number)
                                        .keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 82)
                                    TextField("повт.", value: $set.reps, format: .number)
                                        .keyboardType(.numberPad).textFieldStyle(.roundedBorder).frame(width: 72)
                                }
                            }
                        }.padding(.vertical, 5)
                    }
                }
                Section("Самочувствие · 0–10") {
                    Stepper("Левое плечо: \(left)", value: $left, in: 0...10)
                    Stepper("Правое плечо: \(right)", value: $right, in: 0...10)
                    Stepper("Поясница: \(back)", value: $back, in: 0...10)
                    Stepper("Энергия: \(energy)", value: $energy, in: 1...10)
                    TextField("Заметки", text: $notes, axis: .vertical)
                    Button("Сохранить тренировку") {
                        let session = WorkoutSession(date: .now, day: selectedDay, week: week,
                            exercises: exercises, leftShoulder: left, rightShoulder: right,
                            lowerBack: back, energy: energy, notes: notes)
                        store.save(session)
                        showingSaved = true
                    }.disabled(max(max(left, right), back) >= 7)
                }
            }
            .navigationTitle("Мой фитнес PRO")
            .alert("Тренировка сохранена", isPresented: $showingSaved) {
                Button("Отлично", role: .cancel) {}
            } message: {
                Text("Запись добавлена в историю.")
            }
        }
    }
}

struct PlanView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(TrainingPlan.days, id: \.key) { day in
                    Section(day.title) {
                        ForEach(day.exercises, id: \.0) { item in
                            VStack(alignment: .leading) {
                                Text(item.0).font(.headline)
                                Text("\(item.2) подхода · \(item.1) повторений").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }.navigationTitle("Моя программа")
        }
    }
}

struct ProgressViewScreen: View {
    @EnvironmentObject var store: WorkoutStore
    var body: some View {
        NavigationStack {
            List {
                Section("Итоги") {
                    LabeledContent("Тренировок", value: "\(store.sessions.count)")
                    LabeledContent("Вес тела", value: store.metrics.last?.weightKg.map { String(format: "%.1f кг", $0) } ?? "Нет данных")
                    LabeledContent("Талия", value: store.metrics.last?.waistCm.map { String(format: "%.1f см", $0) } ?? "Нет данных")
                }
                Section("История") {
                    ForEach(store.sessions.reversed()) { session in
                        VStack(alignment: .leading) {
                            Text(session.date, style: .date).font(.headline)
                            Text("День \(session.day) · неделя \(session.week) · \(session.exercises.count) упражнений")
                                .font(.caption).foregroundStyle(.secondary)
                            Text("Плечи: \(session.leftShoulder ?? 0)/\(session.rightShoulder ?? 0), поясница: \(session.lowerBack ?? 0)")
                                .font(.caption2)
                        }
                    }
                }
            }.navigationTitle("Прогресс")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var weight = ""
    @State private var waist = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image("BearMascot").resizable().scaledToFill()
                            .frame(width: 76, height: 76).clipShape(RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading) {
                            Text("СОЗДАЙ СЕБЯ").font(.headline)
                            Text("Дисциплина · Сила · Прогресс").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Еженедельные показатели") {
                    TextField("Вес, кг", text: $weight).keyboardType(.decimalPad)
                    TextField("Талия, см", text: $waist).keyboardType(.decimalPad)
                    Button("Сохранить показатели") {
                        store.save(BodyMetrics(date: .now,
                            weightKg: Double(weight.replacingOccurrences(of: ",", with: ".")),
                            waistCm: Double(waist.replacingOccurrences(of: ",", with: "."))))
                        weight = ""; waist = ""
                    }
                }
                Section("Безопасность") {
                    Label("Вход через Face ID / код-пароль", systemImage: "faceid")
                    Text("Face ID не передаёт приложению биометрические данные. Проверку выполняет iOS.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("Облако") {
                    Label("CloudKit: требуется настройка контейнера и синхронизации", systemImage: "icloud")
                    Text("В этой версии данные сохраняются локально. Синхронизация iCloud ещё не подключена.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }.navigationTitle("Профиль")
        }
    }
}

struct ExerciseMotionCard: View {
    let name: String
    @State private var animate = false
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.cream).frame(width: 76, height: 64)
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 31)).foregroundStyle(Color.navy)
                    .offset(y: animate ? -4 : 4)
                    .rotationEffect(.degrees(animate ? 4 : -4))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Демонстрация движения").font(.caption.bold())
                Text("Анимированная иллюстрация-заглушка для: \(name)")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill").foregroundStyle(Color.gold)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { animate = true }
        }
    }
}
