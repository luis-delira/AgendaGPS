import Foundation
internal import Combine
import FirebaseFirestore

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
            
            // NUEVO: Sincronizar el nombre en todas las citas de esta clienta
            updateClientNameInAppointments(clientId: clientId, newName: client.name)
            
        } catch {
            print("Error updating client: \(error.localizedDescription)")
        }
    }
    
    // NUEVA FUNCIÓN: Busca las citas y actualiza el nombre viejo por el nuevo
    private func updateClientNameInAppointments(clientId: String, newName: String) {
        // 1. Buscamos todas las citas que le pertenezcan a este ID
        db.collection("appointments").whereField("clientId", isEqualTo: clientId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error buscando citas para actualizar: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else { return }
            
            // 2. Usamos un Batch para actualizar todas las citas de un solo golpe
            let batch = self.db.batch()
            
            for document in documents {
                let docRef = self.db.collection("appointments").document(document.documentID)
                batch.updateData(["clientName": newName], forDocument: docRef)
            }
            
            // 3. Ejecutamos el lote de actualizaciones
            batch.commit { error in
                if let error = error {
                    print("Error sincronizando nombres en citas: \(error.localizedDescription)")
                } else {
                    print("¡Nombres en citas sincronizados correctamente!")
                }
            }
        }
    }
    
    func deleteClient(at offsets: IndexSet) {
        for index in offsets {
            let client = clients[index]
            guard let clientId = client.id else { continue }
            
            db.collection("clients").document(clientId).delete { error in
                if let error = error {
                    print("Error deleting client: \(error.localizedDescription)")
                } else {
                    print("Client successfully deleted!")
                }
            }
        }
    }
}

