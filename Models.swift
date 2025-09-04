
import Foundation
import SwiftData

@Model
final class WorkEntry {
    var date: Date
    var location: String
    var jobNumber: String
    var startTime: Date
    var endTime: Date
    var notes: String?  // NOVO campo opcional

    init(date: Date, location: String, jobNumber: String, startTime: Date, endTime: Date, notes: String? = nil) {
        self.date = date.onlyDate
        self.location = location
        self.jobNumber = jobNumber
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
    }

    // horas brutas (fim - início)
    var durationHoursRaw: Double {
        max(0, endTime.timeIntervalSince(startTime) / 3600.0)
    }

    // horas líquidas descontando 1h de almoço
    var durationHoursNet: Double {
        max(0, durationHoursRaw - 1.0) // 1h de almoço
    }
}

// helpers de data
extension Date {
    var onlyDate: Date { Calendar.current.startOfDay(for: self) }

    /// combina o dia de `self` com a hora de `time`
    func combiningTime(from time: Date) -> Date {
        let cal = Calendar.current
        let d = cal.dateComponents([.year,.month,.day], from: self)
        let t = cal.dateComponents([.hour,.minute,.second], from: time)
        var c = DateComponents()
        c.year = d.year; c.month = d.month; c.day = d.day
        c.hour = t.hour; c.minute = t.minute; c.second = t.second
        return cal.date(from: c) ?? self
    }
}
