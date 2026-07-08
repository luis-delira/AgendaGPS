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
        ScrollView {
            VStack(spacing: 24) {
                
                // --- PROFILE IMAGE ---
                if let imageUrl = currentClient.imageUrl, let url = URL(string: imageUrl), !imageUrl.isEmpty {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                        .shadow(radius: 5)
                }
                
                // --- NAME ---
                Text(currentClient.name)
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // --- PHONE ---
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text(currentClient.phoneNumber)
                            .font(.body)
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // --- EMAIL ---
                    if let email = currentClient.email, !email.isEmpty {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text(email)
                                .font(.body)
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // --- BIRTHDAY ---
                    if let birthday = currentClient.birthday {
                        HStack {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.pink)
                                .frame(width: 24)
                            Text(birthday, format: .dateTime.day().month().year())
                                .font(.body)
                            Spacer()
                            if currentClient.isBirthdayToday {
                                Text("🎂 Today!")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // --- NOTES ---
                    if let notes = currentClient.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Notes")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(notes)
                                .font(.body)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // ESTE ES EL BOTÓN QUE AHORA ABRE LA EDICIÓN
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditClientView(viewModel: viewModel, client: currentClient)
        }
    }
}
