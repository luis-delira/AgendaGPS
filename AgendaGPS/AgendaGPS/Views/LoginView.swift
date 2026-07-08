import SwiftUI

struct LoginView: View {
    // CAMBIO CLAVE: Recibimos el "Cerebro" (ViewModel) compartido en lugar de crear uno nuevo
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "scissors.badge.ellipsis")
                .font(.system(size: 80))
                .foregroundColor(Theme.accent) // Color rosa en lugar de azul
                .padding(.bottom, 32)
            
            Text(isLoginMode ? "Bienvenida" : "Crear Cuenta")
                .font(.largeTitle)
                .bold()
            
            TextField("Correo electrónico", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            
            SecureField("Contraseña (mínimo 6 caracteres)", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                if isLoginMode {
                    viewModel.login(email: email, clave: password)
                } else {
                    viewModel.registrarse(email: email, clave: password)
                }
            }) {
                Text(isLoginMode ? "Iniciar Sesión" : "Registrarse")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent) // Color rosa en lugar de azul
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            .disabled(email.isEmpty || password.count < 6)
            
            Button(action: {
                isLoginMode.toggle()
                viewModel.errorMessage = ""
            }) {
                Text(isLoginMode ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia sesión")
                    .foregroundColor(Theme.accent) // Color rosa en lugar de azul
                    .font(.subheadline)
            }
            .padding(.top, 15)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
