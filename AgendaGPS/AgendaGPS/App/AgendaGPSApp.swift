import SwiftUI
import FirebaseCore // Importamos Firebase

// 1. El AppDelegate para configurar Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("¡Firebase configurado exitosamente!")
        return true
    }
}

// 2. Tu punto de entrada principal
@main
struct AgendaGPSApp: App {
    // Conectamos el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView() // Esta es la vista por defecto que te creó Xcode
        }
    }
}
