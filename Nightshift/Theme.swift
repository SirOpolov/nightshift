import SwiftUI
import UIKit

let defaultAccent = Color(UIColor { traits in
    traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.50, green: 0.86, blue: 0.84, alpha: 1)
        : UIColor(red: 0.10, green: 0.56, blue: 0.54, alpha: 1)
})

let card = Color(UIColor { traits in
    traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.09, green: 0.13, blue: 0.14, alpha: 1)
        : UIColor(red: 0.92, green: 0.97, blue: 0.96, alpha: 1)
})

let turquoise = Color(red: 0.56, green: 0.87, blue: 0.84)
let turquoiseLight = Color(red: 0.80, green: 0.95, blue: 0.93)

extension EnvironmentValues {
    @Entry var accent = defaultAccent
}

func themeColor(_ hex: String) -> Color {
    let clean = hex.trimmingCharacters(in: CharacterSet(charactersIn: "# "))
    guard clean.count == 6, let value = Int(clean, radix: 16) else { return defaultAccent }
    return Color(red: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255)
}

func hexString(_ color: Color) -> String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let channel = { (value: CGFloat) in max(0, min(255, Int((value * 255).rounded()))) }
    return String(format: "#%02X%02X%02X", channel(red), channel(green), channel(blue))
}
