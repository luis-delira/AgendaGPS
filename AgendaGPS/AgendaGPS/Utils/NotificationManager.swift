import Foundation
internal import Combine
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            if success { print("Notifications allowed!") }
        }
    }
    
    func programarNotificacion(para appointment: Appointment, avisar24h: Bool = true, avisar30m: Bool = true) {
        if let id = appointment.id { cancelarNotificacion(id: id) }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let horaStr = formatter.string(from: appointment.date)
        
        if avisar24h {
            let tiempo24h = appointment.date.addingTimeInterval(-24 * 60 * 60)
            if tiempo24h > Date() {
                let content24h = UNMutableNotificationContent()
                content24h.title = "¡Cita de mañana con: \(appointment.clientName)!"
                content24h.body = "Recuerda: Mañana a las \(horaStr) tienes un servicio de \(appointment.serviceName)."
                content24h.sound = .default
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tiempo24h)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: "\(appointment.id ?? UUID().uuidString)-24h", content: content24h, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        if avisar30m {
            let tiempo30m = appointment.date.addingTimeInterval(-30 * 60)
            if tiempo30m > Date() {
                let content30m = UNMutableNotificationContent()
                content30m.title = "Cinta en seguida: \(appointment.clientName)"
                content30m.body = "Tienes un servicio de  \(appointment.serviceName) a las \(horaStr)."
                content30m.sound = .default
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tiempo30m)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: "\(appointment.id ?? UUID().uuidString)-30m", content: content30m, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.fetchPendingNotifications() }
    }
    
    func cancelarNotificacion(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(id)-24h", "\(id)-30m"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.fetchPendingNotifications() }
    }
    
    // --- NEW: BIRTHDAY NOTIFICATIONS ---
    func scheduleBirthdayNotification(for client: Client) {
        guard let id = client.id, let birthday = client.birthday else { return }
        
        cancelBirthdayNotification(id: id)
        
        let content = UNMutableNotificationContent()
        content.title = "Cumple de clienta! 🎂"
        
        // FIX: Cambiamos el texto para que tenga sentido leerlo hoy o dentro de 5 meses
        content.body = "Es el cumple de \(client.name). Enviale un bonito mensaje."
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthday)
        dateComponents.hour = 9 // Sonará a las 9:00 AM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "\(id)-birthday", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        // Actualizamos la lista de alertas al instante
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.fetchPendingNotifications() }
    }
    
    func cancelBirthdayNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(id)-birthday"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.fetchPendingNotifications() }
    }
    
    func fetchPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests.sorted { req1, req2 in
                    guard let t1 = req1.trigger as? UNCalendarNotificationTrigger, let d1 = t1.nextTriggerDate(),
                          let t2 = req2.trigger as? UNCalendarNotificationTrigger, let d2 = t2.nextTriggerDate() else { return false }
                    return d1 < d2
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
