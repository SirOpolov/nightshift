import SwiftUI

struct MonthGrid: View {
    @Environment(Store.self) private var store
    @Environment(\.accent) private var accent
    let year: Int
    let month: Int
    var compact = false
    var selected: Date?
    var overtimeDay: Binding<Date?> = .constant(nil)
    var tap: (Date) -> Void = { _ in }

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            GridRow {
                Text("KW")
                    .foregroundStyle(Color.secondary)
                    .frame(width: 26)
                ForEach(weekdays, id: \.self) { name in
                    Text(name)
                        .foregroundStyle(name == "Sa" || name == "So" ? accent : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.caption.weight(.medium))
            ForEach(weeks(year: year, month: month), id: \.self) { week in
                GridRow {
                    Text(String(weekNumber(week)))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(accent)
                        .frame(width: 26)
                    ForEach(0..<7, id: \.self) { index in
                        if let date = week[index] {
                            DayCell(date: date, shift: store.shift(on: date), overtime: store.overtimeMinutes(on: date), selected: date == selected, compact: compact)
                                .frame(height: compact ? 52 : nil)
                                .onTapGesture {
                                    tap(date)
                                }
                                .popover(isPresented: popover(date)) {
                                    OvertimeForm(date: date)
                                        .frame(minWidth: 300, minHeight: 260)
                                        .presentationCompactAdaptation(.popover)
                                }
                        } else {
                            Color.clear
                                .frame(height: compact ? 52 : nil)
                        }
                    }
                }
            }
        }
    }

    private func popover(_ date: Date) -> Binding<Bool> {
        Binding {
            overtimeDay.wrappedValue == date
        } set: { shown in
            if !shown {
                overtimeDay.wrappedValue = nil
            }
        }
    }
}

struct DayCell: View {
    @Environment(\.accent) private var accent
    let date: Date
    let shift: ShiftType?
    let overtime: Int
    let selected: Bool
    let compact: Bool

    var body: some View {
        let today = calendar.isDateInToday(date)
        VStack(spacing: 2) {
            Text(String(calendar.component(.day, from: date)))
                .font(.subheadline.weight(today ? .heavy : .regular))
            if let shift {
                Text(shift.id)
                    .font(.caption.weight(.semibold))
                Text(shift.name)
                    .font(.caption2)
                if !compact {
                    Text(shift.cellTime)
                        .font(.system(size: 9))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            if overtime > 0 {
                Text("+" + hours(overtime))
                    .font(.system(size: 9, weight: .bold))
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(shift != nil ? Color.black : today ? accent : Color.primary)
        .padding(.vertical, 6)
        .padding(.horizontal, 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(shift?.tint ?? card, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(selected ? Color.primary : accent, lineWidth: selected ? 3 : today ? 2 : 0)
        }
    }
}

struct MiniMonth: View {
    @Environment(Store.self) private var store
    @Environment(\.accent) private var accent
    let year: Int
    let month: Int

    var body: some View {
        let rows = weeks(year: year, month: month)
        let current = calendar.isDate(day(year, month, 1), equalTo: .now, toGranularity: .month)
        VStack(alignment: .leading, spacing: 3) {
            Text(monthName(month))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(current ? accent : Color.primary)
                .lineLimit(1)
                .padding(.bottom, 2)
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color(row < rows.count ? rows[row][index] : nil))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(10)
        .background(card, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(accent, lineWidth: current ? 1.5 : 0)
        }
    }

    private func color(_ date: Date?) -> Color {
        guard let date else { return .clear }
        return store.shift(on: date)?.tint ?? Color.primary.opacity(0.12)
    }
}
