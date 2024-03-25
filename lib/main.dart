import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

final firebaseinitializerProvider = FutureProvider<FirebaseApp>((ref) async {
  return await Firebase.initializeApp();
});

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialize = ref.watch(firebaseinitializerProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: initialize.when(
          data: (data) {
            return const AuthChecker();
          },
          loading: () => SizedBox.shrink(),
          error: (e, stackTrace) => SizedBox.shrink(),
        ));
  }
}
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Tact Tik',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         textTheme: GoogleFonts.poppinsTextTheme(
//           Theme.of(context).textTheme,
//         ),
//       ),
//       home: GetStartedScreens(),
//     );
//   }
// }
