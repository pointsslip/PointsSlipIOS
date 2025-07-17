import SwiftUI

struct ContentView: View {
    @State private var counts: [Int] = Array(repeating: 0, count: 20)
    @State private var countStrings: [String] = Array(repeating: "0", count: 20)

    let labels: [String] = [
        "Pages Read (10 points per page):",
        "Videos/Live or Recorded Lectures/Teacher Instruction (5 points per minute):",
        "Passing a Theory Checkout (3 points per page):",
        "Giving a Theory Checkout (when passed, 3 points per page):",
        "Finding MUs (5 points per word):",
        "Giving a Checkout on a Demo (3 points):",
        "For Each Definition, Derivation, Idiom or Synonym Fully Cleared (3 points):",
        "Giving/Receiving Word Clearing (150 points per hour):",
        "Theory Coaching - Student and Coach (5 points per line):",
        "Any drill that takes 15 minutes or less. (40 points):",
        "Verbatim Learning (10 points per line):",
        "Any Practical, Drill, or Demonstration that takes more than 15 mins to do. (150 points per hour):",
        "Completing a practical, drill, or demonstration that takes more than 1 hour. (500 points):",
        "Checksheet Requirement (5 points):",
        "Self-Originated (3 points):",
        "Clay Demo (50 points):",
        "Essays, Charts, Diagrams (10 points):",
        "Course Completions (2000 points):",
        "(For each day ahead of target, 2000 points):",
        "Points for each day you are overdue on a course (-200 points):"
    ]

    let pointsPerUnit: [Int] = [
        10, 5, 3, 3, 5, 3, 3, 150, 5, 40,
        10, 150, 500, 5, 3, 50, 10, 2000, 2000, -200
    ]

    init() {
        let today = Self.currentDayString()
        let lastSavedDay = UserDefaults.standard.string(forKey: "lastSavedDay")
        if lastSavedDay == today,
           let saved = UserDefaults.standard.array(forKey: "counts") as? [Int], saved.count == 20 {
            _counts = State(initialValue: saved)
            _countStrings = State(initialValue: saved.map { String($0) })
        } else {
            UserDefaults.standard.set(today, forKey: "lastSavedDay")
            UserDefaults.standard.set(Array(repeating: 0, count: 20), forKey: "counts")
            _counts = State(initialValue: Array(repeating: 0, count: 20))
            _countStrings = State(initialValue: Array(repeating: "0", count: 20))
        }
    }

    static func currentDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func saveCounts() {
        UserDefaults.standard.set(counts, forKey: "counts")
        UserDefaults.standard.set(Self.currentDayString(), forKey: "lastSavedDay")
    }

    func resetCounts() {
        counts = Array(repeating: 0, count: 20)
        countStrings = Array(repeating: "0", count: 20)
        saveCounts()
    }

    var totalPoints: Int {
        zip(counts, pointsPerUnit).map { $0 * $1 }.reduce(0, +)
    }

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.05
            let verticalSpacing = geometry.size.height * 0.02

            VStack(spacing: verticalSpacing) {
                Text("Digital Points Slip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, verticalSpacing)
                ScrollView {
                    VStack(spacing: verticalSpacing) {
                        ForEach(0..<labels.count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: verticalSpacing / 2) {
                                HStack(alignment: .center) {
                                    Text(labels[index])
                                        .font(.body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    TextField(
                                        "",
                                        text: Binding(
                                            get: { countStrings[index] },
                                            set: { newValue in
                                                let filtered = newValue.filter { "0123456789".contains($0) }
                                                countStrings[index] = filtered
                                                counts[index] = Int(filtered) ?? 0
                                                saveCounts()
                                            }
                                        )
                                    )
                                    .frame(width: 60, alignment: .trailing)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    Stepper(
                                        value: Binding(
                                            get: { counts[index] },
                                            set: { newValue in
                                                counts[index] = newValue
                                                countStrings[index] = String(newValue)
                                                saveCounts()
                                            }
                                        ),
                                        in: 0...10000
                                    ) {
                                        EmptyView()
                                    }
                                }
                                .padding(.vertical, verticalSpacing / 2)
                                if index == 0 {
                                    Text("Bonus Points for Pages Read in One Day automatically included. (25 points per 50 pages)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                Spacer()
                Divider()
                HStack {
                    Button(action: resetCounts) {
                        Text("Reset")
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    Spacer()
                    Text("Points:")
                        .fontWeight(.bold)
                    Text("\(totalPoints)")
                        .fontWeight(.bold)
                }
                .padding(.top, verticalSpacing)
                Text("Made with ❤️ and Open Source by Ari Cummings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, verticalSpacing / 2)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalSpacing)
        }
    }
}

#Preview {
    ContentView()
}
