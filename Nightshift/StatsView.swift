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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(card, in: RoundedRectangle(cornerRadius: 16))
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(1...12, id: \.self) { month in
                            NavigationLink {
                                MonthStatsView(year: year, month: month)
                            } label: {
                                MonthTile(year: year, month: month)
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

struct MonthTile: View {
    @Environment(Store.self) private var store
    @Environment(\.accent) private var accent
    let year: Int
    let month: Int

    var body: some View {
        let current = calendar.isDate(day(year, month, 1), equalTo: .now, toGranularity: .month)
        let minutes = store.stats(from: day(year, month, 1), to: lastDay(year, month)).minutes
        VStack(spacing: 4) {
            Text(monthName(month))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(current ? accent : Color.primary)
            Text(hours(minutes))
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(card, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(accent, lineWidth: current ? 1.5 : 0)
        }
    }
}

struct SummaryCard: View {
    @Environment(Store.self) private var store
    let stats: Stats

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 16) {
                    total("Stunden gearbeitet", stats.minutes)
                    total("Überstunden gemacht", stats.overtime)
                }
                Label(String(stats.vacationDays) + (stats.vacationDays == 1 ? " Tag Urlaub" : " Tage Urlaub"), systemImage: "sun.max.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.5), in: Capsule())
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(LinearGradient(colors: [turquoiseLight, turquoise], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 10) {
                ForEach(store.shiftTypes) { shift in
                    let count = stats.counts[shift.id] ?? 0
                    HStack {
                        Circle()
                            .fill(shift.tint)
                            .frame(width: 12, height: 12)
                        Text(shift.name.isEmpty ? shift.id : shift.id + " (" + shift.name + ")")
                        Spacer()
                        Text(String(count) + "×")
                            .foregroundStyle(Color.secondary)
                        Text(shift.start == nil ? "" : hours(count * shift.minutes))
                            .fontWeight(.medium)
                            .frame(width: 84, alignment: .trailing)
                    }
                    .font(.subheadline)
                    .opacity(count == 0 ? 0.45 : 1)
                }
            }
            .padding(18)
            .background(card)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func total(_ label: String, _ minutes: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .opacity(0.7)
            Text(hours(minutes))
                .font(.system(size: 40, weight: .bold, design: .rounded))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    @Environment(\.accent) private var accent
    let week: [Date?]

    var body: some View {
        let days = week.compactMap { $0 }
        let stats = store.stats(from: days[0], to: days[days.count - 1])
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("KW " + String(weekNumber(week)))
                    .font(.headline)
                    .foregroundStyle(accent)
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
        .background(card, in: RoundedRectangle(cornerRadius: 16))
    }
}
