import SwiftUI
import PhotosUI

struct EditClientView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ClientsViewModel
    var client: Client
    
    @State private var name: String
    @State private var phoneNumber: String
    @State private var email: String
    @State private var notes: String
    
    // NEW: Birthday variables
    @State private var includeBirthday: Bool
    @State private var birthday: Date
    
    @State private var existingImageUrl: String?
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    
    init(viewModel: ClientsViewModel, client: Client) {
        self.viewModel = viewModel
        self.client = client
        _name = State(initialValue: client.name)
        _phoneNumber = State(initialValue: client.phoneNumber)
        _email = State(initialValue: client.email ?? "")
        _notes = State(initialValue: client.notes ?? "")
        _existingImageUrl = State(initialValue: client.imageUrl)
        
        // NEW: Load existing birthday
        _includeBirthday = State(initialValue: client.birthday != nil)
        _birthday = State(initialValue: client.birthday ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            if let selectedImage {
                                Image(uiImage: selectedImage).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle())
                            } else if let imageUrl = existingImageUrl, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in image.resizable().scaledToFill() } placeholder: { ProgressView() }
                                .frame(width: 100, height: 100).clipShape(Circle())
                            } else {
                                VStack {
                                    Image(systemName: "camera.circle.fill").resizable().frame(width: 80, height: 80).foregroundColor(.blue)
                                    Text("Change Photo").font(.caption)
                                }
                            }
                        }
                        .task(id: selectedItem) {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Phone", text: $phoneNumber).keyboardType(.phonePad)
                    TextField("Email (Optional)", text: $email).keyboardType(.emailAddress).autocapitalization(.none)
                }
                
                // --- NEW: BIRTHDAY SECTION ---
                Section(header: Text("Birthday")) {
                    Toggle("Add Birthday", isOn: $includeBirthday)
                    if includeBirthday {
                        DatePicker("Date", selection: $birthday, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes).frame(height: 100)
                }
            }
            .navigationTitle("Edit Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.disabled(isUploading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isUploading ? "Uploading..." : "Save") {
                        isUploading = true
                        var updatedClient = client
                        updatedClient.name = name
                        updatedClient.phoneNumber = phoneNumber
                        updatedClient.email = email.isEmpty ? nil : email
                        updatedClient.notes = notes.isEmpty ? nil : notes
                        updatedClient.birthday = includeBirthday ? birthday : nil // Update birthday
                        
                        if let image = selectedImage {
                            viewModel.uploadImage(image: image) { uploadedUrl in
                                updatedClient.imageUrl = uploadedUrl
                                viewModel.updateClient(client: updatedClient)
                                isUploading = false
                                dismiss()
                            }
                        } else {
                            updatedClient.imageUrl = existingImageUrl
                            viewModel.updateClient(client: updatedClient)
                            isUploading = false
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty || isUploading)
                }
            }
        }
    }
}
