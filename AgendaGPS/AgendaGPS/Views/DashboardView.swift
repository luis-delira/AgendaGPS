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
            ScrollView {
                VStack(spacing: 24) {
                    
                    // --- SECCIÓN: GANANCIAS ---
                    VStack(spacing: 8) {
                        Text("Ganancias Estimadas Hoy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text("$\(gananciasDeHoy, specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // --- SECCIÓN: CITAS DE HOY ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Citas de Hoy (\(citasDeHoy.count))")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        if citasDeHoy.isEmpty {
                            ContentUnavailableView(
                                "Día Libre",
                                systemImage: "moon.zzz.fill",
                                description: Text("No tienes citas programadas para hoy.")
                            )
                        } else {
                            ForEach(citasDeHoy) { appointment in
                                TarjetaCita(appointment: appointment)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // --- NUEVA SECCIÓN: CITAS DE MAÑANA ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Próximamente Mañana (\(citasDeManana.count))")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        if citasDeManana.isEmpty {
                            Text("No hay citas agendadas para mañana.")
                                .foregroundColor(.secondary)
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
            .navigationTitle("Resumen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.cerrarSesion()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                viewModel.fetchAppointments()
            }
        }
    }
}

// NUEVO: Extraje el diseño de la tarjeta a un componente separado
// para no repetir código entre "Hoy" y "Mañana"
struct TarjetaCita: View {
    var appointment: Appointment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.clientName)
                    .font(.headline)
                Text(appointment.serviceName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(appointment.date, style: .time)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("$\(appointment.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
