# 💅 AgendaGPS

**Tu agenda de belleza.** AgendaGPS es una app para iOS hecha con SwiftUI para que profesionales de la belleza (uñas, pestañas, estética, etc.) administren sus clientas, citas, recordatorios y tarjetas de fidelidad desde el iPhone.

![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0D96F6?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-26.5%2B-000000?logo=apple&logoColor=white)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)
![Arquitectura](https://img.shields.io/badge/Arquitectura-MVVM-8A2BE2)

<!-- Agrega aquí capturas de pantalla, por ejemplo:
<p align="center">
  <img src="docs/screenshots/resumen.png" width="200" />
  <img src="docs/screenshots/agenda.png" width="200" />
  <img src="docs/screenshots/clientas.png" width="200" />
  <img src="docs/screenshots/fidelidad.png" width="200" />
</p>
-->

---

## ✨ Funcionalidades

### 📊 Resumen (Dashboard)
- Ganancias estimadas del día, calculadas a partir del precio de las citas de hoy.
- Lista de citas de **hoy** y de **mañana** de un vistazo.

### 📅 Agenda
- Crear, editar y eliminar citas (cliente, servicio, precio, fecha/hora y notas).
- Recordatorios locales configurables por cita: **24 horas antes** y/o **30 minutos antes**.
- Botón **"Recordar por WhatsApp"** que abre WhatsApp con un mensaje de recordatorio ya redactado para la clienta.

### 👩 Clientas
- Directorio de clientas con nombre, teléfono, correo, notas y foto de perfil.
- Fecha de cumpleaños opcional, con indicador **🎂 ¡Hoy!** y notificación anual a las 9:00 AM.
- Deslizar para eliminar.
- Si cambias el nombre de una clienta, se actualiza automáticamente en todas sus citas.

### 🎁 Tarjeta de fidelidad
- Tarjeta digital de **6 sellos** por clienta.
- Agregar o quitar sellos y canjear el premio para reiniciar la tarjeta.

### 🔔 Notificaciones
- Vista con todas las alertas programadas (citas y cumpleaños), ordenadas por fecha.

### 👤 Perfil
- Inicio de sesión y registro con correo y contraseña.
- Nombre visible y foto de perfil editables.
- Cerrar sesión.

### 🎨 Diseño
- Sistema de diseño propio en rosa, dorado y blanco (`Theme.swift`), con tarjetas, botones y fondos reutilizables.
- Compatible con el estilo *Liquid Glass* de iOS 26.

---

## 🛠️ Tecnologías

| Área | Tecnología |
|---|---|
| Lenguaje | Swift 5 |
| UI | SwiftUI, PhotosUI |
| Arquitectura | MVVM (`ObservableObject` + Combine) |
| Autenticación | Firebase Authentication (correo/contraseña) |
| Base de datos | Cloud Firestore (sincronización en tiempo real con *snapshot listeners*) |
| Notificaciones | UserNotifications (notificaciones locales) |
| Imágenes | Almacenamiento local en el dispositivo (`Documents/ClientImages`) |
| Dependencias | Swift Package Manager — [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk) 12.15+ |

---

## 📁 Estructura del proyecto

```
AgendaGPS/
└── AgendaGPS/
    ├── App/            # Punto de entrada (AgendaGPSApp) y configuración de Firebase
    ├── Models/         # Client, Appointment
    ├── ViewModels/     # AuthViewModel, ClientsViewModel, AppointmentsViewModel
    ├── Views/          # Pantallas SwiftUI (Dashboard, Agenda, Clientas, Fidelidad, Perfil…)
    └── Utils/          # Theme, NotificationManager, ImageStorageManager
```

### Modelo de datos (Firestore)

**`clients`**

| Campo | Tipo | Descripción |
|---|---|---|
| `name` | String | Nombre de la clienta |
| `phoneNumber` | String | Teléfono (usado para WhatsApp) |
| `email` | String? | Correo electrónico |
| `notes` | String? | Notas |
| `imageUrl` | String? | Nombre del archivo de la foto guardada localmente |
| `birthday` | Date? | Fecha de cumpleaños |
| `loyaltyStamps` | Int? | Sellos de fidelidad (0–6) |

**`appointments`**

| Campo | Tipo | Descripción |
|---|---|---|
| `clientId` | String | ID de la clienta |
| `clientName` | String | Nombre de la clienta (desnormalizado) |
| `clientPhone` | String? | Teléfono de la clienta |
| `serviceName` | String | Servicio |
| `price` | Double | Precio |
| `date` | Date | Fecha y hora |
| `notes` | String? | Notas |

---

## 🚀 Cómo ejecutar el proyecto

### Requisitos
- macOS con **Xcode 26** o superior
- iOS **26.5+** (simulador o dispositivo)
- Un proyecto de [Firebase](https://console.firebase.google.com/)

### Pasos

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/luis-delira/AgendaGPS.git
   ```

2. **Configura Firebase**
   - Crea un proyecto en Firebase y agrega una app iOS con el *bundle identifier* del proyecto.
   - En **Authentication**, habilita el proveedor **Correo electrónico/contraseña**.
   - Crea una base de datos **Cloud Firestore**.
   - Descarga tu `GoogleService-Info.plist` y colócalo en `AgendaGPS/AgendaGPS/App/`.

3. **Abre el proyecto en Xcode**
   ```bash
   open AgendaGPS/AgendaGPS.xcodeproj
   ```
   Xcode descargará automáticamente las dependencias de Firebase con Swift Package Manager.

4. **Ejecuta** la app con `⌘R` en un simulador o en tu iPhone. Acepta el permiso de notificaciones para recibir los recordatorios.

---

## 🗺️ Próximas mejoras

- [ ] Separar los datos por usuario en Firestore (`users/{uid}/clients`, `users/{uid}/appointments`) y agregar reglas de seguridad.
- [ ] Sincronizar las fotos de las clientas entre dispositivos.
- [ ] Reportes de ganancias semanales y mensuales.
- [ ] Catálogo de servicios con precios predefinidos.

---

## 👨‍💻 Autor

**Luis De Lira**

¿Sugerencias o comentarios? Abre un *issue* o envía un *pull request*. 💖
