//
//  AppTheme.swift
//  To-Do List
//

import SwiftUI

// MARK: - Theme

struct AppTheme {
    let name: String
    let background: Color
    let cardBackground: Color
    let cardText: Color
    let buttonBackground: Color
    let buttonText: Color
    let accent: Color
    let exprBackground: Color
    let exprText: Color
    let secondaryText: Color
}

let themes: [AppTheme] = [
    AppTheme(
        name: "Classic",
        background: Color(UIColor.systemBackground),
        cardBackground: Color(UIColor.secondarySystemBackground),
        cardText: Color.primary,
        buttonBackground: Color(UIColor.tertiarySystemBackground),
        buttonText: Color.primary,
        accent: Color.blue,
        exprBackground: Color(UIColor.secondarySystemBackground),
        exprText: Color.primary,
        secondaryText: Color.secondary
    ),
    AppTheme(
        name: "Dark",
        background: Color(red: 0.1, green: 0.1, blue: 0.12),
        cardBackground: Color(red: 0.18, green: 0.18, blue: 0.22),
        cardText: Color.white,
        buttonBackground: Color(red: 0.22, green: 0.22, blue: 0.28),
        buttonText: Color.white,
        accent: Color(red: 0.4, green: 0.6, blue: 1.0),
        exprBackground: Color(red: 0.15, green: 0.15, blue: 0.18),
        exprText: Color.white,
        secondaryText: Color(white: 0.6)
    ),
    AppTheme(
        name: "Ocean",
        background: Color(red: 0.05, green: 0.15, blue: 0.3),
        cardBackground: Color(red: 0.08, green: 0.22, blue: 0.42),
        cardText: Color.white,
        buttonBackground: Color(red: 0.1, green: 0.28, blue: 0.5),
        buttonText: Color.white,
        accent: Color(red: 0.3, green: 0.85, blue: 0.85),
        exprBackground: Color(red: 0.06, green: 0.18, blue: 0.36),
        exprText: Color.white,
        secondaryText: Color(red: 0.5, green: 0.75, blue: 0.9)
    ),
    AppTheme(
        name: "Forest",
        background: Color(red: 0.08, green: 0.18, blue: 0.1),
        cardBackground: Color(red: 0.12, green: 0.25, blue: 0.14),
        cardText: Color.white,
        buttonBackground: Color(red: 0.15, green: 0.3, blue: 0.18),
        buttonText: Color.white,
        accent: Color(red: 0.4, green: 0.9, blue: 0.5),
        exprBackground: Color(red: 0.1, green: 0.2, blue: 0.12),
        exprText: Color.white,
        secondaryText: Color(red: 0.5, green: 0.8, blue: 0.55)
    ),
    AppTheme(
        name: "Sakura",
        background: Color(red: 1.0, green: 0.94, blue: 0.96),
        cardBackground: Color(red: 1.0, green: 0.85, blue: 0.9),
        cardText: Color(red: 0.5, green: 0.1, blue: 0.2),
        buttonBackground: Color(red: 0.98, green: 0.78, blue: 0.86),
        buttonText: Color(red: 0.5, green: 0.1, blue: 0.2),
        accent: Color(red: 0.9, green: 0.3, blue: 0.5),
        exprBackground: Color(red: 1.0, green: 0.9, blue: 0.93),
        exprText: Color(red: 0.5, green: 0.1, blue: 0.2),
        secondaryText: Color(red: 0.7, green: 0.4, blue: 0.5)
    ),
]
