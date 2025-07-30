import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
 apiKey: "AIzaSyAiosUVgkDSn_kN8Knhql7LF0Jqv7K2kbQ",
  authDomain: "shotorko-f950b.firebaseapp.com",
  projectId: "shotorko-f950b",
  storageBucket: "shotorko-f950b.firebasestorage.app",
  messagingSenderId: "185098753354",
  appId: "1:185098753354:web:385a6ac8c13802fdff1db3",
  measurementId: "G-6KHDHQ7P4Q"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const firestore = getFirestore(app);
