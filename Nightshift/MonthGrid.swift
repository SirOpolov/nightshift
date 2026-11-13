import SwiftUI

struct MonthGrid: View {
    @Environment(Store.self) private var store
    let year: Int
    let month: Int
    var compact = false
    var selected: Date?
    var tap: (Date) -> Void = { _ in }

    var body: some View {
        Grid(horizontalSpacing: 3, verticalSpacing: 3) {
            GridRow {
                Text("KW")
                    .frame(width: 26)
                ForEach(weekdays, id: \.self) { name in
                    Text(name)
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            ForEach(weeks(year: year, month: month), id: \.self) { week in
                GridRow {
                    Text(String(weekNumber(week)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 26)
                    ForEach(0..<7, id: \.self) { index in
                        if let date = week[index] {
                            DayCell(date: date, shift: store.shift(on: date), selected: date == selected)
                                .frame(height: compact ? 52 : nil)
                                .onTapGesture {
                                    tap(date)
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
}

struct DayCell: View {
    let date: Date
    let shift: ShiftType?
    let selected: Bool

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
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(shift == nil ? Color.primary : Color.black)
        .padding(.vertical, 5)
        .padding(.horizontal, 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(shift?.tint ?? Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(selected ? Color.accentColor : Color.primary, lineWidth: selected ? 3 : today ? 1.5 : 0)
        }
    }
}

struct MiniMonth: View {
    @Environment(Store.self) private var store
    let year: Int
    let month: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(monthName(month))
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            ForEach(weeks(year: year, month: month), id: \.self) { week in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color(week[index]))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(8)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func color(_ date: Date?) -> Color {
        guard let date else { return .clear }
        return store.shift(on: date)?.tint ?? Color(.systemGray4)
    }
}
