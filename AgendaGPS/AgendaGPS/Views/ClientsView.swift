import SwiftUI

struct ClientsView: View {
    @StateObject private var viewModel = ClientsViewModel()
    
    @State private var showingAddClient = false
    @State private var clientToEdit: Client?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.clients.isEmpty {
                    ProgressView("Loading clients...")
                } else if viewModel.clients.isEmpty {
                    ContentUnavailableView(
                        "No Clients",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("You haven't added any clients yet.")
                    )
                } else {
                    List {
                        ForEach(viewModel.clients) { client in
                            Button(action: {
                                clientToEdit = client
                            }) {
                                HStack(spacing: 15) {
                                    if let imageUrl = client.imageUrl, let url = URL(string: imageUrl), !imageUrl.isEmpty {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                 .scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(client.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(client.phoneNumber)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: viewModel.deleteClient)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Clients")
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
                AddClientView(viewModel: viewModel)
            }
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
