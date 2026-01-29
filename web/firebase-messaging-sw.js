importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyB2ey94Y5vj1SOhp7VqCP9cfObGAfMB0Lk",
    authDomain: "edirectory-ecfcf.firebaseapp.com",
    projectId: "edirectory-ecfcf",
    storageBucket: "edirectory-ecfcf.firebasestorage.app",
    messagingSenderId: "531362834016",
    appId: "1:531362834016:web:610064c5dfcb033321c505"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
