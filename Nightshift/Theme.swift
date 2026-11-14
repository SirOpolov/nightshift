import SwiftUI
import UIKit

let accent = Color(UIColor { traits in
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
