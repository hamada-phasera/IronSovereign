import SwiftUI

extension Color {
    // === 背景系 (Nightreign: 深夜の藍) ===
    static let ironAbyss    = Color(hex: "#060912")  // 夜天の最深
    static let ironDark     = Color(hex: "#0B1122")  // 夜の帳
    static let ironSurface  = Color(hex: "#101C35")  // 深海の紺
    static let ironElevated = Color(hex: "#182C4A")  // 月夜の紺碧

    // === アクセント (Nightreign: 月光・蒼炎・黄金律) ===
    static let ironEmber    = Color(hex: "#4A8FBF")  // 月光の蒼
    static let ironFlame    = Color(hex: "#7AB4E0")  // 銀青の輝き
    static let ironGold     = Color(hex: "#C9A836")  // 黄金律
    static let ironAsh      = Color(hex: "#7A8FA0")  // 月の灰

    // === テキスト (冷月の白銀) ===
    static let ironBone     = Color(hex: "#D8E8F8")  // 月光白
    static let ironStone    = Color(hex: "#6080A0")  // 霧の石
    static let ironFade     = Color(hex: "#2A3D54")  // 深夜の影

    // === ステータス ===
    static let ironVictory  = Color(hex: "#2AB87A")  // 勝利の碧
    static let ironDefeat   = Color(hex: "#C62828")  // 敗北の赤
    static let ironCaution  = Color(hex: "#E8A020")  // 警戒の琥珀

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

extension LinearGradient {
    // 月光グラデーション（ボタン・アクセント）
    static let emberGradient = LinearGradient(
        colors: [.ironEmber, .ironFlame],
        startPoint: .leading, endPoint: .trailing
    )
    // 夜空グラデーション（背景）
    static let darkGradient = LinearGradient(
        colors: [Color(hex: "#060912"), Color(hex: "#0C1828")],
        startPoint: .top, endPoint: .bottom
    )
    // 黄金律グラデーション
    static let goldGradient = LinearGradient(
        colors: [.ironGold, Color(hex: "#A07820")],
        startPoint: .leading, endPoint: .trailing
    )
}
