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

    func freeDays(_ stats: Stats) -> Int {
        shifts.filter { $0.start == nil && !$0.vacation }.reduce(0) { $0 + (stats.counts[$1.id] ?? 0) }
    }

    func average(_ stats: Stats) -> String {
        let days = workDays(stats)
        return days == 0 ? "–" : hours(stats.minutes / days)
    }

    func count(_ value: Int) -> String {
        value == 0 ? "–" : String(value)
    }

    func time(_ minutes: Int) -> String {
        minutes == 0 ? "–" : hours(minutes)
    }
}

@MainActor
func renderReport(_ report: YearReport, accent: Color) -> URL? {
    let url = URL.temporaryDirectory.appending(path: "Nightshift Auswertung " + String(report.year) + ".pdf")
    var box = CGRect(x: 0, y: 0, width: 595, height: 842)
    guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return nil }
    for page in [AnyView(OverviewPage(report: report)), AnyView(ShiftsPage(report: report))] {
        let renderer = ImageRenderer(content: page
            .environment(\.accent, accent)
            .environment(\.colorScheme, .light)
            .frame(width: 595, height: 842))
        renderer.render { _, draw in
            context.beginPDFPage(nil)
            draw(context)
            context.endPDFPage()
        }
    }
    context.closePDF()
    return url
}

struct OverviewPage: View {
    let report: YearReport

    var body: some View {
        ReportPage(year: report.year, title: "Jahresübersicht", number: 1) {
            HStack(spacing: 10) {
                Kpi(label: "Stunden gearbeitet", value: hours(report.total.minutes))
                Kpi(label: "Arbeitstage", value: String(report.workDays(report.total)))
                Kpi(label: "Urlaubstage", value: String(report.total.vacationDays))
                Kpi(label: "Ø pro Arbeitstag", value: report.average(report.total))
            }
            if report.year >= calendar.component(.year, from: .now) {
                Text("Stand " + today + ": Tage nach heute sind noch nicht enthalten.")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Stunden pro Monat")
                    .font(.system(size: 13, weight: .semibold))
                MonthChart(minutes: report.months.map(\.minutes))
            }
            ReportTable(
                title: "Monatsübersicht",
                widths: [115, 75, 65, 60, 90, 90],
                header: ["Monat", "Arbeitstage", "Urlaub", "Frei", "Stunden", "Ø / Tag"],
                rows: (0..<12).map { index in
                    let stats = report.months[index]
                    return [
                        monthName(index + 1),
                        report.count(report.workDays(stats)),
                        report.count(stats.vacationDays),
                        report.count(report.freeDays(stats)),
                        report.time(stats.minutes),
                        report.average(stats),
                    ]
                },
                total: [
                    "Gesamt",
                    String(report.workDays(report.total)),
                    String(report.total.vacationDays),
                    String(report.freeDays(report.total)),
                    hours(report.total.minutes),
                    report.average(report.total),
                ]
            )
        }
    }
}

struct ShiftsPage: View {
    let report: YearReport

    var body: some View {
        let shifts = report.shifts
        let width = (495 - 160) / CGFloat(max(shifts.count, 1))
        ReportPage(year: report.year, title: "Schichten", number: 2) {
            ReportTable(
                title: "Schichten im Jahr",
                widths: [90, 105, 100, 70, 55, 75],
                leading: 3,
                header: ["Schicht", "Beschreibung", "Zeit", "Netto", "Anzahl", "Stunden"],
                rows: shifts.map { shift in
                    let number = report.total.counts[shift.id] ?? 0
                    return [
                        shift.id,
                        shift.name.isEmpty ? "–" : shift.name,
                        shift.time.isEmpty ? "–" : shift.time,
                        shift.start == nil ? "–" : hours(shift.minutes),
                        report.count(number),
                        report.time(number * shift.minutes),
                    ]
                },
                dots: shifts.map(\.tint),
                total: ["Gesamt", "", "", "", String(report.total.counts.values.reduce(0, +)), hours(report.total.minutes)]
            )
            ReportTable(
                title: "Schichten pro Monat",
                widths: [80] + Array(repeating: width, count: shifts.count) + [80],
                header: ["Monat"] + shifts.map(\.id) + ["Stunden"],
                headerDots: [nil] + shifts.map { $0.tint as Color? } + [nil],
                rows: (0..<12).map { index in
                    let stats = report.months[index]
                    return [monthName(index + 1)] + shifts.map { report.count(stats.counts[$0.id] ?? 0) } + [report.time(stats.minutes)]
                },
                total: ["Gesamt"] + shifts.map { String(report.total.counts[$0.id] ?? 0) } + [hours(report.total.minutes)]
            )
        }
    }
}

