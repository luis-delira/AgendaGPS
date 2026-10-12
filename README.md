# 💅 AgendaGPS

**Your beauty appointment book.** AgendaGPS is an iOS app built with SwiftUI that helps beauty professionals (nails, lashes, skincare, etc.) manage their clients, appointments, reminders and loyalty cards right from their iPhone.

> The app's interface is in Spanish.

![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0D96F6?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-26.5%2B-000000?logo=apple&logoColor=white)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-8A2BE2)

<!-- Add screenshots here, for example:
<p align="center">
  <img src="docs/screenshots/dashboard.png" width="200" />
  <img src="docs/screenshots/agenda.png" width="200" />
  <img src="docs/screenshots/clients.png" width="200" />
  <img src="docs/screenshots/loyalty.png" width="200" />
</p>
-->

---

## ✨ Features

### 📊 Dashboard (Resumen)
- Estimated earnings for the day, calculated from the price of today's appointments.
- **Today's** and **tomorrow's** appointments at a glance.

### 📅 Agenda
- Create, edit and delete appointments (client, service, price, date/time and notes).
- Configurable local reminders per appointment: **24 hours before** and/or **30 minutes before**.
- **"Remind via WhatsApp"** button that opens WhatsApp with a pre-written reminder message for the client.

### 👩 Clients (Clientas)
- Client directory with name, phone, email, notes and profile photo.
- Optional birthday, with a **🎂 Today!** badge and a yearly notification at 9:00 AM.
- Swipe to delete.
- Renaming a client automatically updates the name on all of their appointments.

### 🎁 Loyalty card (Fidelidad)
- Digital **6-stamp** loyalty card per client.
- Add or remove stamps, and redeem the reward to reset the card.

### 🔔 Notifications (Notificaciones)
- List of every scheduled alert (appointments and birthdays), sorted by date.

### 👤 Profile (Perfil)
- Email and password sign-in and sign-up.
- Editable display name and profile photo.
- Sign out.

### 🎨 Design
- Custom pink, gold and white design system (`Theme.swift`) with reusable cards, buttons and backgrounds.
- Compatible with iOS 26's *Liquid Glass* style.

---

## 🛠️ Tech stack

| Area | Technology |
|---|---|
| Language | Swift 5 |
| UI | SwiftUI, PhotosUI |
| Architecture | MVVM (`ObservableObject` + Combine) |
| Authentication | Firebase Authentication (email/password) |
| Database | Cloud Firestore (real-time sync with snapshot listeners) |
| Notifications | UserNotifications (local notifications) |
| Images | On-device local storage (`Documents/ClientImages`) |
| Dependencies | Swift Package Manager — [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk) 12.15+ |

---

## 📁 Project structure

```
AgendaGPS/
└── AgendaGPS/
    ├── App/            # Entry point (AgendaGPSApp) and Firebase setup
    ├── Models/         # Client, Appointment
    ├── ViewModels/     # AuthViewModel, ClientsViewModel, AppointmentsViewModel
    ├── Views/          # SwiftUI screens (Dashboard, Agenda, Clients, Loyalty, Profile…)
    └── Utils/          # Theme, NotificationManager, ImageStorageManager
```

### Data model (Firestore)

**`clients`**

| Field | Type | Description |
|---|---|---|
| `name` | String | Client's name |
| `phoneNumber` | String | Phone number (used for WhatsApp) |
| `email` | String? | Email address |
| `notes` | String? | Notes |
| `imageUrl` | String? | File name of the locally stored photo |
| `birthday` | Date? | Birthday |
| `loyaltyStamps` | Int? | Loyalty stamps (0–6) |

**`appointments`**

| Field | Type | Description |
|---|---|---|
| `clientId` | String | Client ID |
| `clientName` | String | Client's name (denormalized) |
| `clientPhone` | String? | Client's phone number |
| `serviceName` | String | Service |
| `price` | Double | Price |
| `date` | Date | Date and time |
| `notes` | String? | Notes |

---

## 🚀 Getting started

### Requirements
- macOS with **Xcode 26** or later
- iOS **26.5+** (simulator or device)
- A [Firebase](https://console.firebase.google.com/) project

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/luis-delira/AgendaGPS.git
   ```

2. **Set up Firebase**
   - Create a Firebase project and add an iOS app using the project's bundle identifier.
   - In **Authentication**, enable the **Email/Password** provider.
   - Create a **Cloud Firestore** database.
   - Download your `GoogleService-Info.plist` and place it in `AgendaGPS/AgendaGPS/App/`.

3. **Open the project in Xcode**
   ```bash
   open AgendaGPS/AgendaGPS.xcodeproj
   ```
   Xcode will automatically fetch the Firebase dependencies through Swift Package Manager.

4. **Run** the app with `⌘R` on a simulator or your iPhone. Allow notifications to receive reminders.

---

## 🗺️ Roadmap

- [ ] Scope data per user in Firestore (`users/{uid}/clients`, `users/{uid}/appointments`) and add security rules.
- [ ] Sync client photos across devices.
- [ ] Weekly and monthly earnings reports.
- [ ] Service catalog with preset prices.

---

## 👨‍💻 Author

**Luis De Lira**

Suggestions or feedback? Open an issue or send a pull request. 💖
