import SwiftUI
import UserNotifications

struct NotificationsView: View {
    // Observamos el manager de notificaciones
    @StateObject private var notifManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if notifManager.pendingNotifications.isEmpty {
                    ContentUnavailableView(
                        "Sin Alertas",
                        systemImage: "bell.slash",
                        description: Text("No tienes recordatorios programados próximamente.")
                    )
                } else {
                    List {
                        ForEach(notifManager.pendingNotifications, id: \.identifier) { request in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(request.content.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(request.content.body)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Obtenemos la fecha exacta en la que el iPhone va a sonar
                                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                                   let nextTrigger = trigger.nextTriggerDate() {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                        Text("Sonará: \(nextTrigger, style: .date) a las \(nextTrigger, style: .time)")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: eliminarNotificacion)
                    }
                }
            }
            .navigationTitle("Tus Alertas")
            .onAppear {
                // Refrescamos la lista al abrir la pestaña
                notifManager.fetchPendingNotifications()
            }
        }
    }
    
    // Función para cancelar una alerta manualmente deslizando a la izquierda
    private func eliminarNotificacion(at offsets: IndexSet) {
        let idsToRemove = offsets.map { notifManager.pendingNotifications[$0].identifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        
        // Refrescamos la vista
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            notifManager.fetchPendingNotifications()
        }
    }
}

#Preview {
    NotificationsView()
}
