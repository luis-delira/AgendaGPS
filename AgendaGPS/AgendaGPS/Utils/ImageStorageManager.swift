import SwiftUI
import UIKit

/// Guarda, carga y elimina las fotos de perfil de las clientas en el
/// almacenamiento local del dispositivo (carpeta Documents/ClientImages).
/// En Firestore solo se guarda el nombre del archivo.
struct ImageStorageManager {
    static let shared = ImageStorageManager()

    private let folderName = "ClientImages"

    // Carpeta Documents/ClientImages (se crea si no existe)
    private var folderURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let folder = documents.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    /// Guarda la imagen como JPEG y devuelve el nombre de archivo generado.
    func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let folder = folderURL else { return nil }

        let filename = "\(UUID().uuidString).jpg"
        do {
            try data.write(to: folder.appendingPathComponent(filename))
            return filename
        } catch {
            print("Error guardando imagen local: \(error.localizedDescription)")
            return nil
        }
    }

    /// Carga una imagen guardada previamente a partir de su nombre de archivo.
    func loadImage(named filename: String) -> UIImage? {
        guard let folder = folderURL else { return nil }
        return UIImage(contentsOfFile: folder.appendingPathComponent(filename).path)
    }

    /// Elimina el archivo de imagen del dispositivo.
    func deleteImage(named filename: String) {
        guard let folder = folderURL else { return }
        try? FileManager.default.removeItem(at: folder.appendingPathComponent(filename))
    }
}

/// Muestra la foto de perfil de una clienta.
/// - Si `imageUrl` es un nombre de archivo, la carga del almacenamiento local.
/// - Si es una URL http (fotos antiguas en Hostinger), la descarga con AsyncImage.
/// - Si no hay foto, muestra un placeholder rosa.
struct ClientImageView: View {
    var imageUrl: String?
    var size: CGFloat

    var body: some View {
        Group {
            if let imageUrl, !imageUrl.isEmpty {
                if imageUrl.hasPrefix("http"), let url = URL(string: imageUrl) {
                    // Compatibilidad: imágenes antiguas subidas a Hostinger
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else if let uiImage = ImageStorageManager.shared.loadImage(named: imageUrl) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholder
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundColor(Theme.lightPink)
    }
}
