import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

Future<void> mostrarModalReserva(BuildContext context, Tutor tutor, int colorIdx) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppProvider>(),
      child: _ModalReserva(tutor: tutor, colorIdx: colorIdx),
    ),
  );
}

class _ModalReserva extends StatefulWidget {
  final Tutor tutor;
  final int colorIdx;
  const _ModalReserva({required this.tutor, required this.colorIdx});

  @override
  State<_ModalReserva> createState() => _ModalReservaState();
}

class _ModalReservaState extends State<_ModalReserva> {
  final _materiaCtrl = TextEditingController();
  final _notaCtrl    = TextEditingController();
  DateTime _fecha    = DateTime.now();
  TimeOfDay _hora    = TimeOfDay.now();
  int _duracion      = 60;
  String? _error;

  double get _subtotal => (_duracion / 60) * widget.tutor.precioPorHora;
  double get _comision => _subtotal * 0.10;
  double get _total    => _subtotal + _comision;

  @override
  void dispose() {
    _materiaCtrl.dispose(); _notaCtrl.dispose(); super.dispose();
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _pickHora() async {
    final t = await showTimePicker(context: context, initialTime: _hora);
    if (t != null) setState(() => _hora = t);
  }

  String _formatFecha(DateTime d) {
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  String _formatHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  void _confirmar() {
    if (_materiaCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa la materia a trabajar.');
      return;
    }
    context.read<AppProvider>().crearReserva(
      tutor: widget.tutor,
      materia: _materiaCtrl.text.trim(),
      fecha: _fecha,
      hora: _formatHora(_hora),
      duracionMinutos: _duracion,
      nota: _notaCtrl.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Reserva creada exitosamente! 🎉'),
        backgroundColor: AppTheme.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avBg = AppTheme.avBg[widget.colorIdx % AppTheme.avBg.length];
    final avFg = AppTheme.avFg[widget.colorIdx % AppTheme.avFg.length];
    final kb   = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: 60, bottom: kb),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.9,
        maxChildSize: 1,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reservar sesión',
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    alignment: Alignment.center,
                    child: Text('✕', style: TextStyle(color: AppTheme.muted, fontSize: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tutor seleccionado
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: avBg, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(widget.tutor.iniciales,
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: avFg)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.tutor.nombre,
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text(widget.tutor.materias.join(' · '),
                          style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Error
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.redL, borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: GoogleFonts.nunito(color: AppTheme.red, fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],

            // Materia
            _Label('Materia a trabajar'),
            const SizedBox(height: 6),
            TextField(
              controller: _materiaCtrl,
              decoration: const InputDecoration(hintText: 'Ej. Integrales por partes'),
            ),
            const SizedBox(height: 14),

            // Fecha y hora
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Fecha'),
                      const SizedBox(height: 6),
                      _PickerField(
                        value: _formatFecha(_fecha),
                        icon: Icons.calendar_today,
                        onTap: _pickFecha,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Hora'),
                      const SizedBox(height: 6),
                      _PickerField(
                        value: _formatHora(_hora),
                        icon: Icons.access_time,
                        onTap: _pickHora,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Duración
            _Label('Duración'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _duracion,
                  isExpanded: true,
                  onChanged: (v) => setState(() => _duracion = v!),
                  items: const [
                    DropdownMenuItem(value: 30,  child: Text('30 minutos')),
                    DropdownMenuItem(value: 60,  child: Text('60 minutos')),
                    DropdownMenuItem(value: 90,  child: Text('90 minutos')),
                    DropdownMenuItem(value: 120, child: Text('120 minutos')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Nota
            _Label('Nota para el tutor (opcional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _notaCtrl,
              decoration: const InputDecoration(hintText: 'Temas específicos, preguntas...'),
            ),
            const SizedBox(height: 18),

            // Resumen de precio
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _PriceRow('Tarifa tutor', 'S/${_subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  _PriceRow('Comisión plataforma (10%)', 'S/${_comision.toStringAsFixed(2)}'),
                  const Divider(color: AppTheme.border, height: 20),
                  _PriceRow('Total', 'S/${_total.toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón confirmar
            ElevatedButton(
              onPressed: _confirmar,
              child: const Text('Confirmar reserva'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.muted, letterSpacing: 0.5),
  );
}

class _PickerField extends StatelessWidget {
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerField({required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textColor))),
        ],
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _PriceRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.nunito(
        fontSize: isTotal ? 15 : 13.5,
        fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
        color: isTotal ? AppTheme.textColor : AppTheme.muted,
      )),
      Text(value, style: GoogleFonts.nunito(
        fontSize: isTotal ? 15 : 13.5,
        fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
        color: isTotal ? AppTheme.textColor : AppTheme.muted,
      )),
    ],
  );
}
