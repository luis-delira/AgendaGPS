import Foundation
import FirebaseFirestore

struct Appointment: Identifiable, Codable {
    @DocumentID var id: String?
    var clientId: String
    var clientName: String // Guardamos el nombre para no tener que buscarlo cada vez
    var clientPhone: String?
    var serviceName: String
    var price: Double
    var date: Date
    var notes: String?
}
