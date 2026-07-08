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
}

extension Client {
    // Helper to check if today is their birthday
    var isBirthdayToday: Bool {
        guard let birthday = birthday else { return false }
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        let bday = Calendar.current.dateComponents([.month, .day], from: birthday)
        return today.month == bday.month && today.day == bday.day
    }
}
