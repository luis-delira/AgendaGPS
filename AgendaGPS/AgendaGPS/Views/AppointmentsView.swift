import SwiftUI
import UIKit

struct AppointmentsView: View {
    @StateObject private var viewModel = AppointmentsViewModel()
    @State private var showingAddAppointment = false
    @State private var appointmentToEdit: Appointment?
    
    @State private var selectedDate = Date()
    
    var citasFiltradas: [Appointment] {
        viewModel.appointments.filter { appointment in
            Calendar.current.isDate(appointment.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GirlyBackground()

                VStack(spacing: 0) {

                    // --- CALENDARIO MÁGICO EN ESPAÑOL ---
                    CustomCalendarView(selectedDate: $selectedDate, appointments: viewModel.appointments)
                        .padding(8)
                        .girlyCard(cornerRadius: 20)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                    // --- LISTA DE CITAS ---
                    Group {
                        if viewModel.isLoading && viewModel.appointments.isEmpty {
                            Spacer()
                            ProgressView("Cargando agenda...")
                                .tint(Theme.primaryPink)
                            Spacer()
                        } else if citasFiltradas.isEmpty {
                            ContentUnavailableView(
                                "Día Libre",
                                systemImage: "calendar.badge.minus",
                                description: Text("No tienes citas programadas para este día.")
                            )
                            .foregroundColor(Theme.softText)
                        } else {
                            List {
                                ForEach(citasFiltradas) { appointment in
                                    Button(action: {
                                        appointmentToEdit = appointment
                                    }) {
                                        HStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Theme.pinkGradient)
                                                .frame(width: 5)

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(appointment.clientName)
                                                    .font(.headline)
                                                    .foregroundColor(Theme.deepRose)

                                                HStack {
                                                    Text(appointment.serviceName)
                                                        .foregroundColor(Theme.softText)
                                                    Spacer()
                                                    Text("$\(appointment.price, specifier: "%.2f")")
                                                        .bold()
                                                        .foregroundColor(Theme.gold)
                                                }
                                                .font(.subheadline)

                                                HStack {
                                                    Image(systemName: "clock")
                                                    Text(appointment.date, style: .time)
                                                }
                                                .font(.caption)
                                                .foregroundColor(Theme.primaryPink)
                                            }
                                            .padding(.leading, 4)
                                        }
                                        .padding()
                                        .girlyCard()
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        guard let id = citasFiltradas[index].id else { continue }
                                        viewModel.deleteAppointmentById(id: id)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAppointment = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primaryPink)
                    }
                }
            }
            .sheet(isPresented: $showingAddAppointment) {
                AddAppointmentView(viewModel: viewModel)
            }
            .sheet(item: $appointmentToEdit) { appointment in
                EditAppointmentView(viewModel: viewModel, appointment: appointment)
            }
            .onAppear {
                viewModel.fetchAppointments()
            }
        }
    }
}

struct CustomCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    var appointments: [Appointment]
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        
        // FORZAR IDIOMA: Usamos "es_MX" (Español México) para asegurar que siempre esté en español
        calendarView.locale = Locale(identifier: "es_MX")
        
        calendarView.fontDesign = .rounded
        // Tinte rosa para la selección y acentos del calendario
        calendarView.tintColor = Theme.uiAccent

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        calendarView.selectionBehavior = selection
        calendarView.delegate = context.coordinator
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self
        let components = appointments.map { Calendar.current.dateComponents([.year, .month, .day], from: $0.date) }
        uiView.reloadDecorations(forDateComponents: components, animated: true)
        
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            selection.selectedDate = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CustomCalendarView
        
        init(_ parent: CustomCalendarView) {
            self.parent = parent
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectedDate = date
            }
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let hasAppointments = parent.appointments.contains { appointment in
                let aptComponents = Calendar.current.dateComponents([.year, .month, .day], from: appointment.date)
                return aptComponents.year == dateComponents.year &&
                       aptComponents.month == dateComponents.month &&
                       aptComponents.day == dateComponents.day
            }
            
            if hasAppointments {
                return .default(color: Theme.uiAccent, size: .medium)
            }
            return nil
        }
    }
}

#Preview {
    AppointmentsView()
}
