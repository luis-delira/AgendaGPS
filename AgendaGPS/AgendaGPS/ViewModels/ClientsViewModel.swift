import Foundation
import FirebaseFirestore
import UIKit
internal import Combine

class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading: Bool = true // Restored to avoid errors
    
    private var db: Firestore {
        Firestore.firestore()
    }
    
    init() {
        fetchClients()
    }
    
    func fetchClients() {
        db.collection("clients").addSnapshotListener { querySnapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching clients: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.clients = documents.compactMap { document -> Client? in
                    try? document.data(as: Client.self)
                }
            }
        }
    }
    
    // --- HOSTINGER UPLOAD FUNCTION ---
    func uploadImage(image: UIImage, completion: @escaping (String?) -> Void) {
        // 🔴 CHANGE THIS to your actual domain
        let serverUrlString = "https://paradoxtudio.com/agenda_uploads/upload.php"
        
        guard let url = URL(string: serverUrlString) else {
            print("Invalid server URL")
            completion(nil)
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = "\(UUID().uuidString).jpg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading to Hostinger: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imageUrl = json["url"] as? String {
                    DispatchQueue.main.async {
                        completion(imageUrl)
                    }
                } else {
                    if let plainTextResponse = String(data: data, encoding: .utf8), plainTextResponse.hasPrefix("http") {
                        DispatchQueue.main.async { completion(plainTextResponse.trimmingCharacters(in: .whitespacesAndNewlines)) }
                    } else {
                        DispatchQueue.main.async { completion(nil) }
                    }
                }
            } catch {
                if let plainTextResponse = String(data: data, encoding: .utf8), plainTextResponse.hasPrefix("http") {
                    DispatchQueue.main.async { completion(plainTextResponse.trimmingCharacters(in: .whitespacesAndNewlines)) }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }.resume()
    }
    
    // --- FIRESTORE CRUD ---
    func addClient(client: Client) {
        do {
            let _ = try db.collection("clients").addDocument(from: client)
            print("Client successfully saved to Firestore!")
        } catch {
            print("Error saving client: \(error.localizedDescription)")
        }
    }
    
    func updateClient(client: Client) {
        guard let clientId = client.id else { return }
        do {
            try db.collection("clients").document(clientId).setData(from: client)
            print("Client successfully updated!")
            updateClientNameInAppointments(clientId: clientId, newName: client.name)
        } catch {
            print("Error updating client: \(error.localizedDescription)")
        }
    }
    
    private func updateClientNameInAppointments(clientId: String, newName: String) {
        db.collection("appointments").whereField("clientId", isEqualTo: clientId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, !documents.isEmpty else { return }
            let batch = self.db.batch()
            
            for document in documents {
                let docRef = self.db.collection("appointments").document(document.documentID)
                batch.updateData(["clientName": newName], forDocument: docRef)
            }
            batch.commit()
        }
    }
    
    func deleteClient(at offsets: IndexSet) {
        for index in offsets {
            let client = clients[index]
            guard let clientId = client.id else { continue }
            db.collection("clients").document(clientId).delete()
        }
    }
}
