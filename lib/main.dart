import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'screens/user/analytics_page.dart';
import 'screens/user/irrigation_page.dart';
import 'screens/user/settings_page.dart';
import 'screens/user/profile_page.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'widgets/weather_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyAppWithTheme());
}

class MyAppWithTheme extends StatefulWidget {
  @override
  State<MyAppWithTheme> createState() => _MyAppWithThemeState();
}

class _MyAppWithThemeState extends State<MyAppWithTheme> {
  final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ThemeNotifier(
      isDarkMode: isDarkMode,
      child: ValueListenableBuilder<bool>(
        valueListenable: isDarkMode,
        builder: (context, dark, _) {
          return MaterialApp(
            title: 'Agrosmart',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                primary: Colors.green[800]!,
                secondary: Colors.brown[400]!,
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              scaffoldBackgroundColor: dark
                  ? Colors.grey[900]
                  : Colors.green[50],
              appBarTheme: AppBarTheme(
                backgroundColor: dark
                    ? Colors.grey[850]
                    : const Color(0xFF388E3C),
                foregroundColor: Colors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: dark ? Colors.grey[800] : Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/user-dashboard': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final lastName = args != null && args['lastName'] != null
                    ? args['lastName'] as String
                    : '';
                final navIndex = args != null && args['navIndex'] != null
                    ? args['navIndex'] as int
                    : 0;
                return UserDashboardScaffold(
                  lastName: lastName,
                  currentIndex: navIndex,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'Welcome, $lastName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Weather widget below welcome
                        SizedBox(
                          width: double.infinity,
                          child: WeatherWidget(),
                        ),
                      ],
                    ),
                  ),
                );
              },
              '/analytics': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final lastName = args != null && args['lastName'] != null
                    ? args['lastName'] as String
                    : '';
                final navIndex = args != null && args['navIndex'] != null
                    ? args['navIndex'] as int
                    : 1;
                return AnalyticsPage(lastName: lastName, navIndex: navIndex);
              },
              '/irrigation': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final lastName = args != null && args['lastName'] != null
                    ? args['lastName'] as String
                    : '';
                final navIndex = args != null && args['navIndex'] != null
                    ? args['navIndex'] as int
                    : 2;
                return IrrigationPage(lastName: lastName, navIndex: navIndex);
              },
              '/settings': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final lastName = args != null && args['lastName'] != null
                    ? args['lastName'] as String
                    : '';
                final navIndex = args != null && args['navIndex'] != null
                    ? args['navIndex'] as int
                    : 3;
                return SettingsPage(lastName: lastName, navIndex: navIndex);
              },
              '/profile': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final lastName = args != null && args['lastName'] != null
                    ? args['lastName'] as String
                    : '';
                final navIndex = args != null && args['navIndex'] != null
                    ? args['navIndex'] as int
                    : 4;
                return ProfilePage(lastName: lastName, navIndex: navIndex);
              },
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrosmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green[800]!,
          secondary: Colors.brown[400]!,
        ),
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF388E3C),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/user-dashboard': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final lastName = args != null && args['lastName'] != null
              ? args['lastName'] as String
              : '';
          return UserDashboardScaffold(
            lastName: lastName,
            currentIndex: 0,
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Welcome, Mr. ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        lastName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22c55e),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // ...dashboard cards and widgets can be added here...
              ],
            ),
          );
        },
        '/analytics': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final lastName = args != null && args['lastName'] != null
              ? args['lastName'] as String
              : '';
          return AnalyticsPage(lastName: lastName);
        },
        '/irrigation': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final lastName = args != null && args['lastName'] != null
              ? args['lastName'] as String
              : '';
          return IrrigationPage(lastName: lastName);
        },
        '/settings': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final lastName = args != null && args['lastName'] != null
              ? args['lastName'] as String
              : '';
          return SettingsPage(lastName: lastName);
        },
        '/profile': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final lastName = args != null && args['lastName'] != null
              ? args['lastName'] as String
              : '';
          return ProfilePage(lastName: lastName);
        },
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
