import Foundation
import FirebaseFirestore
internal import Combine

// EL VIEWMODEL (VM): El intermediario que habla con Firebase
// Usamos @MainActor para asegurar que la UI se actualice en el hilo principal
@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    
    // Función para obtener las clientas desde Firebase
    func fetchClientes() {
        isLoading = true
        
        // Apuntamos a la colección "clientes" que definimos en el diseño
        db.collection("clients").addSnapshotListener { querySnapshot, error in
            self.isLoading = false
            
            if let error = error {
                print("Error al obtener clientas: \(error.localizedDescription)")
                return
            }
            
            // Mapeamos los documentos de Firestore a nuestro Struct 'Cliente'
            self.clients = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Client.self)
            } ?? []
        }
    }
}
