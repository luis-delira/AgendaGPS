import Foundation
import FirebaseFirestore // Importante para @DocumentID

// EL MODELO (M): Define qué es un Cliente
struct Client: Identifiable, Codable {
    @DocumentID var id: String? // Firestore llenará esto automáticamente
    var name: String
    var phoneNumber: String
    var email: String
    var notes: String?
}
