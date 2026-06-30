
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_MDBCzw0uIbynTz9h9OTYXQWMzFlp8vg',
    appId: '1:559505703937:web:0a5cf6b37502c487daec00',
    messagingSenderId: '559505703937',
    projectId: 'parentapp-b5706',
    authDomain: 'parentapp-b5706.firebaseapp.com',
    storageBucket: 'parentapp-b5706.appspot.com',
    measurementId: 'G-1N289C6M6J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR_pVhP1IkUTJ370uCSog2CVLaKULIj78',
    appId: '1:559505703937:android:19a1c7228965821edaec00',
    messagingSenderId: '559505703937',
    projectId: 'parentapp-b5706',
    storageBucket: 'parentapp-b5706.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBo-HfqSpi9y8_CID-B37iTOyKyvwhYtCk',
    appId: '1:559505703937:ios:a43b5d33a0c7ea4edaec00',
    messagingSenderId: '559505703937',
    projectId: 'parentapp-b5706',
    storageBucket: 'parentapp-b5706.appspot.com',
    iosBundleId: 'com.playschool_admin.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBo-HfqSpi9y8_CID-B37iTOyKyvwhYtCk',
    appId: '1:559505703937:ios:e56ac1d584abeaf1daec00',
    messagingSenderId: '559505703937',
    projectId: 'parentapp-b5706',
    storageBucket: 'parentapp-b5706.appspot.com',
    iosBundleId: 'com.playschool_admin.app.RunnerTests',
  );
}
