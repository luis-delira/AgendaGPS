import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // APLICAMOS EL TEMA "GIRLY" AL INICIAR LA APP
        Theme.applyAppearance()
    }
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        // PASO CLAVE: Compartimos este ÚNICO "Cerebro" con toda la app
        .environmentObject(authViewModel)
        
        // ESTILOS GLOBALES DE SWIFTUI:
        .tint(Theme.accent) // Cambia el color por defecto a nuestro rosa en todos los botones y enlaces
        .fontDesign(.rounded) // Hace que el texto de toda la app sea redondeado y más suave visualmente
    }
}

#Preview {
    RootView()
}
