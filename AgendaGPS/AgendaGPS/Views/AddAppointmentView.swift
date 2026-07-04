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
    
    // NUEVO: Variable para el interruptor de notificación, por defecto encendido
    @State private var recordatorioActivo = true
    
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
                
                // NUEVO: La sección para activar la notificación al crear la cita
                Section(header: Text("Notificaciones de la App")) {
                    Toggle("Avisarme 30 min antes", isOn: $recordatorioActivo)
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
                        // 1. Buscamos a la clienta seleccionada
                        guard let client = clientsViewModel.clients.first(where: { $0.id == selectedClientId }) else { return }
                        
                        // 2. Creamos la cita
                        let newAppointment = Appointment(
                            clientId: client.id ?? "",
                            clientName: client.name,
                            clientPhone: client.phoneNumber,
                            serviceName: serviceName,
                            price: price ?? 0.0,
                            date: date,
                            notes: notes.isEmpty ? nil : notes
                        )
                        
                        // 3. Guardamos en Firebase
                        viewModel.addAppointment(appointment: newAppointment)
                        
                        // 4. NUEVO: Si dejó encendido el switch, programamos la notificación
                        if recordatorioActivo {
                            NotificationManager.shared.programarNotificacion(para: newAppointment)
                        }
                        
                        dismiss()
                    }
                    .disabled(selectedClientId.isEmpty || serviceName.isEmpty || price == nil)
                }
            }
        }
    }
}
