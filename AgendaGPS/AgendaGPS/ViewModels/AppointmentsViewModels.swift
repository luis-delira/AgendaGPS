import Foundation
internal import Combine
import FirebaseFirestore
import UIKit // Importante para usar UIApplication y abrir WhatsApp

class AppointmentsViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var isLoading: Bool = true
    
    private var db: Firestore {
        Firestore.firestore()
    }
    
    init() {
        fetchAppointments()
    }
    
    func fetchAppointments() {
        db.collection("appointments")
            .order(by: "date")
            .addSnapshotListener { querySnapshot, error in
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching appointments: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.appointments = documents.compactMap { document -> Appointment? in
                    try? document.data(as: Appointment.self)
                }
            }
        }
    }
    
    func addAppointment(appointment: Appointment) {
        do {
            let _ = try db.collection("appointments").addDocument(from: appointment)
            print("Appointment successfully saved!")
        } catch {
            print("Error saving appointment: \(error.localizedDescription)")
        }
    }
    
    func updateAppointment(appointment: Appointment) {
        guard let appointmentId = appointment.id else { return }
        do {
            try db.collection("appointments").document(appointmentId).setData(from: appointment)
            print("Appointment successfully updated!")
        } catch {
            print("Error updating appointment: \(error.localizedDescription)")
        }
    }
    
    func deleteAppointment(at offsets: IndexSet) {
        for index in offsets {
            let appointment = appointments[index]
            guard let appointmentId = appointment.id else { continue }
            
            db.collection("appointments").document(appointmentId).delete { error in
                if let error = error {
                    print("Error deleting appointment: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteAppointmentById(id: String) {
        db.collection("appointments").document(id).delete { error in
            if let error = error {
                print("Error deleting appointment: \(error.localizedDescription)")
            }
        }
    }
    
    // NUEVA FUNCIÓN: Enviar WhatsApp
    func enviarWhatsApp(appointment: Appointment) {
        // 1. Obtenemos el teléfono (si no tiene, usamos vacío)
        let telefonoBase = appointment.clientPhone ?? ""
        
        // 2. Limpiamos el número por si tiene espacios, guiones o paréntesis
        let telefonoLimpio = telefonoBase
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        // 3. Formateamos la fecha para que sea legible (Ej: "15 de Ago, 10:00")
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX") // Forzamos el idioma español
        let fechaLegible = formatter.string(from: appointment.date)
        
        // 4. Creamos el mensaje personalizado
        let mensaje = "Hola \(appointment.clientName), te recordamos tu cita de \(appointment.serviceName) para el día \(fechaLegible). ¡Te esperamos!"
        
        // 5. Construimos la URL
        let urlString = "https://wa.me/\(telefonoLimpio)?text=\(mensaje.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // 6. Abrimos la app de WhatsApp
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

