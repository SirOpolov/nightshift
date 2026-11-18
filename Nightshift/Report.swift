import SwiftUI

struct YearReport {
    let year: Int
    let shifts: [ShiftType]
    let months: [Stats]
    let total: Stats

    init(store: Store, year: Int) {
        self.year = year
        shifts = store.shiftTypes
        months = (1...12).map { store.stats(from: day(year, $0, 1), to: lastDay(year, $0)) }
        total = store.stats(from: day(year, 1, 1), to: day(year, 12, 31))
    }

    func workDays(_ stats: Stats) -> Int {
        shifts.filter { $0.start != nil }.reduce(0) { $0 + (stats.counts[$1.id] ?? 0) }
    }
}

@MainActor
func renderReport(_ report: YearReport) -> URL? {
    let url = URL.temporaryDirectory.appending(path: String(localized: "Nightshift Report \(String(report.year))") + ".pdf")
    var box = CGRect(x: 0, y: 0, width: 595, height: 842)
    guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return nil }
    let renderer = ImageRenderer(content: ReportPage(report: report).environment(\.colorScheme, .light))
    renderer.render { _, draw in
        context.beginPDFPage(nil)
        draw(context)
        context.endPDFPage()
    }
    context.closePDF()
    return url
}

struct ReportPage: View {
    let report: YearReport

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Report \(String(report.year))")
                    .font(.system(size: 24, weight: .bold))
                Text("Created on \(today) · 30 minute break deducted per work day · Only days up to today")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.gray)
            }
            HStack(spacing: 30) {
                summary("Hours", hours(report.total.minutes))
                summary("Work days", String(report.workDays(report.total)))
                summary("Vacation days", String(report.total.vacationDays))
            }
            ReportTable(
                title: "Months",
                header: [String(localized: "Month"), String(localized: "Work days"), String(localized: "Vacation"), String(localized: "Hours")],
                rows: (0..<12).map { index in
                    let stats = report.months[index]
                    return [monthName(index + 1), String(report.workDays(stats)), String(stats.vacationDays), hours(stats.minutes)]
                },
                total: [String(localized: "Total"), String(report.workDays(report.total)), String(report.total.vacationDays), hours(report.total.minutes)]
            )
            ReportTable(
                title: "Shifts",
                header: [String(localized: "Shift"), String(localized: "Time"), String(localized: "Count"), String(localized: "Hours")],
                rows: report.shifts.map { shift in
                    let count = report.total.counts[shift.id] ?? 0
                    return [shift.label, shift.time, String(count), hours(count * shift.minutes)]
                },
                total: [String(localized: "Total"), "", String(report.total.counts.values.reduce(0, +)), hours(report.total.minutes)]
            )
            Spacer(minLength: 0)
        }
        .padding(48)
        .frame(width: 595, height: 842, alignment: .topLeading)
        .foregroundStyle(Color.black)
        .background(Color.white)
    }

    private func summary(_ label: LocalizedStringKey, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Color.gray)
            Text(value)
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

struct ReportTable: View {
    let title: LocalizedStringKey
    let header: [String]
    let rows: [[String]]
    let total: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
            VStack(spacing: 0) {
                line(header)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .background(Color(red: 0.15, green: 0.25, blue: 0.45))
                ForEach(rows.indices, id: \.self) { index in
                    line(rows[index])
                        .font(.system(size: 10))
                        .background(index % 2 == 1 ? Color(white: 0.94) : Color.white)
                }
                line(total)
                    .font(.system(size: 10, weight: .bold))
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                    }
            }
            .overlay {
                Rectangle()
                    .strokeBorder(Color(white: 0.75), lineWidth: 0.5)
            }
        }
    }

    private func line(_ cells: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(cells.indices, id: \.self) { index in
                Text(cells[index])
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : .trailing)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

private var today: String {
    Date.now.formatted(date: .numeric, time: .omitted)
}
