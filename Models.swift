import Foundation

struct WorkoutSet: Identifiable, Codable {
    var id = UUID()
    var weightKg: Double?
    var reps: Int?
}

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var prescription: String
    var sets: [WorkoutSet]
    var note: String = ""
}

struct WorkoutSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var day: String
    var week: Int
    var exercises: [Exercise]
    var leftShoulder: Int?
    var rightShoulder: Int?
    var lowerBack: Int?
    var energy: Int?
    var notes: String
}

struct BodyMetrics: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var weightKg: Double?
    var waistCm: Double?
}

enum TrainingPlan {
    static let days: [(key: String, title: String, exercises: [(String, String, Int, Double?)])] = [
        ("A", "Понедельник · A", [
            ("Подтягивания в гравитроне", "8–10", 3, 40),
            ("Горизонтальная тяга блока", "10–12", 3, nil),
            ("Жим штанги лёжа", "8–10", 3, 65),
            ("Сведение рук в тренажёре", "12–15", 2, nil),
            ("Dead Bug", "8 на сторону", 2, nil)
        ]),
        ("B", "Среда · B", [
            ("Гакк-присед", "10–12", 3, nil),
            ("Сгибание ног в тренажёре", "12–15", 3, nil),
            ("Разгибание ног в тренажёре", "12–15", 2, nil),
            ("Ягодичный мост", "10–12", 2, nil),
            ("Bird Dog", "8 на сторону", 2, nil),
            ("Подъёмы на носки", "12–15", 3, nil)
        ]),
        ("C", "Пятница · C", [
            ("Тяга верхнего блока", "10–12", 3, nil),
            ("Разведение рук в стороны", "12–15", 2, nil),
            ("Горизонтальная тяга блока", "10–12", 2, nil),
            ("Сгибание рук на бицепс", "10–12", 2, nil),
            ("Разгибание рук на блоке", "10–12", 2, nil),
            ("Боковая планка", "15–25 сек/сторона", 2, nil)
        ])
    ]

    static func makeExercises(for key: String) -> [Exercise] {
        let day = days.first { $0.key == key } ?? days[0]
        return day.exercises.map { item in
            Exercise(name: item.0, prescription: item.1,
                     sets: (0..<item.2).map { index in
                         WorkoutSet(weightKg: index == 0 ? item.3 : nil, reps: nil)
                     })
        }
    }
}
