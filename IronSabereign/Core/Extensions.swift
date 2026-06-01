import Foundation

extension Date {
    /// 週の開始日（月曜日）を返す
    var startOfWeek: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        )!
    }
}
