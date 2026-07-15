import SwiftUI

struct LoyaltyCardView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ClientsViewModel
    var client: Client

    // Obtenemos la versión más reciente de la clienta desde el ViewModel
    // para que los sellos se actualicen en vivo al agregar/quitar
    var currentClient: Client {
        viewModel.clients.first(where: { $0.id == client.id }) ?? client
    }

    var stamps: Int {
        currentClient.stampCount
    }

    var isCardComplete: Bool {
        stamps >= Client.maxLoyaltyStamps
    }

    // 3 columnas para acomodar los 6 sellos en 2 filas
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        NavigationStack {
            ZStack {
                GirlyBackground()

                ScrollView {
                    VStack(spacing: 24) {

                        // --- CLIENTA ---
                        ClientImageView(imageUrl: currentClient.imageUrl, size: 90)
                            .overlay(Circle().stroke(Theme.goldGradient, lineWidth: 3))
                            .shadow(color: Theme.primaryPink.opacity(0.3), radius: 8, x: 0, y: 4)

                        Text(currentClient.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Theme.deepRose)

                        // --- TARJETA CON LOS 6 SELLOS ---
                        VStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("Tarjeta de Fidelidad")
                                    .textCase(.uppercase)
                                Image(systemName: "sparkles")
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white.opacity(0.95))

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(1...Client.maxLoyaltyStamps, id: \.self) { index in
                                    StampCircle(number: index, isStamped: index <= stamps)
                                }
                            }

                            Text("\(stamps) de \(Client.maxLoyaltyStamps) sellos")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Theme.glamGradient)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Theme.goldGradient, lineWidth: 1.5)
                        )
                        .shadow(color: Theme.primaryPink.opacity(0.35), radius: 12, x: 0, y: 6)
                        .padding(.horizontal)

                        // --- PREMIO GANADO ---
                        if isCardComplete {
                            VStack(spacing: 12) {
                                Text("🎁 ¡Premio ganado!")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Theme.deepRose)

                                Text("La clienta completó su tarjeta y merece su premio.")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.softText)
                                    .multilineTextAlignment(.center)

                                Button(action: {
                                    // Al canjear el premio la tarjeta se reinicia
                                    viewModel.setLoyaltyStamps(for: currentClient, stamps: 0)
                                }) {
                                    Text("Canjear premio y reiniciar tarjeta")
                                }
                                .buttonStyle(GirlyButtonStyle())
                            }
                            .padding()
                            .girlyCard()
                            .padding(.horizontal)
                        }

                        // --- BOTONES PARA AGREGAR / QUITAR SELLOS ---
                        VStack(spacing: 12) {
                            Button(action: {
                                viewModel.setLoyaltyStamps(for: currentClient, stamps: stamps + 1)
                            }) {
                                Label("Agregar sello", systemImage: "seal.fill")
                            }
                            .buttonStyle(GirlyButtonStyle())
                            .opacity(isCardComplete ? 0.5 : 1)
                            .disabled(isCardComplete)

                            Button(action: {
                                viewModel.setLoyaltyStamps(for: currentClient, stamps: stamps - 1)
                            }) {
                                Text("Quitar un sello")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.softText)
                            }
                            .disabled(stamps == 0)
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Fidelidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundColor(Theme.primaryPink)
                }
            }
        }
    }
}

// Un sello individual de la tarjeta: corazón rosa si está sellado,
// número en gris rosado si aún está pendiente
struct StampCircle: View {
    var number: Int
    var isStamped: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle().stroke(
                        isStamped ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(Color.white.opacity(0.6)),
                        style: StrokeStyle(lineWidth: 2, dash: isStamped ? [] : [5])
                    )
                )

            if isStamped {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(Theme.primaryPink)
            } else {
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(Theme.lightPink)
            }
        }
        .frame(width: 64, height: 64)
        .shadow(color: Theme.deepRose.opacity(isStamped ? 0.3 : 0), radius: 4, x: 0, y: 2)
        .animation(.spring(duration: 0.3), value: isStamped)
    }
}
