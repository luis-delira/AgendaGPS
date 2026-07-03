import SwiftUI

// LA VISTA (V): Lo que ve tu esposa
struct ClientsView: View {
    // Conectamos la vista con su ViewModel
    @StateObject private var viewModel = ClientsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.clients.isEmpty {
                    ProgressView("Cargando clientas...")
                } else if viewModel.clients.isEmpty {
                    ContentUnavailableView(
                        "Sin Clientas",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Aún no has agregado ninguna clienta al sistema.")
                    )
                } else {
                    List(viewModel.clients) { client in
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .font(.headline)
                            Text(client.phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Clientas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Aquí abriremos el formulario más adelante
                        print("Botón de agregar presionado")
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Cuando la vista aparece, le decimos al ViewModel que descargue los datos
            .onAppear {
                viewModel.fetchClientes()
            }
        }
    }
}

#Preview {
    ClientsView()
}
