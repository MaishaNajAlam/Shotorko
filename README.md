# Shotorko 🚨  
**A Personal Safety and Emergency Alert System**  
_My First App – Built with Flutter_

## 📱 Overview

**Shotorko** is a real-time emergency alert application designed to enhance personal safety in critical situations like stalking, pickpocketing, or medical emergencies. With a single tap, users can instantly send alerts to nearby users, emergency contacts, and law enforcement, sharing real-time location and other vital details.

This is our first full-stack mobile application developed using **Flutter**, integrated with **Firebase** for backend services such as authentication, real-time database, cloud messaging, and Firestore storage.

---

## 🔧 Features

- 🚨 **One-Tap Emergency Alert**: Instantly notify nearby users and emergency contacts.
- 📍 **Real-Time Location Sharing**: Send precise location of the incident.
- 👮 **Police Interface Support**: Role-based access for police to view and respond to alerts.
- 📲 **Push Notifications**: Receive emergency alerts via Firebase Cloud Messaging (FCM).
- 🗺️ **Google Maps Integration**: Visualize user locations on the map.
- 📞 **Emergency Call Support**: Call emergency numbers directly from the app.
- 🔐 **User Authentication**: Secure login and role-based access control via Firebase Auth.

---

## 🚀 Getting Started

Follow these instructions to set up and run the project locally.

### Prerequisites

- Flutter SDK (≥ 3.x.x)
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code
- Firebase Project with necessary configurations (see below)

### Firebase Setup

1. Create a Firebase project from [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password or other methods as needed).
3. Enable **Cloud Firestore**, **Firebase Cloud Messaging**, and **Storage**.
4. Download the `google-services.json` file and place it in the `android/app` directory.
5. (Optional) Configure Firebase Security Rules according to roles (`user`, `police`).


