import SwiftUI

struct EditAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AppointmentsViewModel
    @StateObject private var clientsViewModel = ClientsViewModel()
    
    var appointment: Appointment
    
    @State private var selectedClientId: String
    @State private var serviceName: String
    @State private var price: Double?
    @State private var date: Date
    @State private var notes: String
    
    // MODIFICADO: Dos variables para controlar los recordatorios
    @State private var avisar24h: Bool
    @State private var avisar30m: Bool
    
    init(viewModel: AppointmentsViewModel, appointment: Appointment) {
        self.viewModel = viewModel
        self.appointment = appointment
        
        _selectedClientId = State(initialValue: appointment.clientId)
        _serviceName = State(initialValue: appointment.serviceName)
        _price = State(initialValue: appointment.price)
        _date = State(initialValue: appointment.date)
        _notes = State(initialValue: appointment.notes ?? "")
        _avisar24h = State(initialValue: true)
        _avisar30m = State(initialValue: true)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // --- BOTÓN DE WHATSAPP ---
                Section {
                    Button(action: {
                        viewModel.enviarWhatsApp(appointment: appointment)
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "message.fill")
                            Text("Recordar por WhatsApp")
                                .bold()
                            Spacer()
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.green)
                    .disabled(appointment.clientPhone == nil || appointment.clientPhone?.isEmpty == true)
                }
                
                // --- MODIFICADO: CONFIGURACIÓN DE DOS NOTIFICACIONES ---
                Section(header: Text("Notificaciones de la App")) {
                    Toggle("Avisarme 24 horas antes", isOn: $avisar24h)
                        .tint(Theme.primaryPink)
                    Toggle("Avisarme 30 min antes", isOn: $avisar30m)
                        .tint(Theme.primaryPink)
                }
                
                Section(header: Text("Client")) {
                    if clientsViewModel.clients.isEmpty {
                        Text("Cargando clientas...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Client", selection: $selectedClientId) {
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
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .scrollContentBackground(.hidden)
            .background(GirlyBackground())
            .navigationTitle("Detalles Cita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let client = clientsViewModel.clients.first(where: { $0.id == selectedClientId }) else { return }
                        
                        var updatedAppointment = appointment
                        updatedAppointment.clientId = client.id ?? ""
                        updatedAppointment.clientName = client.name
                        updatedAppointment.clientPhone = client.phoneNumber
                        updatedAppointment.serviceName = serviceName
                        updatedAppointment.price = price ?? 0.0
                        updatedAppointment.date = date
                        updatedAppointment.notes = notes.isEmpty ? nil : notes
                        
                        viewModel.updateAppointment(appointment: updatedAppointment)
                        
                        // MODIFICADO: Actualizamos las notificaciones con las nuevas preferencias
                        if avisar24h || avisar30m {
                            NotificationManager.shared.programarNotificacion(para: updatedAppointment, avisar24h: avisar24h, avisar30m: avisar30m)
                        } else if let id = updatedAppointment.id {
                            NotificationManager.shared.cancelarNotificacion(id: id)
                        }
                        
                        dismiss()
                    }
                    .disabled(selectedClientId.isEmpty || serviceName.isEmpty || price == nil)
                }
            }
        }
    }
}
