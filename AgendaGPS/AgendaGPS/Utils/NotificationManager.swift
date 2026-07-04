import Foundation
internal import Combine
import UserNotifications
import SwiftUI

// Agregamos ObservableObject para que la nueva vista pueda "escuchar" los cambios
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    // Lista de notificaciones pendientes para mostrarlas en la nueva pantalla
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 1. Pedir permiso al usuario para mostrar notificaciones
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error pidiendo permisos: \(error.localizedDescription)")
            } else if success {
                print("¡Permisos de notificación concedidos!")
            }
        }
    }
    
    // 2. Programar la notificación para una cita (24h y/o 30m)
    func programarNotificacion(para appointment: Appointment, avisar24h: Bool = true, avisar30m: Bool = true) {
        if let id = appointment.id {
            cancelarNotificacion(id: id)
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let horaStr = formatter.string(from: appointment.date)
        
        // --- 1. Programar recordatorio de 24 horas antes ---
        if avisar24h {
            let tiempo24h = appointment.date.addingTimeInterval(-24 * 60 * 60)
            if tiempo24h > Date() {
                let content24h = UNMutableNotificationContent()
                content24h.title = "Cita Mañana: \(appointment.clientName)"
                content24h.body = "Recuerda que mañana a las \(horaStr) tienes un servicio de \(appointment.serviceName)."
                content24h.sound = .default
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tiempo24h)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                // Usamos el ID de Firebase añadiéndole "-24h"
                let request = UNNotificationRequest(identifier: "\(appointment.id ?? UUID().uuidString)-24h", content: content24h, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        // --- 2. Programar recordatorio de 30 minutos antes ---
        if avisar30m {
            let tiempo30m = appointment.date.addingTimeInterval(-30 * 60)
            if tiempo30m > Date() {
                let content30m = UNMutableNotificationContent()
                content30m.title = "Próxima Cita: \(appointment.clientName)"
                content30m.body = "Tienes un servicio de \(appointment.serviceName) a las \(horaStr)."
                content30m.sound = .default
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tiempo30m)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                // Usamos el ID de Firebase añadiéndole "-30m"
                let request = UNNotificationRequest(identifier: "\(appointment.id ?? UUID().uuidString)-30m", content: content30m, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        // Refrescamos la lista de la nueva vista con un pequeño retraso para asegurar que iOS ya las guardó
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchPendingNotifications()
        }
    }
    
    // 3. Cancelar todas las posibles notificaciones (24h y 30m) para una cita
    func cancelarNotificacion(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(id)-24h", "\(id)-30m"])
        
        // Refrescamos la vista
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchPendingNotifications()
        }
    }
    
    // 4. Función que le pregunta al iPhone qué alertas tiene guardadas
    func fetchPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                // Las ordenamos para que las más próximas salgan hasta arriba en la lista
                self.pendingNotifications = requests.sorted { req1, req2 in
                    guard let t1 = req1.trigger as? UNCalendarNotificationTrigger, let d1 = t1.nextTriggerDate(),
                          let t2 = req2.trigger as? UNCalendarNotificationTrigger, let d2 = t2.nextTriggerDate() else {
                        return false
                    }
                    return d1 < d2
                }
            }
        }
    }
    
    // 5. Fuerza a iOS a mostrar la alerta incluso si la app está abierta en la pantalla
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

