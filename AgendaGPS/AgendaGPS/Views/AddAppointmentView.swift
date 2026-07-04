import SwiftUI

struct AddAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AppointmentsViewModel
    @StateObject private var clientsViewModel = ClientsViewModel()
    
    @State private var selectedClientId = ""
    @State private var serviceName = ""
    @State private var price: Double? = nil
    @State private var date = Date()
    @State private var notes = ""
    
    // NUEVO: Dos Toggles para controlar las notificaciones
    @State private var avisar24h = true
    @State private var avisar30m = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Client")) {
                    if clientsViewModel.clients.isEmpty {
                        Text("Por favor, agrega clientas primero.")
                            .foregroundColor(.red)
                    } else {
                        Picker("Select Client", selection: $selectedClientId) {
                            Text("Select...").tag("")
                            ForEach(clientsViewModel.clients) { client in
                                Text(client.name).tag(client.id ?? "")
                            }
                        }
                    }
                }
                
                Section(header: Text("Service Details")) {
                    TextField("Service (e.g. Corte, Tinte)", text: $serviceName)
                    
                    TextField("Price", value: $price, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date & Time", selection: $date)
                }
                
                // NUEVO: Sección de Notificaciones
                Section(header: Text("Recordatorios para ti")) {
                    Toggle("Avisarme 24 horas antes", isOn: $avisar24h)
                        .tint(.blue)
                    Toggle("Avisarme 30 min antes", isOn: $avisar30m)
                        .tint(.blue)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let client = clientsViewModel.clients.first(where: { $0.id == selectedClientId }) else { return }
                        
                        let newAppointment = Appointment(
                            clientId: client.id ?? "",
                            clientName: client.name,
                            clientPhone: client.phoneNumber,
                            serviceName: serviceName,
                            price: price ?? 0.0,
                            date: date,
                            notes: notes.isEmpty ? nil : notes
                        )
                        
                        viewModel.addAppointment(appointment: newAppointment)
                        
                        // PROGRAMAMOS LA ALERTA
                        NotificationManager.shared.programarNotificacion(para: newAppointment, avisar24h: avisar24h, avisar30m: avisar30m)
                        
                        dismiss()
                    }
                    .disabled(selectedClientId.isEmpty || serviceName.isEmpty || price == nil)
                }
            }
        }
    }
}
