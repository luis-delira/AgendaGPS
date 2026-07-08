import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Resumen", systemImage: "chart.bar.fill")
                }
            
            AppointmentsView()
                .tabItem {
                    Label("Agenda", systemImage: "calendar")
                }
            
            ClientsView()
                .tabItem {
                    Label("Clientas", systemImage: "person.2.fill")
                }
            
            // NUEVA PESTAÑA: Centro de Notificaciones
            NotificationsView()
                .tabItem {
                    Label("Notificaciones", systemImage: "bell.badge.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
