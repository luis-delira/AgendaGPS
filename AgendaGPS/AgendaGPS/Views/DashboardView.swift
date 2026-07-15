import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = AppointmentsViewModel()

    // Recibimos el ViewModel compartido desde el RootView para poder cerrar sesión
    @EnvironmentObject var authViewModel: AuthViewModel

    // 1. Filtro para las citas de HOY
    var citasDeHoy: [Appointment] {
        viewModel.appointments.filter { appointment in
            Calendar.current.isDateInToday(appointment.date)
        }
    }

    // 2. NUEVO: Filtro para las citas de MAÑANA
    var citasDeManana: [Appointment] {
        viewModel.appointments.filter { appointment in
            Calendar.current.isDateInTomorrow(appointment.date)
        }
    }

    // 3. Cálculo de ganancias solo para hoy
    var gananciasDeHoy: Double {
        citasDeHoy.reduce(0) { total, appointment in
            total + appointment.price
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GirlyBackground()

                ScrollView {
                    VStack(spacing: 24) {

                        // --- SECCIÓN: GANANCIAS (tarjeta premium rosa/dorado) ---
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("Ganancias Estimadas Hoy")
                                    .font(.subheadline)
                                    .textCase(.uppercase)
                            }
                            .foregroundColor(.white.opacity(0.9))

                            Text("$\(gananciasDeHoy, specifier: "%.2f")")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(28)
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

                        // --- SECCIÓN: CITAS DE HOY ---
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Citas de Hoy", count: citasDeHoy.count, icon: "heart.fill")

                            if citasDeHoy.isEmpty {
                                ContentUnavailableView(
                                    "Día Libre",
                                    systemImage: "moon.zzz.fill",
                                    description: Text("No tienes citas programadas para hoy.")
                                )
                                .foregroundColor(Theme.softText)
                            } else {
                                ForEach(citasDeHoy) { appointment in
                                    TarjetaCita(appointment: appointment)
                                }
                            }
                        }

                        // --- NUEVA SECCIÓN: CITAS DE MAÑANA ---
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Mañana", count: citasDeManana.count, icon: "calendar")

                            if citasDeManana.isEmpty {
                                Text("No hay citas agendadas para mañana.")
                                    .foregroundColor(Theme.softText)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 20)
                            } else {
                                ForEach(citasDeManana) { appointment in
                                    TarjetaCita(appointment: appointment)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Resumen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.cerrarSesion()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(Theme.primaryPink)
                    }
                }
            }
            .onAppear {
                viewModel.fetchAppointments()
            }
        }
    }
}

// Encabezado de sección con contador tipo "pill" dorado
struct SectionHeader: View {
    var title: String
    var count: Int
    var icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryPink)
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(Theme.deepRose)

            Text("\(count)")
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Capsule().fill(Theme.goldGradient))
        }
        .padding(.horizontal)
    }
}

// NUEVO: Extraje el diseño de la tarjeta a un componente separado
// para no repetir código entre "Hoy" y "Mañana"
struct TarjetaCita: View {
    var appointment: Appointment

    var body: some View {
        HStack {
            // Barra decorativa rosa lateral
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.pinkGradient)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.clientName)
                    .font(.headline)
                    .foregroundColor(Theme.deepRose)
                Text(appointment.serviceName)
                    .font(.subheadline)
                    .foregroundColor(Theme.softText)
            }
            .padding(.leading, 4)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(appointment.date, style: .time)
                    .font(.headline)
                    .foregroundColor(Theme.primaryPink)
                Text("$\(appointment.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(Theme.gold)
            }
        }
        .padding()
        .girlyCard()
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
