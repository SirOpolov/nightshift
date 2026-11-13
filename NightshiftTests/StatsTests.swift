import XCTest
@testable import Nightshift

final class StatsTests: XCTestCase {
    let early = ShiftType(id: "F15", name: "früh", start: "06:45", end: "14:57", color: "#F8C8DC", vacation: false)
    let night = ShiftType(id: "N", name: "nacht", start: "21:00", end: "07:00", color: "#FFCBA4", vacation: false)
    let vacation = ShiftType(id: "Urlaub", name: "", start: nil, end: nil, color: "#FFF3A3", vacation: true)

    func testNetMinutes() {
        XCTAssertEqual(early.minutes, 462)
        XCTAssertEqual(night.minutes, 570)
        XCTAssertEqual(vacation.minutes, 0)
        XCTAssertEqual(hours(462), "7:42 h")
    }

    func testStatsCountOnlyUntilToday() {
        let entries = ["2026-11-09": "F15", "2026-11-10": "N", "2026-11-11": "Urlaub", "2026-11-20": "F15"]
        let stats = Stats(entries: entries, shiftTypes: [early, night, vacation], from: day(2026, 11, 1), to: day(2026, 11, 30), today: day(2026, 11, 13))
        XCTAssertEqual(stats.minutes, 1032)
        XCTAssertEqual(stats.vacationDays, 1)
        XCTAssertEqual(stats.counts, ["F15": 1, "N": 1, "Urlaub": 1])
    }

    func testWeeks() {
        let november = weeks(year: 2026, month: 11)
        XCTAssertEqual(november.count, 6)
        XCTAssertEqual(november[0].compactMap { $0 }, [day(2026, 11, 1)])
        XCTAssertEqual(weekNumber(november[2]), 46)
        XCTAssertEqual(weekNumber(weeks(year: 2027, month: 1)[0]), 53)
        XCTAssertEqual(dayKey(lastDay(2028, 2)), "2028-02-29")
    }
}
