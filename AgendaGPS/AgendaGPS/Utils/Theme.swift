import SwiftUI
import UIKit

struct Theme {
    // 1. El color rosa para botones, iconos y switches
    static let uiAccent = UIColor(red: 0.94, green: 0.39, blue: 0.58, alpha: 1.0)
    static let accent = Color(uiColor: uiAccent)
    
    // 2. Color de texto dinámico (Negro en modo claro, Blanco en modo oscuro)
    static let uiDarkText = UIColor.systemPink
    
    static func applyAppearance() {
        // --- Navigation Bar (Barra Superior) ---
        let navAppearance = UINavigationBarAppearance()
        
        // LA SOLUCIÓN: Usamos el fondo de "cristal" nativo de Apple.
        // Al NO asignarle un "backgroundColor", evitamos el cuadro rojo que se estira al cambiar de pantallas.
        navAppearance.configureWithDefaultBackground()
        
        // Forzamos el texto a ser negro
        navAppearance.titleTextAttributes = [
            .foregroundColor: uiDarkText
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: uiDarkText
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Flechas de retroceso y botones de arriba en rosa
        UINavigationBar.appearance().tintColor = uiAccent
        
        // --- Tab Bar (Barra Inferior) ---
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        
        // Iconos de la barra de abajo en rosa
        UITabBar.appearance().tintColor = uiAccent
        
        // --- Switches (Interruptores) ---
        UISwitch.appearance().onTintColor = uiAccent
    }
}
