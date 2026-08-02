import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'inicio_tab.dart';
import 'tutores_tab.dart';
import 'reservas_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<String> _titles = ['Inicio', 'Buscar tutores', 'Mis reservas'];

  final List<Widget> _tabs = const [
    InicioTab(),
    TutoresTab(),
    ReservasTab(),
  ];

  void _logout() {
    context.read<AppProvider>().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AppProvider>().usuario!;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.border, height: 1),
        ),
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textColor),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Hola, ${usuario.primerNombre}',
                style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          _AvatarMenu(
            iniciales: usuario.iniciales,
            onLogout: _logout,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.accent,
          unselectedItemColor: AppTheme.muted,
          selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 22)), label: 'Inicio'),
            BottomNavigationBarItem(icon: Text('🔍', style: TextStyle(fontSize: 22)), label: 'Buscar'),
            BottomNavigationBarItem(icon: Text('📅', style: TextStyle(fontSize: 22)), label: 'Reservas'),
          ],
        ),
      ),
    );
  }
}

class _AvatarMenu extends StatelessWidget {
  final String iniciales;
  final VoidCallback onLogout;
  const _AvatarMenu({required this.iniciales, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) { if (v == 'logout') onLogout(); },
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppTheme.accentL,
          borderRadius: BorderRadius.circular(17),
        ),
        alignment: Alignment.center,
        child: Text(iniciales,
          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.accent)),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            const Icon(Icons.logout, size: 16, color: AppTheme.red),
            const SizedBox(width: 8),
            Text('Cerrar sesión', style: GoogleFonts.nunito(color: AppTheme.red, fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    );
  }
}
