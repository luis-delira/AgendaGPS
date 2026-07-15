import SwiftUI
import UserNotifications

struct NotificationsView: View {
    // Usamos @State local para almacenar las notificaciones entregadas
    @State private var deliveredNotifications: [UNNotification] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                GirlyBackground()

                Group {
                    if deliveredNotifications.isEmpty {
                        ContentUnavailableView(
                            "Sin notificaciones recientes",
                            systemImage: "bell.slash",
                            description: Text("No se han mostrado notificaciones recientemente.")
                        )
                        .foregroundColor(Theme.softText)
                    } else {
                        List {
                            // Iteramos sobre las notificaciones entregadas
                            ForEach(deliveredNotifications, id: \.request.identifier) { notification in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(Theme.primaryPink)
                                        .font(.title3)
                                        .padding(.top, 2)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(notification.request.content.title)
                                            .font(.headline)
                                            .foregroundColor(Theme.deepRose)

                                        Text(notification.request.content.body)
                                            .font(.subheadline)
                                            .foregroundColor(Theme.softText)

                                        // Mostramos la fecha exacta en que apareció la notificación
                                        HStack {
                                            Image(systemName: "calendar.badge.clock")
                                            Text("Recibida: \(notification.date, style: .date) a las \(notification.date, style: .time)")
                                        }
                                        .font(.caption)
                                        .foregroundColor(Theme.gold)
                                        .padding(.top, 4)
                                    }
                                }
                                .padding()
                                .girlyCard()
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete(perform: eliminarNotificacion)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Notificaciones") // Título actualizado
            .onAppear {
                fetchDeliveredNotifications()
            }
            // Opcional: Actualizar la lista al volver a la app
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                fetchDeliveredNotifications()
            }
        }
    }
    
    // Función para obtener las notificaciones que ya han aparecido
    private func fetchDeliveredNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                // Filtramos las de cumpleaños y ordenamos por fecha (más recientes primero)
                self.deliveredNotifications = notifications
                    .filter { !$0.request.identifier.contains("birthday") }
                    .sorted { $0.date > $1.date }
            }
        }
    }
    
    // Función para eliminar notificaciones del centro de notificaciones
    private func eliminarNotificacion(at offsets: IndexSet) {
        let idsToRemove = offsets.map { deliveredNotifications[$0].request.identifier }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idsToRemove)
        
        // Actualizamos la lista después de un breve retraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            fetchDeliveredNotifications()
        }
    }
}

#Preview {
    NotificationsView()
}
