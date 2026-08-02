import 'package:flutter_test/flutter_test.dart';
import 'package:tutormatch/models/models.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // MODELO: Usuario
  // ═══════════════════════════════════════════════════════════════
  group('Usuario', () {
    const usuarioJson = {
      'id': 'u1',
      'nombre': 'Carlos Mendoza',
      'email': 'carlos@uni.edu',
      'rol': 'estudiante',
    };

    test('fromJson construye el usuario correctamente', () {
      final usuario = Usuario.fromJson(usuarioJson);

      expect(usuario.id,     equals('u1'));
      expect(usuario.nombre, equals('Carlos Mendoza'));
      expect(usuario.email,  equals('carlos@uni.edu'));
      expect(usuario.rol,    equals('estudiante'));
    });

    test('iniciales extrae las dos primeras letras del nombre', () {
      final usuario = Usuario.fromJson(usuarioJson);
      expect(usuario.iniciales, equals('CM'));
    });

    test('iniciales funciona con nombre de una sola palabra', () {
      final usuario = Usuario.fromJson({...usuarioJson, 'nombre': 'Carlos'});
      expect(usuario.iniciales, equals('C'));
    });

    test('primerNombre devuelve solo el primer nombre', () {
      final usuario = Usuario.fromJson(usuarioJson);
      expect(usuario.primerNombre, equals('Carlos'));
    });

    test('primerNombre funciona con nombre de una sola palabra', () {
      final usuario = Usuario.fromJson({...usuarioJson, 'nombre': 'Admin'});
      expect(usuario.primerNombre, equals('Admin'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // MODELO: Tutor
  // ═══════════════════════════════════════════════════════════════
  group('Tutor', () {
    const tutorJson = {
      'id': 't1',
      'nombre': 'Rafael Gómez',
      'materias': ['Cálculo Diferencial', 'Álgebra Lineal'],
      'bio': 'Ingeniero matemático con 5 años de experiencia.',
      'precioPorHora': 40,
      'rating': 4.9,
      'totalResenas': 142,
      'disponible': true,
    };

    test('fromJson construye el tutor correctamente', () {
      final tutor = Tutor.fromJson(tutorJson);

      expect(tutor.id,            equals('t1'));
      expect(tutor.nombre,        equals('Rafael Gómez'));
      expect(tutor.materias,      equals(['Cálculo Diferencial', 'Álgebra Lineal']));
      expect(tutor.precioPorHora, equals(40.0));
      expect(tutor.rating,        equals(4.9));
      expect(tutor.totalResenas,  equals(142));
      expect(tutor.disponible,    isTrue);
    });

    test('fromJson acepta precioPorHora como entero o decimal', () {
      final tutorConDecimal = Tutor.fromJson({...tutorJson, 'precioPorHora': 35.5});
      expect(tutorConDecimal.precioPorHora, equals(35.5));
    });

    test('iniciales extrae correctamente las iniciales del nombre', () {
      final tutor = Tutor.fromJson(tutorJson);
      expect(tutor.iniciales, equals('RG'));
    });

    test('disponible es false cuando el tutor no está disponible', () {
      final tutorOcupado = Tutor.fromJson({...tutorJson, 'disponible': false});
      expect(tutorOcupado.disponible, isFalse);
    });

    test('materias puede estar vacía sin lanzar error', () {
      final tutorSinMaterias = Tutor.fromJson({...tutorJson, 'materias': []});
      expect(tutorSinMaterias.materias, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // MODELO: Reserva
  // ═══════════════════════════════════════════════════════════════
  group('Reserva', () {
    final reservaJson = {
      'id': 'r1',
      'materia': 'Cálculo Diferencial',
      'fecha': '2025-04-26',
      'hora': '10:00',
      'duracionMinutos': 60,
      'estado': 'completada',
      'precioTotal': 44.0,
      'tutor': {'nombre': 'Rafael Gómez'},
      'nota': 'Traer ejercicios del libro',
    };

    test('fromJson construye la reserva correctamente', () {
      final reserva = Reserva.fromJson(reservaJson);

      expect(reserva.id,               equals('r1'));
      expect(reserva.materia,          equals('Cálculo Diferencial'));
      expect(reserva.hora,             equals('10:00'));
      expect(reserva.duracionMinutos,  equals(60));
      expect(reserva.precioTotal,      equals(44.0));
      expect(reserva.tutorNombre,      equals('Rafael Gómez'));
      expect(reserva.nota,             equals('Traer ejercicios del libro'));
    });

    test('fromJson parsea la fecha correctamente', () {
      final reserva = Reserva.fromJson(reservaJson);
      expect(reserva.fecha, equals(DateTime(2025, 4, 26)));
    });

    test('fromJson asigna estado "completada" correctamente', () {
      final reserva = Reserva.fromJson(reservaJson);
      expect(reserva.estado, equals(EstadoReserva.completada));
    });

    test('fromJson asigna estado "pendiente" correctamente', () {
      final reserva = Reserva.fromJson({...reservaJson, 'estado': 'pendiente'});
      expect(reserva.estado, equals(EstadoReserva.pendiente));
    });

    test('fromJson asigna estado "cancelada" correctamente', () {
      final reserva = Reserva.fromJson({...reservaJson, 'estado': 'cancelada'});
      expect(reserva.estado, equals(EstadoReserva.cancelada));
    });

    test('fromJson usa pendiente como estado por defecto si el estado es desconocido', () {
      final reserva = Reserva.fromJson({...reservaJson, 'estado': 'estado_invalido'});
      expect(reserva.estado, equals(EstadoReserva.pendiente));
    });

    test('nota es cadena vacía cuando el JSON no incluye nota', () {
      final reservaSinNota = Map<String, dynamic>.from(reservaJson)..remove('nota');
      final reserva = Reserva.fromJson(reservaSinNota);
      expect(reserva.nota, equals(''));
    });

    test('estado puede cambiar después de construido', () {
      final reserva = Reserva.fromJson(reservaJson);
      reserva.estado = EstadoReserva.cancelada;
      expect(reserva.estado, equals(EstadoReserva.cancelada));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // ENUM: EstadoReserva
  // ═══════════════════════════════════════════════════════════════
  group('EstadoReserva labels', () {
    test('pendiente muestra "Pendiente"', () {
      expect(EstadoReserva.pendiente.label,  equals('Pendiente'));
    });
    test('confirmada muestra "Confirmada"', () {
      expect(EstadoReserva.confirmada.label, equals('Confirmada'));
    });
    test('completada muestra "Completada"', () {
      expect(EstadoReserva.completada.label, equals('Completada'));
    });
    test('cancelada muestra "Cancelada"', () {
      expect(EstadoReserva.cancelada.label,  equals('Cancelada'));
    });
  });
}