struct ReportPage<Content: View>: View {
    @Environment(\.accent) private var accent
    let year: Int
    let title: String
    let number: Int
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NIGHTSHIFT · AUSWERTUNG " + String(year))
                        .font(.system(size: 9, weight: .bold))
                        .kerning(1.2)
                        .foregroundStyle(accent)
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                }
                Spacer()
                Text("Erstellt am " + today)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Rectangle()
                .fill(accent)
                .frame(height: 2)
            content
            Spacer(minLength: 0)
            HStack {
                Text("Pro Arbeitstag werden 30 Minuten Pause abgezogen. Urlaub und Frei zählen 0 Stunden.")
                Spacer()
                Text("Seite " + String(number) + " von 2")
            }
            .font(.system(size: 8))
            .foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(width: 595, height: 842, alignment: .topLeading)
        .foregroundStyle(.black)
        .fontDesign(.rounded)
        .background(.white)
    }
}

struct Kpi: View {
    @Environment(\.accent) private var accent
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct MonthChart: View {
    @Environment(\.accent) private var accent
    let minutes: [Int]

    var body: some View {
        let top = CGFloat(max(minutes.max() ?? 0, 1))
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<12, id: \.self) { index in
                VStack(spacing: 3) {
                    Text(minutes[index] == 0 ? " " : String(minutes[index] / 60) + " h")
                        .font(.system(size: 7, weight: .medium))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(minutes[index] == 0 ? accent.opacity(0.2) : accent)
                        .frame(height: max(2, 90 * CGFloat(minutes[index]) / top))
                    Text(calendar.shortStandaloneMonthSymbols[index])
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 125, alignment: .bottom)
    }
}

struct ReportTable: View {
    @Environment(\.accent) private var accent
    let title: String
    let widths: [CGFloat]
    var leading = 1
    let header: [String]
    var headerDots: [Color?] = []
    let rows: [[String]]
    var dots: [Color?] = []
    let total: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
            VStack(spacing: 0) {
                line(header, dots: headerDots)
                    .font(.system(size: 8, weight: .bold))
                    .textCase(.uppercase)
                    .background(accent.opacity(0.18))
                ForEach(rows.indices, id: \.self) { index in
                    line(rows[index], dots: [index < dots.count ? dots[index] : nil])
                        .font(.system(size: 9.5))
                        .background(index % 2 == 1 ? Color.black.opacity(0.035) : Color.clear)
                }
                line(total, dots: [])
                    .font(.system(size: 9.5, weight: .bold))
                    .background(accent.opacity(0.18))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.black.opacity(0.12), lineWidth: 0.5)
            }
        }
    }

    private func line(_ cells: [String], dots: [Color?]) -> some View {
        HStack(spacing: 0) {
            ForEach(cells.indices, id: \.self) { index in
                HStack(spacing: 5) {
                    if index < dots.count, let dot = dots[index] {
                        Circle()
                            .fill(dot)
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                            .frame(width: 7, height: 7)
                    }
                    Text(cells[index])
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(width: widths[index], alignment: index < leading ? .leading : .trailing)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

private var today: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: .now)
}
