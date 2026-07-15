import SwiftUI
import PhotosUI
import FirebaseAuth

// Perfil del usuario al estilo WhatsApp: cabecera con foto y nombre
// editables, seguida de secciones agrupadas con filas de información.
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // Para mostrar las estadísticas del negocio
    @StateObject private var clientsViewModel = ClientsViewModel()
    @StateObject private var appointmentsViewModel = AppointmentsViewModel()

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showingNameEditor = false
    @State private var newName = ""

    var displayName: String {
        let name = authViewModel.userSession?.displayName ?? ""
        return name.isEmpty ? "Tu nombre" : name
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GirlyBackground()

                ScrollView {
                    VStack(spacing: 20) {

                        // --- CABECERA DE PERFIL (como WhatsApp) ---
                        HStack(spacing: 16) {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                ZStack(alignment: .bottomTrailing) {
                                    profileImage
                                        .frame(width: 72, height: 72)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Theme.goldGradient, lineWidth: 2))

                                    // Badge de cámara para indicar que la foto es editable
                                    Image(systemName: "camera.fill")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Theme.pinkGradient))
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                }
                            }
                            .task(id: selectedItem) {
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    authViewModel.actualizarFotoPerfil(image)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(displayName)
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Theme.deepRose)

                                Text(authViewModel.userSession?.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.softText)
                            }

                            Spacer()

                            // Botón para editar el nombre
                            Button(action: {
                                newName = authViewModel.userSession?.displayName ?? ""
                                showingNameEditor = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.primaryPink)
                            }
                        }
                        .padding()
                        .girlyCard()
                        .padding(.horizontal)

                        // --- SECCIÓN: MI NEGOCIO ---
                        ProfileSection(title: "Mi negocio") {
                            ProfileRow(icon: "person.2.fill", iconColor: Theme.primaryPink, title: "Clientas", value: "\(clientsViewModel.clients.count)")
                            Divider().padding(.leading, 56)
                            ProfileRow(icon: "calendar", iconColor: Theme.gold, title: "Citas agendadas", value: "\(appointmentsViewModel.appointments.count)")
                        }

                        // --- SECCIÓN: CUENTA ---
                        ProfileSection(title: "Cuenta") {
                            ProfileRow(icon: "envelope.fill", iconColor: Theme.primaryPink, title: "Correo", value: authViewModel.userSession?.email ?? "—")
                            Divider().padding(.leading, 56)

                            // Cerrar sesión en rojo, como las acciones destructivas de WhatsApp
                            Button(action: {
                                authViewModel.cerrarSesion()
                            }) {
                                ProfileRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: "Cerrar sesión", titleColor: .red, showsChevron: true)
                            }
                        }

                        // --- SECCIÓN: INFORMACIÓN ---
                        ProfileSection(title: "Información") {
                            ProfileRow(icon: "sparkles", iconColor: Theme.gold, title: "Versión", value: appVersion)
                        }

                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Perfil")
            .alert("Editar nombre", isPresented: $showingNameEditor) {
                TextField("Tu nombre", text: $newName)
                Button("Guardar") {
                    let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        authViewModel.actualizarNombre(trimmed)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Este nombre se mostrará en tu perfil.")
            }
        }
    }

    // Foto de perfil local o placeholder rosa
    @ViewBuilder
    private var profileImage: some View {
        if let filename = authViewModel.profileImageFilename,
           let uiImage = ImageStorageManager.shared.loadImage(named: filename) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundColor(Theme.lightPink)
        }
    }
}

// Sección agrupada con título, al estilo de los ajustes de WhatsApp
struct ProfileSection<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .bold()
                .textCase(.uppercase)
                .foregroundColor(Theme.softText)
                .padding(.leading, 8)

            VStack(spacing: 0) {
                content
            }
            .girlyCard(cornerRadius: 16)
        }
        .padding(.horizontal)
    }
}

// Fila con ícono en cuadro de color (como WhatsApp), título y valor opcional
struct ProfileRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var titleColor: Color = Theme.deepRose
    var value: String? = nil
    var showsChevron: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(iconColor))

            Text(title)
                .font(.body)
                .foregroundColor(titleColor)

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(Theme.softText)
                    .lineLimit(1)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.lightPink)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
