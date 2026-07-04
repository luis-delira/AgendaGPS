import SwiftUI

struct AddClientsView: View {
    // Esta variable nos permite cerrar esta pantalla cuando terminemos
    @Environment(\.dismiss) var dismiss
    
    // Recibimos el ViewModel para poder usar su función de guardar
    @ObservedObject var viewModel: ClientsViewModel
    
    // Variables de estado para los campos de texto
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre completo", text: $name)
                    TextField("Teléfono", text: $phoneNumber)
                        .keyboardType(.phonePad) // Abre el teclado numérico
                    TextField("Correo electrónico (Opcional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Notas Adicionales")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nueva Clienta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón para cancelar y cerrar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                // Botón para guardar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let newClient = Client(
                            name: name,
                            phoneNumber: phoneNumber,
                            email: email,
                            notes: notes.isEmpty ? nil : notes
                        )
                        viewModel.addClient(client: newClient)
                        dismiss() // Cierra la pantalla después de guardar
                    }
                    // Deshabilita el botón si no hay nombre o teléfono
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}
