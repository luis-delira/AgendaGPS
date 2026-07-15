import Foundation
import FirebaseAuth // Importamos la librería de seguridad
import UIKit
internal import Combine

class AuthViewModel: ObservableObject {
    // Guarda la sesión actual. Si es 'nil', nadie ha iniciado sesión.
    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String = ""

    // Foto de perfil guardada localmente (nombre del archivo en Documents/ClientImages)
    @Published var profileImageFilename: String? = UserDefaults.standard.string(forKey: "profileImageFilename")
    
    init() {
        // Escucha en tiempo real si el usuario inicia o cierra sesión
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.userSession = user
            }
        }
    }
    
    func login(email: String, clave: String) {
        Auth.auth().signIn(withEmail: email, password: clave) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async { self.errorMessage = "" }
            }
        }
    }
    
    func registrarse(email: String, clave: String) {
        Auth.auth().createUser(withEmail: email, password: clave) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async { self.errorMessage = "" }
            }
        }
    }
    
    func cerrarSesion() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }

    // --- PERFIL DEL USUARIO ---

    // Actualiza el nombre visible en Firebase Auth
    func actualizarNombre(_ nombre: String) {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = nombre
        changeRequest.commitChanges { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error actualizando nombre: \(error.localizedDescription)")
                } else {
                    // Reasignamos para que SwiftUI refresque las vistas
                    self?.userSession = Auth.auth().currentUser
                }
            }
        }
    }

    // Guarda la foto de perfil en el almacenamiento local del dispositivo
    func actualizarFotoPerfil(_ image: UIImage) {
        // Borramos la foto anterior para no acumular archivos
        if let old = profileImageFilename {
            ImageStorageManager.shared.deleteImage(named: old)
        }
        let filename = ImageStorageManager.shared.saveImage(image)
        profileImageFilename = filename
        UserDefaults.standard.set(filename, forKey: "profileImageFilename")
    }
}
