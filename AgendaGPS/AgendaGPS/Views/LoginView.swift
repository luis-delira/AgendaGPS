import SwiftUI

struct LoginView: View {
    // CAMBIO CLAVE: Recibimos el "Cerebro" (ViewModel) compartido en lugar de crear uno nuevo
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true

    var body: some View {
        ZStack {
            GirlyBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 40)

                    // --- LOGO en círculo con gradiente rosa y aro dorado ---
                    ZStack {
                        Circle()
                            .fill(Theme.pinkGradient)
                            .frame(width: 130, height: 130)
                            .overlay(
                                Circle().stroke(Theme.goldGradient, lineWidth: 3)
                            )
                            .shadow(color: Theme.primaryPink.opacity(0.4), radius: 12, x: 0, y: 6)

                        Image(systemName: "sparkles")
                            .font(.system(size: 55))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 24)

                    Text(isLoginMode ? "Bienvenida" : "Crear Cuenta")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Theme.deepRose)

                    Text("Tu agenda de belleza")
                        .font(.subheadline)
                        .foregroundColor(Theme.softText)
                        .padding(.bottom, 12)

                    // --- CAMPOS ---
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Theme.primaryPink)
                                .frame(width: 24)
                            TextField("Correo electrónico", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .girlyCard(cornerRadius: 14)

                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Theme.primaryPink)
                                .frame(width: 24)
                            SecureField("Contraseña (mínimo 6 caracteres)", text: $password)
                        }
                        .padding()
                        .girlyCard(cornerRadius: 14)
                    }

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
                    }
                    .buttonStyle(GirlyButtonStyle())
                    .opacity((email.isEmpty || password.count < 6) ? 0.5 : 1)
                    .disabled(email.isEmpty || password.count < 6)
                    .padding(.top, 10)

                    Button(action: {
                        isLoginMode.toggle()
                        viewModel.errorMessage = ""
                    }) {
                        Text(isLoginMode ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia sesión")
                            .foregroundColor(Theme.deepRose)
                            .font(.subheadline)
                    }
                    .padding(.top, 15)

                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
