import Foundation
import FirebaseFirestore

struct Client: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var phoneNumber: String
    var email: String?
    var notes: String?
    var imageUrl: String?
    var birthday: Date? // NEW: Birthday property
    var loyaltyStamps: Int? // NEW: sellos de la tarjeta de fidelidad (0-6)
}

extension Client {
    // Número máximo de sellos para ganar el premio
    static let maxLoyaltyStamps = 6

    // Sellos actuales (0 si la clienta aún no tiene tarjeta)
    var stampCount: Int {
        loyaltyStamps ?? 0
    }

    // Helper to check if today is their birthday
    var isBirthdayToday: Bool {
        guard let birthday = birthday else { return false }
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        let bday = Calendar.current.dateComponents([.month, .day], from: birthday)
        return today.month == bday.month && today.day == bday.day
    }
}
