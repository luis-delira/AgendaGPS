import SwiftUI

struct ClientsView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @State private var showingAddClient = false
    @State private var loyaltyClient: Client? // Clienta cuya tarjeta de fidelidad se muestra

    var body: some View {
        NavigationStack {
            ZStack {
                GirlyBackground()

                Group {
                    if viewModel.isLoading && viewModel.clients.isEmpty {
                        ProgressView("Cargando clientas...")
                            .tint(Theme.primaryPink)
                    } else if viewModel.clients.isEmpty {
                        ContentUnavailableView(
                            "Sin Clientas",
                            systemImage: "person.crop.circle.badge.plus",
                            description: Text("Aún no has agregado ninguna clienta.")
                        )
                        .foregroundColor(Theme.softText)
                    } else {
                        List {
                            ForEach(viewModel.clients) { client in
                                ZStack {
                                    // NavigationLink invisible para quitar la flecha por defecto
                                    NavigationLink(destination: ClientDetailsView(viewModel: viewModel, client: client)) {
                                        EmptyView()
                                    }
                                    .opacity(0)

                                    HStack(spacing: 15) {
                                        ClientImageView(imageUrl: client.imageUrl, size: 55)
                                            .overlay(Circle().stroke(Theme.goldGradient, lineWidth: 2))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(client.name)
                                                .font(.headline)
                                                .foregroundColor(Theme.deepRose)

                                            HStack {
                                                Text(client.phoneNumber)
                                                    .font(.subheadline)
                                                    .foregroundColor(Theme.softText)

                                                if let birthday = client.birthday {
                                                    Text("•")
                                                        .foregroundColor(Theme.softText)

                                                    if client.isBirthdayToday {
                                                        Text("🎂 ¡Hoy!")
                                                            .font(.caption)
                                                            .bold()
                                                            .foregroundColor(Theme.primaryPink)
                                                    } else {
                                                        Text("🎁 \(birthday, format: .dateTime.day().month().year())")
                                                            .font(.caption)
                                                            .foregroundColor(Theme.softText)
                                                    }
                                                }
                                            }
                                        }

                                        Spacer()

                                        // Badge de la tarjeta de fidelidad: muestra los sellos
                                        // y abre la vista de fidelidad al tocarlo
                                        Button(action: { loyaltyClient = client }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "seal.fill")
                                                Text("\(client.stampCount)/\(Client.maxLoyaltyStamps)")
                                            }
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(Theme.gold)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule().fill(Theme.blush)
                                            )
                                            .overlay(
                                                Capsule().stroke(Theme.goldGradient, lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.borderless)

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(Theme.lightPink)
                                    }
                                    .padding()
                                    .girlyCard()
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete(perform: viewModel.deleteClient)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Clientas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primaryPink)
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView(viewModel: viewModel)
            }
            .sheet(item: $loyaltyClient) { client in
                LoyaltyCardView(viewModel: viewModel, client: client)
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
