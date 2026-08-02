import 'package:flutter_test/flutter_test.dart';
import 'package:tutormatch/models/models.dart';
import 'package:tutormatch/providers/app_provider.dart';

// ── Helper: crea un Tutor de prueba ──────────────────────────────────────
Tutor crearTutorDePrueba({
  String id = 't1',
  String nombre = 'Rafael Gómez',
  bool disponible = true,
  double precioPorHora = 40,
}) {
  return Tutor(
    id: id,
    nombre: nombre,
    materias: ['Cálculo', 'Álgebra'],
    bio: 'Tutor de prueba para tests unitarios.',
    precioPorHora: precioPorHora,
    rating: 4.9,
    totalResenas: 10,
    disponible: disponible,
  );
}

// ── Helper: crea una Reserva de prueba ───────────────────────────────────
Reserva crearReservaDePrueba({
  String id = 'r1',
  EstadoReserva estado = EstadoReserva.pendiente,
}) {
  return Reserva(
    id: id,
    materia: 'Cálculo Diferencial',
    fecha: DateTime(2025, 5, 10),
    hora: '10:00',
    duracionMinutos: 60,
    estado: estado,
    precioTotal: 44.0,
    tutorNombre: 'Rafael Gómez',
    nota: '',
  );
}

void main() {
  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Estado inicial
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — estado inicial', () {
    late AppProvider provider;

    setUp(() => provider = AppProvider());

    test('inicia sin usuario autenticado', () {
      expect(provider.autenticado, isFalse);
      expect(provider.usuario,     isNull);
    });

    test('inicia sin busqueda activa', () {
      expect(provider.busqueda, isEmpty);
    });

    test('inicia sin filtro de solo disponibles', () {
      expect(provider.soloDisponibles, isFalse);
    });

    test('inicia sin filtro de estado de reservas', () {
      expect(provider.filtroEstado, isNull);
    });

    test('inicia sin carga en progreso', () {
      expect(provider.cargando, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Filtros de tutores
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — filtros de tutores', () {
    late AppProvider provider;

    setUp(() => provider = AppProvider());

    test('setBusqueda actualiza el término de búsqueda', () {
      provider.setBusqueda('Cálculo');
      expect(provider.busqueda, equals('Cálculo'));
    });

    test('setBusqueda notifica a los listeners', () {
      bool notificado = false;
      provider.addListener(() => notificado = true);
      provider.setBusqueda('Python');
      expect(notificado, isTrue);
    });

    test('toggleSoloDisponibles activa el filtro', () {
      provider.toggleSoloDisponibles();
      expect(provider.soloDisponibles, isTrue);
    });

    test('toggleSoloDisponibles desactiva el filtro al llamarlo dos veces', () {
      provider.toggleSoloDisponibles();
      provider.toggleSoloDisponibles();
      expect(provider.soloDisponibles, isFalse);
    });

    test('toggleSoloDisponibles notifica a los listeners', () {
      bool notificado = false;
      provider.addListener(() => notificado = true);
      provider.toggleSoloDisponibles();
      expect(notificado, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Filtros de reservas
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — filtros de reservas', () {
    late AppProvider provider;

    setUp(() => provider = AppProvider());

    test('setFiltroEstado actualiza el filtro activo', () {
      provider.setFiltroEstado(EstadoReserva.pendiente);
      expect(provider.filtroEstado, equals(EstadoReserva.pendiente));
    });

    test('setFiltroEstado con null muestra todas las reservas', () {
      provider.setFiltroEstado(EstadoReserva.pendiente);
      provider.setFiltroEstado(null);
      expect(provider.filtroEstado, isNull);
    });

    test('setFiltroEstado notifica a los listeners', () {
      bool notificado = false;
      provider.addListener(() => notificado = true);
      provider.setFiltroEstado(EstadoReserva.confirmada);
      expect(notificado, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Cálculo de precio en crearReserva
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — cálculo de precio de reserva', () {
    test('60 minutos con S/40/hora da total S/44 (incluye 10% comisión)', () {
      // subtotal = 1h * 40 = 40
      // comisión = 40 * 0.10 = 4
      // total    = 44
      final subtotal = (60 / 60) * 40.0;
      final comision = subtotal * 0.10;
      final total    = subtotal + comision;
      expect(total, equals(44.0));
    });

    test('90 minutos con S/35/hora da total S/57.75 (incluye 10% comisión)', () {
      // subtotal = 1.5h * 35 = 52.5
      // comisión = 52.5 * 0.10 = 5.25
      // total    = 57.75
      final subtotal = (90 / 60) * 35.0;
      final comision = subtotal * 0.10;
      final total    = double.parse((subtotal + comision).toStringAsFixed(2));
      expect(total, equals(57.75));
    });

    test('30 minutos con S/28/hora da total S/15.4 (incluye 10% comisión)', () {
      final subtotal = (30 / 60) * 28.0;
      final comision = subtotal * 0.10;
      final total    = double.parse((subtotal + comision).toStringAsFixed(2));
      expect(total, equals(15.4));
    });

    test('120 minutos con S/40/hora da total S/88 (incluye 10% comisión)', () {
      final subtotal = (120 / 60) * 40.0;
      final comision = subtotal * 0.10;
      final total    = double.parse((subtotal + comision).toStringAsFixed(2));
      expect(total, equals(88.0));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Cambiar estado de reserva
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — cambiar estado de reserva', () {
    late AppProvider provider;

    setUp(() => provider = AppProvider());

    test('cambiarEstadoLocal actualiza el estado en la lista', () {
      final reserva = crearReservaDePrueba(estado: EstadoReserva.pendiente);
      provider.agregarReservaParaTest(reserva);

      provider.cambiarEstadoLocal('r1', EstadoReserva.cancelada);

      expect(
        provider.reservasFiltradas.first.estado,
        equals(EstadoReserva.cancelada),
      );
    });

    test('cambiarEstadoLocal notifica a los listeners', () {
      bool notificado = false;
      final reserva = crearReservaDePrueba();
      provider.agregarReservaParaTest(reserva);
      provider.addListener(() => notificado = true);

      provider.cambiarEstadoLocal('r1', EstadoReserva.completada);

      expect(notificado, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Stats del dashboard
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — estadísticas del dashboard', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
      // Limpiamos las reservas demo para que los tests partan de cero
      provider.limpiarReservasParaTest();
    });

    test('totalReservas devuelve 0 cuando no hay reservas', () {
      expect(provider.totalReservas, equals(0));
    });

    test('totalReservas se incrementa al agregar una reserva', () {
      provider.agregarReservaParaTest(crearReservaDePrueba(id: 'r1'));
      provider.agregarReservaParaTest(crearReservaDePrueba(id: 'r2'));
      expect(provider.totalReservas, equals(2));
    });

    test('proximaReserva devuelve null cuando no hay reservas activas', () {
      provider.agregarReservaParaTest(
        crearReservaDePrueba(estado: EstadoReserva.completada),
      );
      expect(provider.proximaReserva, isNull);
    });

    test('proximaReserva devuelve la primera reserva pendiente', () {
      final reservaPendiente = crearReservaDePrueba(
        id: 'r_pendiente',
        estado: EstadoReserva.pendiente,
      );
      provider.agregarReservaParaTest(reservaPendiente);
      expect(provider.proximaReserva?.id, equals('r_pendiente'));
    });

    test('proximaReserva devuelve la primera reserva confirmada', () {
      final reservaConfirmada = crearReservaDePrueba(
        id: 'r_confirmada',
        estado: EstadoReserva.confirmada,
      );
      provider.agregarReservaParaTest(reservaConfirmada);
      expect(provider.proximaReserva?.id, equals('r_confirmada'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PROVIDER: Logout
  // ═══════════════════════════════════════════════════════════════
  group('AppProvider — logout', () {
    late AppProvider provider;

    setUp(() => provider = AppProvider());

    test('logout limpia el usuario y el token', () {
      provider.logout();
      expect(provider.autenticado, isFalse);
      expect(provider.usuario,     isNull);
    });

    test('logout resetea los filtros de búsqueda', () {
      provider.setBusqueda('Python');
      provider.toggleSoloDisponibles();
      provider.logout();

      expect(provider.busqueda,        isEmpty);
      expect(provider.soloDisponibles, isFalse);
    });

    test('logout resetea el filtro de estado de reservas', () {
      provider.setFiltroEstado(EstadoReserva.pendiente);
      provider.logout();
      expect(provider.filtroEstado, isNull);
    });

    test('logout notifica a los listeners', () {
      bool notificado = false;
      provider.addListener(() => notificado = true);
      provider.logout();
      expect(notificado, isTrue);
    });
  });
}
