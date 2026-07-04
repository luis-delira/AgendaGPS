import Foundation
import UserNotifications

class NotificationManager {
    // Creamos una instancia compartida (Singleton) para usarla en toda la app
    static let shared = NotificationManager()
    
    // 1. Pedir permiso al usuario para mostrar notificaciones
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error pidiendo permisos de notificación: \(error.localizedDescription)")
            } else if success {
                print("¡Permisos de notificación concedidos!")
            }
        }
    }
    
    // 2. Programar la notificación para una cita específica
    func programarNotificacion(para appointment: Appointment) {
        // Cancelamos cualquier notificación anterior para esta misma cita (por si cambió la hora)
        if let id = appointment.id {
            cancelarNotificacion(id: id)
        }
        
        // Crear el contenido del mensaje
        let content = UNMutableNotificationContent()
        content.title = "Próxima Cita: \(appointment.clientName)"
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let horaStr = formatter.string(from: appointment.date)
        
        content.body = "Tienes un servicio de \(appointment.serviceName) a las \(horaStr)."
        content.sound = .default
        
        // Configurar el tiempo (30 minutos antes de la cita)
        let tiempoAviso = appointment.date.addingTimeInterval(-30 * 60)
        
        // Verificamos que el tiempo de aviso sea en el futuro, de lo contrario no programamos nada
        guard tiempoAviso > Date() else { return }
        
        // Crear el disparador (Trigger) basado en el calendario
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tiempoAviso)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Usamos el ID de la cita de Firebase para vincular la notificación a esta cita exacta
        let request = UNNotificationRequest(
            identifier: appointment.id ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Añadir al centro de notificaciones de iOS
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error programando notificación: \(error.localizedDescription)")
            } else {
                print("Notificación programada con éxito para \(appointment.clientName)")
            }
        }
    }
    
    // 3. Cancelar una notificación (si se borra la cita o se apaga el recordatorio)
    func cancelarNotificacion(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
