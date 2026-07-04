import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
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
    }
}

#Preview {
    RootView()
}
