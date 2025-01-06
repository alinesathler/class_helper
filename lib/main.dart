import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/institutions_screen.dart';
import "shared/colors.dart";
import 'screens/programs_screen.dart';
import 'models/institution.dart';
import 'models/program.dart';
import 'models/term.dart';
import 'models/course.dart';
import 'models/class.dart';
import 'models/assignment.dart';

// Entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future.delayed(Duration(seconds: 2));
  // Load lists from file before the app starts
  await InstitutionService.loadInstitutionsFromFile();
  await ProgramService.loadProgramsFromFile();
  await TermService.loadTermsFromFile();
  await CourseService.loadCoursesFromFile();
  await ClassService.loadClassesFromFile();
  await AssignmentService.loadAssignmentsFromFile();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Helper',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
          surface: MyColors.surface,
          error: MyColors.errorRed,
          onPrimary: MyColors.onPrimary,
          onSecondary: MyColors.onSecondary,
          onSurface: MyColors.onSurface,
          onError: MyColors.errorRed,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: MyColors.onSurface, fontSize: 20),
          bodyMedium: TextStyle(color: MyColors.primary, fontSize: 16),
          bodySmall: TextStyle(color: MyColors.primary, fontSize: 13),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(MyColors.onSurface),
            foregroundColor: WidgetStateProperty.all(MyColors.surface),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(MyColors.onSecondary),
          checkColor: WidgetStateProperty.all(MyColors.secondary),
          overlayColor: WidgetStateProperty.all(MyColors.primary),
          side: BorderSide(color: MyColors.secondary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      home: MyInteractiveScreen(),
    );
  }
}

class MyInteractiveScreen extends StatefulWidget {
  @override
  _MyInteractiveScreenState createState() => _MyInteractiveScreenState();
}

class _MyInteractiveScreenState extends State<MyInteractiveScreen> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => _getTabPage(index),
          );
        },
      ),
    );
  }

  Widget _getTabPage(int index) {
    switch (index) {
      case 0:
        return ProgramsScreen();
      case 1:
        return GradesScreen();
      case 2:
        return InstitutionsScreen();
      case 3:
        return CalendarScreen();
      default:
        return ProgramsScreen();
    }
  }

  Future<bool> _onWillPop() async {
    if (_navigatorKeys[_selectedIndex].currentState!.canPop()) {
      _navigatorKeys[_selectedIndex].currentState!.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(title: "Class Helper"),
        body: Stack(
          children: List.generate(
            4,
            (index) => _buildOffstageNavigator(index),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTabSelected: _onTabTapped,
        ),
      ),
    );
  }
}

// AppBar Widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: MyColors.secondary,
      foregroundColor: MyColors.onSecondary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Bottom Navigation Bar Widget
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 40),
          label: 'Home',
          backgroundColor: MyColors.secondary,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart, size: 40),
          label: 'Grades',
          backgroundColor: MyColors.secondary,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school, size: 40),
          label: 'Institutions',
          backgroundColor: MyColors.secondary,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month, size: 40),
          label: 'Calendar',
          backgroundColor: MyColors.secondary,
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      type: BottomNavigationBarType.shifting,
      selectedItemColor: MyColors.onSecondary,
      unselectedItemColor: MyColors.onSurface,
    );
  }
}
