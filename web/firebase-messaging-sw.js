importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAMJZr8t4l3XVt-KN5CMdEgUct1CqukC_0",
  authDomain: "wesal-6a246.firebaseapp.com",
  projectId: "wesal-6a246",
  storageBucket: "wesal-6a246.firebasestorage.app",
  messagingSenderId: "258782339328",
  appId: "1:258782339328:web:858d389346d4252da8d3e5",
  measurementId: "G-10058DZCGM"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
