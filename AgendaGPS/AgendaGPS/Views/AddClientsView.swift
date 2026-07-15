import SwiftUI
import PhotosUI
internal import Combine

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ClientsViewModel
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var notes = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                VStack {
                                    Image(systemName: "camera.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(Theme.primaryPink)
                                    Text("Agregar foto")
                                        .font(.caption)
                                        .foregroundColor(Theme.softText)
                                }
                            }
                        }
                        .task(id: selectedItem) {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Phone", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email (Optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .scrollContentBackground(.hidden)
            .background(GirlyBackground())
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isUploading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isUploading ? "Uploading..." : "Save") {
                        isUploading = true
                        
                        if let image = selectedImage {
                            viewModel.uploadImage(image: image) { uploadedUrl in
                                let newClient = Client(
                                    name: name,
                                    phoneNumber: phoneNumber,
                                    email: email,
                                    notes: notes.isEmpty ? nil : notes,
                                    imageUrl: uploadedUrl
                                )
                                viewModel.addClient(client: newClient)
                                isUploading = false
                                dismiss()
                            }
                        } else {
                            let newClient = Client(
                                name: name,
                                phoneNumber: phoneNumber,
                                email: email,
                                notes: notes.isEmpty ? nil : notes,
                                imageUrl: nil
                            )
                            viewModel.addClient(client: newClient)
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
