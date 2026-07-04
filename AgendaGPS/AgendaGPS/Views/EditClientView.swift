import SwiftUI

struct EditClientView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ClientsViewModel
    
    // Recibimos la clienta original que vamos a editar
    var client: Client
    
    // Estados para los campos (se llenarán en el init)
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var notes = ""
    
    // El inicializador llena los TextField con los datos actuales de la clienta
    init(viewModel: ClientsViewModel, client: Client) {
        self.viewModel = viewModel
        self.client = client
        
        // Asignamos los valores iniciales a las variables de estado
        _name = State(initialValue: client.name)
        _phoneNumber = State(initialValue: client.phoneNumber)
        _email = State(initialValue: client.email)
        _notes = State(initialValue: client.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre completo", text: $name)
                    TextField("Número de telefono", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email (Opcional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Notas adicionales")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Editar Clienta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // 1. Hacemos una copia de la clienta original
                        var updatedClient = client
                        // 2. Le inyectamos los nuevos valores del formulario
                        updatedClient.name = name
                        updatedClient.phoneNumber = phoneNumber
                        updatedClient.email = email
                        updatedClient.notes = notes.isEmpty ? nil : notes
                        
                        // 3. La enviamos a Firebase
                        viewModel.updateClient(client: updatedClient)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}
