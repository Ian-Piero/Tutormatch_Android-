import 'package:flutter/material.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  // ── Estado interno ───────────────────────────────────────────────────────
  Usuario?      _usuarioAutenticado;
  List<Tutor>   _listaTutores  = List.from(DemoData.tutores);
  List<Reserva> _listaReservas = DemoData.reservasIniciales();
  bool          _cargandoDatos = false;

  String         _terminoBusqueda        = '';
  bool           _mostrarSoloDisponibles = false;
  EstadoReserva? _filtroEstadoActivo;

  // ── Getters públicos ─────────────────────────────────────────────────────
  Usuario? get usuario      => _usuarioAutenticado;
  bool     get autenticado  => _usuarioAutenticado != null;
  bool     get cargando     => _cargandoDatos;

  String         get busqueda        => _terminoBusqueda;
  bool           get soloDisponibles => _mostrarSoloDisponibles;
  EstadoReserva? get filtroEstado    => _filtroEstadoActivo;

  List<Tutor> get tutoresFiltrados {
    return _listaTutores.where((tutor) {
      final terminoEnMinusculas = _terminoBusqueda.toLowerCase();
      final coincideConBusqueda = terminoEnMinusculas.isEmpty ||
          tutor.nombre.toLowerCase().contains(terminoEnMinusculas) ||
          tutor.materias.any((m) => m.toLowerCase().contains(terminoEnMinusculas)) ||
          tutor.bio.toLowerCase().contains(terminoEnMinusculas);
      final coincideConDisponibilidad = !_mostrarSoloDisponibles || tutor.disponible;
      return coincideConBusqueda && coincideConDisponibilidad;
    }).toList();
  }

  List<Tutor> get tutoresDestacados =>
      _listaTutores.where((tutor) => tutor.disponible).take(4).toList();

  List<Reserva> get reservasFiltradas => _filtroEstadoActivo == null
      ? _listaReservas
      : _listaReservas.where((r) => r.estado == _filtroEstadoActivo).toList();

  int get tutoresDisponibles =>
      _listaTutores.where((tutor) => tutor.disponible).length;

  int get totalReservas => _listaReservas.length;

  Reserva? get proximaReserva {
    final reservasActivas = _listaReservas.where((r) =>
    r.estado == EstadoReserva.confirmada ||
        r.estado == EstadoReserva.pendiente);
    return reservasActivas.isNotEmpty ? reservasActivas.first : null;
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  String? login(String email, String password) {
    const credencialesDemo = {
      'carlos@uni.edu':      '123456',
      'sofia@uni.edu':       '123456',
      'admin@tutormatch.pe': 'admin123',
    };

    final passwordEsperado = credencialesDemo[email.trim()];
    if (passwordEsperado == null || passwordEsperado != password) {
      return 'Credenciales incorrectas. Demo: carlos@uni.edu / 123456';
    }

    _usuarioAutenticado = DemoData.usuarios.firstWhere(
          (u) => u.email == email.trim(),
    );
    notifyListeners();
    return null;
  }

  void logout() {
    _usuarioAutenticado     = null;
    _listaReservas          = DemoData.reservasIniciales();
    _terminoBusqueda        = '';
    _mostrarSoloDisponibles = false;
    _filtroEstadoActivo     = null;
    notifyListeners();
  }

  // ── Tutores ──────────────────────────────────────────────────────────────
  void setBusqueda(String terminoNuevo) {
    _terminoBusqueda = terminoNuevo;
    notifyListeners();
  }

  void toggleSoloDisponibles() {
    _mostrarSoloDisponibles = !_mostrarSoloDisponibles;
    notifyListeners();
  }

  // ── Reservas ─────────────────────────────────────────────────────────────
  void setFiltroEstado(EstadoReserva? estadoNuevo) {
    _filtroEstadoActivo = estadoNuevo;
    notifyListeners();
  }

  void crearReserva({
    required Tutor tutor,
    required String materia,
    required DateTime fecha,
    required String hora,
    required int duracionMinutos,
    required String nota,
  }) {
    final horas    = duracionMinutos / 60;
    final subtotal = horas * tutor.precioPorHora;
    final comision = subtotal * 0.10;
    final total    = double.parse((subtotal + comision).toStringAsFixed(2));

    _listaReservas.insert(0, Reserva(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      materia: materia,
      fecha: fecha,
      hora: hora,
      duracionMinutos: duracionMinutos,
      estado: EstadoReserva.pendiente,
      precioTotal: total,
      tutorNombre: tutor.nombre,
      nota: nota,
    ));
    notifyListeners();
  }

  void cambiarEstadoLocal(String reservaId, EstadoReserva estadoNuevo) {
    final reserva = _listaReservas.firstWhere((r) => r.id == reservaId);
    reserva.estado = estadoNuevo;
    notifyListeners();
  }

  // ── Métodos solo para tests ───────────────────────────────────────────────
  void agregarReservaParaTest(Reserva reserva) {
    _listaReservas.add(reserva);
    notifyListeners();
  }

  void cargarTutoresParaTest(List<Tutor> tutores) {
    _listaTutores = tutores;
    notifyListeners();
  }
  // Agrega esto al final de la clase AppProvider, antes del último }
  void cambiarEstado(String reservaId, EstadoReserva estadoNuevo) {
    cambiarEstadoLocal(reservaId, estadoNuevo);
  }
  void limpiarReservasParaTest() {
    _listaReservas = [];
    notifyListeners();
  }
  void calificarTutor({
    required String reservaId,
    required int estrellas,
    required String comentario,
  }) {
    final reserva = _listaReservas.firstWhere((r) => r.id == reservaId);
    reserva.calificacion = Calificacion(
      reservaId:   reservaId,
      tutorId:     reservaId, // en demo usamos reservaId como referencia
      estrellas:   estrellas,
      comentario:  comentario,
      creadoEn:    DateTime.now(),
    );
    notifyListeners();
  }
}