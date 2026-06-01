import SwiftUI
import SwiftData

@Observable
class CardioViewModel {
    var cardioSession: CardioSession
    var elapsedSeconds: Int = 0
    var isRunning: Bool = false
    var isCompleted: Bool = false

    private var timer: Timer?

    init(cardioSession: CardioSession) {
        self.cardioSession = cardioSession
    }

    var progress: Double {
        let target = cardioSession.targetDurationMin * 60
        guard target > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(target), 1.0)
    }

    var remainingSeconds: Int {
        max(cardioSession.targetDurationMin * 60 - elapsedSeconds, 0)
    }

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 1
            if self.elapsedSeconds >= self.cardioSession.targetDurationMin * 60 {
                self.completeCardio()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func completeCardio(context: ModelContext? = nil) {
        pause()
        cardioSession.actualDurationMin = elapsedSeconds / 60
        cardioSession.isCompleted = true
        cardioSession.completedAt = Date()
        cardioSession.caloriesEstimated = Float(elapsedSeconds / 60) * 6.0
        isCompleted = true
        if let ctx = context { try? ctx.save() }
    }
}
