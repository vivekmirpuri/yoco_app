// Import the functions you need from the SDKs you need
// Note: In a browser environment, use CDN scripts or ensure these are bundled by your build tool.
// For direct browser use, see the HTML changes below.

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCsQ0bB9zNSNwXHyHpDXawG8xrDvlGXYWM",
  authDomain: "yoco-76ae7.firebaseapp.com",
  projectId: "yoco-76ae7",
  storageBucket: "yoco-76ae7.firebasestorage.app",
  messagingSenderId: "862521546862",
  appId: "1:862521546862:web:dbe59081fbfafbc8b26e7f",
  measurementId: "G-5TSYW48SBH"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
if (firebase.analytics) {
  firebase.analytics();
} 