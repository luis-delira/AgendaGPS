import Foundation
import FirebaseFirestore
import UIKit
internal import Combine

class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading: Bool = true
    
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
    
    // --- ALMACENAMIENTO LOCAL DE IMÁGENES ---
    // Guarda la foto en el dispositivo y devuelve el nombre del archivo,
    // que se almacena en el campo imageUrl de Firestore.
    // Si la clienta tenía una foto local anterior, la borramos para no acumular archivos.
    func saveImageLocally(image: UIImage, replacing oldImageUrl: String? = nil, completion: @escaping (String?) -> Void) {
        if let old = oldImageUrl, !old.isEmpty, !old.hasPrefix("http") {
            ImageStorageManager.shared.deleteImage(named: old)
        }
        completion(ImageStorageManager.shared.saveImage(image))
    }
    
    // --- FIRESTORE CRUD ---
    func addClient(client: Client) {
        do {
            let ref = try db.collection("clients").addDocument(from: client)
            print("Client successfully saved to Firestore!")
            
            // NEW: Agregamos el ID generado y programamos el cumpleaños
            var savedClient = client
            savedClient.id = ref.documentID
            NotificationManager.shared.scheduleBirthdayNotification(for: savedClient)
            
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
            
            // NEW: Actualizamos la notificación por si cambió de fecha de cumpleaños
            NotificationManager.shared.scheduleBirthdayNotification(for: client)
            
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
            
            // NEW: Cancelamos la alerta de cumpleaños al borrar a la clienta
            NotificationManager.shared.cancelBirthdayNotification(id: clientId)

            // Borramos también su foto del almacenamiento local (si no es una URL antigua)
            if let imageUrl = client.imageUrl, !imageUrl.isEmpty, !imageUrl.hasPrefix("http") {
                ImageStorageManager.shared.deleteImage(named: imageUrl)
            }

            db.collection("clients").document(clientId).delete()
        }
    }
}
