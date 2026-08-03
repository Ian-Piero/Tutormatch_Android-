// ─── Modelo: Usuario ─────────────────────────────────────────────────────
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id:     json['id'],
    nombre: json['nombre'],
    email:  json['email'],
    rol:    json['rol'],
  );

  String get iniciales =>
      nombre.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

  String get primerNombre => nombre.split(' ').first;
}

// ─── Modelo: Tutor ───────────────────────────────────────────────────────
class Tutor {
  final String id;
  final String nombre;
  final List<String> materias;
  final String bio;
  final double precioPorHora;
  final double rating;
  final int totalResenas;
  final bool disponible;

  const Tutor({
    required this.id,
    required this.nombre,
    required this.materias,
    required this.bio,
    required this.precioPorHora,
    required this.rating,
    required this.totalResenas,
    required this.disponible,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) => Tutor(
    id:            json['id'],
    nombre:        json['nombre'],
    materias:      List<String>.from(json['materias'] ?? []),
    bio:           json['bio'] ?? '',
    precioPorHora: (json['precioPorHora'] as num).toDouble(),
    rating:        (json['rating'] as num).toDouble(),
    totalResenas:  json['totalResenas'] ?? 0,
    disponible:    json['disponible'] ?? false,
  );

  String get iniciales =>
      nombre.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
}

// ─── Modelo: Reserva ─────────────────────────────────────────────────────
class Reserva {
  final String id;
  final String materia;
  final DateTime fecha;
  final String hora;
  final int duracionMinutos;
  EstadoReserva estado;
  final double precioTotal;
  final String tutorNombre;
  final String nota;
  Calificacion? calificacion;

  Reserva({
    required this.id,
    required this.materia,
    required this.fecha,
    required this.hora,
    required this.duracionMinutos,
    required this.estado,
    required this.precioTotal,
    required this.tutorNombre,
    this.nota = '',
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final String nombreDelTutor = json['tutor'] is Map
        ? (json['tutor']['nombre'] ?? 'Tutor')
        : (json['tutorNombre'] ?? 'Tutor');

    return Reserva(
      id:              json['id'],
      materia:         json['materia'],
      fecha:           DateTime.parse(json['fecha']),
      hora:            json['hora'],
      duracionMinutos: json['duracionMinutos'],
      estado:          EstadoReserva.values.firstWhere(
            (e) => e.name == json['estado'],
        orElse: () => EstadoReserva.pendiente,
      ),
      precioTotal:     (json['precioTotal'] as num).toDouble(),
      tutorNombre:     nombreDelTutor,
      nota:            json['nota'] ?? '',
    );
  }
}

// ─── Enum: EstadoReserva ─────────────────────────────────────────────────
enum EstadoReserva { pendiente, confirmada, completada, cancelada }

extension EstadoReservaExt on EstadoReserva {
  String get label {
    switch (this) {
      case EstadoReserva.pendiente:  return 'Pendiente';
      case EstadoReserva.confirmada: return 'Confirmada';
      case EstadoReserva.completada: return 'Completada';
      case EstadoReserva.cancelada:  return 'Cancelada';
    }
  }
}

// ─── Datos demo ───────────────────────────────────────────────────────────
class DemoData {
  static const List<Usuario> usuarios = [
    Usuario(id: 'u1', nombre: 'Carlos Mendoza', email: 'carlos@uni.edu',      rol: 'estudiante'),
    Usuario(id: 'u2', nombre: 'Sofía López',    email: 'sofia@uni.edu',       rol: 'estudiante'),
    Usuario(id: 'u3', nombre: 'Admin General',  email: 'admin@tutormatch.pe', rol: 'admin'),
  ];

  static const List<Tutor> tutores = [
    Tutor(id: 't1', nombre: 'Rafael Gómez',  materias: ['Cálculo Diferencial', 'Álgebra Lineal', 'Estadística'], bio: 'Ing. matemático, 5 años de experiencia.', precioPorHora: 40, rating: 4.9, totalResenas: 142, disponible: true),
    Tutor(id: 't2', nombre: 'María López',   materias: ['Python', 'Machine Learning', 'SQL'],                    bio: 'Data Scientist, enseña programación para ciencias.', precioPorHora: 35, rating: 4.8, totalResenas: 98,  disponible: true),
    Tutor(id: 't3', nombre: 'Juan Pérez',    materias: ['Física General', 'Termodinámica', 'Mecánica'],          bio: 'Físico teórico, especialista en exámenes de ingreso.', precioPorHora: 30, rating: 4.7, totalResenas: 77,  disponible: false),
    Tutor(id: 't4', nombre: 'Karen Ríos',    materias: ['Inglés B2', 'IELTS', 'Conversación'],                   bio: 'Certificada Cambridge CELTA.', precioPorHora: 28, rating: 4.9, totalResenas: 201, disponible: true),
    Tutor(id: 't5', nombre: 'Andrés Vargas', materias: ['Química Orgánica', 'Bioquímica', 'Laboratorio'],        bio: 'Químico farmacéutico con experiencia práctica.', precioPorHora: 32, rating: 4.6, totalResenas: 55, disponible: true),
  ];

  static List<Reserva> reservasIniciales() => [
    Reserva(id: 'r1', materia: 'Cálculo Diferencial', fecha: DateTime(2025, 4, 26), hora: '10:00', duracionMinutos: 60, estado: EstadoReserva.completada, precioTotal: 44.0,  tutorNombre: 'Rafael Gómez'),
    Reserva(id: 'r2', materia: 'Python para Data',    fecha: DateTime(2025, 4, 28), hora: '10:00', duracionMinutos: 90, estado: EstadoReserva.confirmada, precioTotal: 57.75, tutorNombre: 'María López', nota: 'Quiero aprender Pandas'),
  ];
}
// ─── Modelo: Calificación ─────────────────────────────────────────────────
class Calificacion {
  final String reservaId;
  final String tutorId;
  final int estrellas;       // 1 a 5
  final String comentario;
  final DateTime creadoEn;

  const Calificacion({
    required this.reservaId,
    required this.tutorId,
    required this.estrellas,
    required this.comentario,
    required this.creadoEn,
  });
}