import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = AppointmentsViewModel()
    
    // CAMBIO CLAVE: Recibimos el ViewModel compartido desde el RootView
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var citasDeHoy: [Appointment] {
        viewModel.appointments.filter { appointment in
            Calendar.current.isDateInToday(appointment.date)
        }
    }
    
    var gananciasDeHoy: Double {
        citasDeHoy.reduce(0) { total, appointment in
            total + appointment.price
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tus Citas (\(citasDeHoy.count))")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        if citasDeHoy.isEmpty {
                            ContentUnavailableView(
                                "Día Libre",
                                systemImage: "moon.zzz.fill",
                                description: Text("No tienes citas programadas para hoy. ¡A descansar!")
                            )
                        } else {
                            ForEach(citasDeHoy) { appointment in
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
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Resumen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Llamamos a la función de cerrar sesión
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

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
