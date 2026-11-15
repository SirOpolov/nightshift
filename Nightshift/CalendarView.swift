import SwiftUI

struct CalendarView: View {
    @Environment(Store.self) private var store
    @Environment(\.accent) private var accent
    @State private var year = calendar.component(.year, from: .now)
    @State private var month = calendar.component(.month, from: .now)
    @State private var showYear = false
    @State private var editing = false
    @State private var tool: String?
    @State private var start: Date?

    var body: some View {
        NavigationStack {
            Group {
                if showYear {
                    yearView
                } else {
                    monthView
                }
            }
            .padding(.horizontal, 12)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if editing {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            leave()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 4) {
                        Button {
                            step(-1)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Text(title)
                            .font(.headline)
                            .frame(minWidth: 150)
                        Button {
                            step(1)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showYear.toggle()
                    } label: {
                        Image(systemName: showYear ? "calendar" : "square.grid.3x3")
                    }
                }
            }
            .toolbar(editing ? .hidden : .visible, for: .tabBar)
            .safeAreaInset(edge: .bottom) {
                if editing {
                    palette
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !editing {
                    Button {
                        editing = true
                        showYear = false
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .tint(turquoise)
                    .foregroundStyle(.black)
                    .padding(16)
                }
            }
        }
    }

    private var title: String {
        showYear ? String(year) : monthName(month) + " " + String(year)
    }

    private var hint: String {
        if tool == nil {
            return "Schicht wählen"
        }
        return start == nil ? "Starttag tippen" : "Endtag tippen"
    }

    private var monthView: some View {
        MonthGrid(year: year, month: month, selected: start) { date in
            tapped(date)
        }
        .padding(.top, 8)
        .padding(.bottom, editing ? 8 : 84)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30).onEnded { value in
                if value.translation.width < -50 {
                    step(1)
                }
                if value.translation.width > 50 {
                    step(-1)
                }
            }
        )
    }

    private var yearView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(1...12, id: \.self) { number in
                    MiniMonth(year: year, month: number)
                        .onTapGesture {
                            month = number
                            showYear = false
                        }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 84)
        }
    }

    private var palette: some View {
        VStack(spacing: 8) {
            Text(hint)
                .font(.footnote.weight(.medium))
                .foregroundStyle(accent)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(store.shiftTypes) { shift in
                        chip(shift.id, shift.id, shift.tint)
                    }
                    chip("", "Löschen", .white)
                }
                .padding(.horizontal, 12)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func chip(_ id: String, _ label: String, _ color: Color) -> some View {
        Button {
            tool = id
            start = nil
        } label: {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(color, in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.primary, lineWidth: tool == id ? 3 : 0)
                }
        }
    }

    private func tapped(_ date: Date) {
        guard editing, let tool else { return }
        guard let first = start else {
            start = date
            return
        }
        if date >= first {
            let shift = store.shiftTypes.first { $0.id == tool }
            store.set(shift, from: first, to: date)
        }
        start = nil
    }

    private func step(_ delta: Int) {
        if showYear {
            year += delta
            return
        }
        month += delta
        if month < 1 {
            month = 12
            year -= 1
        }
        if month > 12 {
            month = 1
            year += 1
        }
    }

    private func leave() {
        editing = false
        tool = nil
        start = nil
    }
}
