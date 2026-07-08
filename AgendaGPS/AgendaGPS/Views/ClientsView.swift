import SwiftUI

struct ClientsView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @State private var showingAddClient = false
    
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
                            // AHORA USAMOS NAVIGATION LINK PARA IR A LOS DETALLES
                            NavigationLink(destination: ClientDetailsView(viewModel: viewModel, client: client)) {
                                HStack(spacing: 15) {
                                    if let imageUrl = client.imageUrl, let url = URL(string: imageUrl), !imageUrl.isEmpty {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
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
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(client.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            Text(client.phoneNumber)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            if let birthday = client.birthday {
                                                Text("•")
                                                    .foregroundColor(.secondary)
                                                
                                                if client.isBirthdayToday {
                                                    Text("🎂 Today!")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundColor(.pink)
                                                } else {
                                                    Text("🎁 \(birthday, format: .dateTime.day().month().year())")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: viewModel.deleteClient)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Clientas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView(viewModel: viewModel)
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
