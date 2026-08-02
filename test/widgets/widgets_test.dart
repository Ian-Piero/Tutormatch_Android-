import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/models/models.dart';
import 'package:tutormatch/providers/app_provider.dart';
import 'package:tutormatch/screens/login_screen.dart';
import 'package:tutormatch/widgets/tutor_card.dart';
import 'package:tutormatch/theme/app_theme.dart';

Widget envolverConProviders(Widget widget) {
  return ChangeNotifierProvider(
    create: (_) => AppProvider(),
    child: MaterialApp(theme: AppTheme.theme, home: widget),
  );
}

const tutorDePrueba = Tutor(
  id: 't1', nombre: 'Rafael Gómez',
  materias: ['Cálculo Diferencial', 'Álgebra Lineal'],
  bio: 'Ingeniero matemático con experiencia.',
  precioPorHora: 40, rating: 4.9, totalResenas: 142, disponible: true,
);

const tutorOcupado = Tutor(
  id: 't2', nombre: 'Juan Pérez',
  materias: ['Física'],
  bio: 'Físico con experiencia.',
  precioPorHora: 30, rating: 4.5, totalResenas: 50, disponible: false,
);

void main() {
  group('LoginScreen — renderizado', () {
    testWidgets('muestra RichText con el logo', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('muestra tab Iniciar sesión', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('muestra tab Crear cuenta', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('muestra campos de texto', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('muestra botón Entrar', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('muestra credenciales demo', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      expect(find.textContaining('carlos@uni.edu'), findsOneWidget);
    });
  });

  group('LoginScreen — interacciones', () {
    testWidgets('al tocar Crear cuenta aparece campo Nombre completo', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      expect(find.text('NOMBRE COMPLETO'), findsOneWidget);
    });

    testWidgets('al volver a Iniciar sesión desaparece el campo Nombre', (tester) async {
      await tester.pumpWidget(envolverConProviders(const LoginScreen()));
      await tester.pump();
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('NOMBRE COMPLETO'), findsNothing);
    });
  });

  group('TutorCard — renderizado', () {
    testWidgets('muestra el nombre del tutor', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(tutor: tutorDePrueba, colorIdx: 0, onTap: () {})),
      ));
      await tester.pump();
      expect(find.text('Rafael Gómez'), findsOneWidget);
    });

    testWidgets('muestra texto / hora junto al precio', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(tutor: tutorDePrueba, colorIdx: 0, onTap: () {})),
      ));
      await tester.pump();
      expect(find.text('/ hora'), findsOneWidget);
    });

    testWidgets('muestra Disponible cuando está disponible', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(tutor: tutorDePrueba, colorIdx: 0, onTap: () {})),
      ));
      await tester.pump();
      expect(find.textContaining('Disponible'), findsOneWidget);
    });

    testWidgets('muestra Ocupado cuando no está disponible', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(tutor: tutorOcupado, colorIdx: 0, onTap: () {})),
      ));
      await tester.pump();
      expect(find.textContaining('Ocupado'), findsOneWidget);
    });

    testWidgets('muestra las materias del tutor', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(tutor: tutorDePrueba, colorIdx: 0, onTap: () {})),
      ));
      await tester.pump();
      expect(find.text('Cálculo Diferencial'), findsOneWidget);
      expect(find.text('Álgebra Lineal'),      findsOneWidget);
    });

    testWidgets('muestra iniciales RG en el avatar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(tutor: tutorDePrueba, colorIdx: 0, onTap: () {})),
      ));
      await tester.pump();
      expect(find.text('RG'), findsOneWidget);
    });

    testWidgets('llama a onTap al presionar la card', (tester) async {
      bool fueTocada = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TutorCard(
          tutor: tutorDePrueba, colorIdx: 0,
          onTap: () => fueTocada = true,
        )),
      ));
      await tester.pump();
      await tester.tap(find.byType(InkWell).first);
      expect(fueTocada, isTrue);
    });
  });
}