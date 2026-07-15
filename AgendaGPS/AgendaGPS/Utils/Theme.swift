import SwiftUI
import UIKit

// MARK: - Sistema de Diseño "Girly" (Rosa · Dorado · Blanco)
struct Theme {

    // MARK: Paleta de Colores

    // Rosa principal (botones, iconos, acentos)
    static let uiAccent = UIColor(red: 0.94, green: 0.39, blue: 0.58, alpha: 1.0)
    static let accent = Color(uiColor: uiAccent)
    static let primaryPink = accent

    // Rosa suave / blush (fondos)
    static let uiLightPink = UIColor(red: 0.98, green: 0.75, blue: 0.83, alpha: 1.0)
    static let lightPink = Color(uiColor: uiLightPink)

    static let uiBlush = UIColor(red: 0.99, green: 0.94, blue: 0.96, alpha: 1.0)
    static let blush = Color(uiColor: uiBlush)

    // Rosa profundo (títulos y textos destacados)
    static let uiDeepRose = UIColor(red: 0.78, green: 0.22, blue: 0.44, alpha: 1.0)
    static let deepRose = Color(uiColor: uiDeepRose)

    // Dorado (bordes finos, detalles de lujo)
    static let uiGold = UIColor(red: 0.83, green: 0.68, blue: 0.32, alpha: 1.0)
    static let gold = Color(uiColor: uiGold)

    static let uiLightGold = UIColor(red: 0.94, green: 0.85, blue: 0.60, alpha: 1.0)
    static let lightGold = Color(uiColor: uiLightGold)

    // Blanco puro para tarjetas
    static let card = Color.white

    // Texto secundario en tono rosado apagado
    static let softText = Color(red: 0.55, green: 0.42, blue: 0.48)

    // MARK: Gradientes

    // Fondo general de la app: blush -> blanco
    static let backgroundGradient = LinearGradient(
        colors: [blush, Color.white, lightPink.opacity(0.25)],
        startPoint: .top,
        endPoint: .bottom
    )

    // Gradiente rosa para botones y elementos destacados
    static let pinkGradient = LinearGradient(
        colors: [Color(red: 0.97, green: 0.56, blue: 0.72), primaryPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Gradiente dorado para bordes y detalles
    static let goldGradient = LinearGradient(
        colors: [lightGold, gold],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Gradiente estelar rosa + dorado para tarjetas premium (ej. ganancias)
    static let glamGradient = LinearGradient(
        colors: [primaryPink, Color(red: 0.90, green: 0.45, blue: 0.62), gold.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: Apariencia global de barras (Navigation & Tab)

    static func applyAppearance() {
        // --- Navigation Bar ---
        let navAppearance = UINavigationBarAppearance()
        // IMPORTANTE (iOS 26 / Liquid Glass): usamos el fondo por defecto del sistema.
        // Un fondo opaco personalizado interfiere con el efecto de borde de scroll
        // y provoca que los títulos de navegación desaparezcan en vistas con ScrollView/List.
        navAppearance.configureWithDefaultBackground()

        // Títulos en rosa profundo y redondeados
        navAppearance.titleTextAttributes = [
            .foregroundColor: uiDeepRose
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: uiDeepRose
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().tintColor = uiAccent

        // --- Tab Bar ---
        let tabAppearance = UITabBarAppearance()
        // Mismo criterio que la Navigation Bar: fondo por defecto para no
        // interferir con Liquid Glass en iOS 26.
        tabAppearance.configureWithDefaultBackground()

        // Íconos seleccionados en rosa, no seleccionados en rosa apagado
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = uiAccent
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: uiAccent]
        itemAppearance.normal.iconColor = uiLightPink
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: uiLightPink]

        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = uiAccent

        // --- Switches ---
        UISwitch.appearance().onTintColor = uiAccent
    }
}

// MARK: - Fondo reutilizable

struct GirlyBackground: View {
    var body: some View {
        Theme.backgroundGradient
            .ignoresSafeArea()
    }
}

// MARK: - Modificador de Tarjeta (blanco con borde dorado y sombra rosa)

struct GirlyCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.goldGradient, lineWidth: 1)
            )
            .shadow(color: Theme.primaryPink.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

extension View {
    /// Aplica el estilo de tarjeta blanca con borde dorado y sombra rosa.
    func girlyCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GirlyCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Estilo de botón principal (gradiente rosa con borde dorado)

struct GirlyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.pinkGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.gold.opacity(0.7), lineWidth: 1.5)
            )
            .shadow(color: Theme.primaryPink.opacity(0.4), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
