import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ถ้าคุณรัน flutterfire configure แล้ว ให้เปิดบรรทัดนี้และใช้ DefaultFirebaseOptions
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ตั้ง true เพื่อแสดงตัวอย่าง "เชื่อมต่อไม่สำเร็จ"
    const bool showFailureDemo = false;

    return MaterialApp(
      title: 'Flutter + Firebase Status',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: showFailureDemo
          ? const FirebaseFailExample()
          : const FirebaseStatusPage(),
    );
  }
}

class FirebaseStatusPage extends StatefulWidget {
  const FirebaseStatusPage({super.key});

  @override
  State<FirebaseStatusPage> createState() => _FirebaseStatusPageState();
}

class _FirebaseStatusPageState extends State<FirebaseStatusPage> {
  late final Future<FirebaseApp> _initFuture = _initializeFirebase();

  Future<FirebaseApp> _initializeFirebase() async {
    try {
      // หากมี firebase_options.dart ให้ใช้แบบนี้แทน:
      // return await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      return await Firebase.initializeApp();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Connection Status')),
      body: Center(
        child: FutureBuilder<FirebaseApp>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text('Firebase initialization failed'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 12),
                Text('Firebase initialized successfully'),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ตัวอย่างบังคับให้ล้มเหลว ด้วย FirebaseOptions ปลอม
class FirebaseFailExample extends StatelessWidget {
  const FirebaseFailExample({super.key});

  Future<FirebaseApp> _initializeWithBadOptions() async {
    const bad = FirebaseOptions(
      apiKey: 'BAD_KEY',
      appId: '1:000000000000:android:badbadbadbadbadb',
      messagingSenderId: '000000000000',
      projectId: 'non-existent-project-123456',
    );

    // พยายาม init ด้วย options ปลอม (อาจไม่ error)
    await Firebase.initializeApp(name: 'bad_instance', options: bad);

    // บังคับให้ล้มเหลวเพื่อเดโมไอคอนกากบาท
    throw Exception('Forced failure for demo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Failure Demo')),
      body: Center(
        child: FutureBuilder<FirebaseApp>(
          future: _initializeWithBadOptions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text('Firebase initialization failed (expected)'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 12),
                Text('Unexpected success (should have failed)'),
              ],
            );
          },
        ),
      ),
    );
  }
}
