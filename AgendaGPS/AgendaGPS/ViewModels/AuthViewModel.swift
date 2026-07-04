import Foundation
import FirebaseAuth // Importamos la librería de seguridad
internal import Combine

class AuthViewModel: ObservableObject {
    // Guarda la sesión actual. Si es 'nil', nadie ha iniciado sesión.
    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String = ""
    
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
}
