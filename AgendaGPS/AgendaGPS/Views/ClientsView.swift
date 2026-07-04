import SwiftUI

struct ClientsView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @State private var showingAddClient = false
    
    // NUEVA VARIABLE: Guarda a la clienta que seleccionamos para editar
    @State private var clientToEdit: Client?
    
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
                    List {
                        ForEach(viewModel.clients) { client in
                            // Envolvemos el texto en un Button para detectar el toque
                            Button(action: {
                                clientToEdit = client
                            }) {
                                VStack(alignment: .leading) {
                                    Text(client.name)
                                        .font(.headline)
                                        .foregroundColor(.primary) // Mantiene el color original
                                    Text(client.phoneNumber)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteClient)
                    }
                }
            }
            .navigationTitle("Clientas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddClient = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientsView(viewModel: viewModel)
            }
            // NUEVO SHEET: Se activa si tocamos a una clienta
            .sheet(item: $clientToEdit) { client in
                EditClientView(viewModel: viewModel, client: client)
            }
            .onAppear {
                viewModel.fetchClients()
            }
        }
    }
}

#Preview {
    ClientsView()
}
