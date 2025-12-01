import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mahasiswa_dashboard_view.dart';
import 'profile_view.dart';
import 'patients_list_view.dart';
import 'forms_list_view.dart';
import '../controllers/dashboard_controller.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _patientsKey = GlobalKey<PatientsListViewState>();
  final _formsKey = GlobalKey<FormsListViewState>();
  final _profileKey = GlobalKey<ProfileViewState>();

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const MahasiswaDashboardView(),
      PatientsListView(key: _patientsKey),
      FormsListView(key: _formsKey),
      ProfileView(key: _profileKey),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Always refresh data when switching tabs to ensure up-to-date information
    _refreshCurrentTab(index);
  }

  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0:
        Get.find<DashboardController>().fetchMahasiswaStats();
        Get.find<DashboardController>().fetchLatestPatients();
        break;
      case 1:
        _patientsKey.currentState?.refresh();
        break;
      case 2:
        _formsKey.currentState?.refresh();
        break;
      case 3:
        _profileKey.currentState?.refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            selectedIcon: Icon(Icons.dashboard_customize_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Pasien',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Forms',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Removed unused _LibraryTab and _LibraryCard after adding dedicated Forms tab.
