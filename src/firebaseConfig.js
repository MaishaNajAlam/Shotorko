import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyA_NFXX6nD7BdTQaWbxIi3EN-l3ONaa7Oc",
  authDomain: "shotorko-950b4.firebaseapp.com",
  projectId: "shotorko-950b4",
  storageBucket: "shotorko-950b4.firebasestorage.app",
  messagingSenderId: "99397302071",
  appId: "1:99397302071:web:2f6c84a46a3fd97c46ccb2"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const firestore = getFirestore(app);