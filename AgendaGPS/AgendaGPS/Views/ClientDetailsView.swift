import SwiftUI

struct ClientDetailsView: View {
    @ObservedObject var viewModel: ClientsViewModel
    var client: Client

    @State private var showingEditSheet = false

    // Obtenemos la versión más reciente de la clienta desde el ViewModel
    // para que la vista se actualice automáticamente si la editas
    var currentClient: Client {
        viewModel.clients.first(where: { $0.id == client.id }) ?? client
    }

    var body: some View {
        ZStack {
            GirlyBackground()

            ScrollView {
                VStack(spacing: 24) {

                    // --- PROFILE IMAGE con aro dorado ---
                    Group {
                        if let imageUrl = currentClient.imageUrl, let url = URL(string: imageUrl), !imageUrl.isEmpty {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 130, height: 130)
                                .foregroundColor(Theme.lightPink)
                        }
                    }
                    .overlay(Circle().stroke(Theme.goldGradient, lineWidth: 3))
                    .shadow(color: Theme.primaryPink.opacity(0.3), radius: 10, x: 0, y: 5)

                    // --- NAME ---
                    Text(currentClient.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Theme.deepRose)

                    VStack(alignment: .leading, spacing: 16) {

                        // --- PHONE ---
                        InfoRow(icon: "phone.fill", text: currentClient.phoneNumber)

                        // --- EMAIL ---
                        if let email = currentClient.email, !email.isEmpty {
                            InfoRow(icon: "envelope.fill", text: email)
                        }

                        // --- BIRTHDAY ---
                        if let birthday = currentClient.birthday {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(Theme.primaryPink)
                                    .frame(width: 24)
                                Text(birthday, format: .dateTime.day().month().year())
                                    .font(.body)
                                    .foregroundColor(Theme.deepRose)
                                Spacer()
                                if currentClient.isBirthdayToday {
                                    Text("🎂 ¡Hoy!")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(Theme.primaryPink)
                                }
                            }
                            .padding()
                            .girlyCard(cornerRadius: 14)
                        }

                        // --- NOTES ---
                        if let notes = currentClient.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notas adicionales")
                                    .font(.headline)
                                    .foregroundColor(Theme.gold)
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(Theme.softText)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .girlyCard(cornerRadius: 14)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Detalles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // ESTE ES EL BOTÓN QUE AHORA ABRE LA EDICIÓN
                Button("Editar") {
                    showingEditSheet = true
                }
                .foregroundColor(Theme.primaryPink)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditClientView(viewModel: viewModel, client: currentClient)
        }
    }
}

// Fila de información con ícono rosa y tarjeta blanca
struct InfoRow: View {
    var icon: String
    var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryPink)
                .frame(width: 24)
            Text(text)
                .font(.body)
                .foregroundColor(Theme.deepRose)
            Spacer()
        }
        .padding()
        .girlyCard(cornerRadius: 14)
    }
}
