import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Resumen", systemImage: "chart.bar.fill")
                }
            
            // Pestaña 1: Citas
            AppointmentsView()
                .tabItem {
                    Label("Citas", systemImage: "calendar")
                }
            
            // Pestaña 2: Clientas
            ClientsView()
                .tabItem {
                    Label("Clientas", systemImage: "person.2.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
