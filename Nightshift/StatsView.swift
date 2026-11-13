import SwiftUI

struct StatsView: View {
    @Environment(Store.self) private var store
    @State private var year = calendar.component(.year, from: .now)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SummaryCard(stats: store.stats(from: day(year, 1, 1), to: day(year, 12, 31)))
                    HStack {
                        Text("Jahr")
                            .font(.headline)
                        Spacer()
                        Picker("Jahr", selection: $year) {
                            ForEach(years, id: \.self) { value in
                                Text(String(value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(1...12, id: \.self) { month in
                            NavigationLink {
                                MonthStatsView(year: year, month: month)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(monthName(month))
                                        .font(.subheadline.weight(.semibold))
                                    Text(hours(store.stats(from: day(year, month, 1), to: lastDay(year, month)).minutes))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Auswertung")
        }
    }

    private var years: [Int] {
        let current = calendar.component(.year, from: .now)
        let used = store.entries.keys.compactMap { Int($0.prefix(4)) }
        return Set(used + [current, year]).sorted()
    }
}

struct SummaryCard: View {
    @Environment(Store.self) private var store
    let stats: Stats

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stunden gearbeitet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(hours(stats.minutes))
                .font(.largeTitle.weight(.bold))
            Text(String(stats.vacationDays) + (stats.vacationDays == 1 ? " Tag Urlaub" : " Tage Urlaub"))
                .font(.headline)
            Divider()
            ForEach(store.shiftTypes) { shift in
                let count = stats.counts[shift.id] ?? 0
                HStack {
                    Circle()
                        .fill(shift.tint)
                        .frame(width: 12, height: 12)
                    Text(shift.name.isEmpty ? shift.id : shift.id + " (" + shift.name + ")")
                    Spacer()
                    Text(String(count) + "×")
                    Text(shift.start == nil ? "" : hours(count * shift.minutes))
                        .frame(width: 84, alignment: .trailing)
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct MonthStatsView: View {
    @Environment(Store.self) private var store
    let year: Int
    let month: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SummaryCard(stats: store.stats(from: day(year, month, 1), to: lastDay(year, month)))
                MonthGrid(year: year, month: month, compact: true)
                ForEach(weeks(year: year, month: month), id: \.self) { week in
                    WeekCard(week: week)
                }
            }
            .padding(16)
        }
        .navigationTitle(monthName(month) + " " + String(year))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WeekCard: View {
    @Environment(Store.self) private var store
    let week: [Date?]

    var body: some View {
        let days = week.compactMap { $0 }
        let stats = store.stats(from: days[0], to: days[days.count - 1])
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("KW " + String(weekNumber(week)))
                    .font(.headline)
                Spacer()
                Text(hours(stats.minutes))
                    .font(.headline)
            }
            ForEach(0..<7, id: \.self) { index in
                if let date = week[index], let shift = store.shift(on: date) {
                    HStack {
                        Text(weekdays[index] + " " + String(calendar.component(.day, from: date)) + ".")
                            .frame(width: 60, alignment: .leading)
                        Text(shift.name.isEmpty ? shift.id : shift.id + " " + shift.name)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(shift.tint, in: Capsule())
                        Spacer()
                        Text(shift.start == nil ? "" : hours(shift.minutes))
                    }
                    .font(.subheadline)
                    .opacity(date > .now ? 0.5 : 1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
