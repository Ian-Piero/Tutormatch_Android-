import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

Future<void> mostrarDialogCalificacion(
    BuildContext context,
    String reservaId,
    String tutorNombre,
    ) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppProvider>(),
      child: _DialogCalificacion(
        reservaId:    reservaId,
        tutorNombre:  tutorNombre,
      ),
    ),
  );
}

class _DialogCalificacion extends StatefulWidget {
  final String reservaId;
  final String tutorNombre;
  const _DialogCalificacion({
    required this.reservaId,
    required this.tutorNombre,
  });

  @override
  State<_DialogCalificacion> createState() => _DialogCalificacionState();
}

class _DialogCalificacionState extends State<_DialogCalificacion> {
  int    _estrellasSeleccionadas = 0;
  final  _comentarioCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  void _enviarCalificacion() {
    if (_estrellasSeleccionadas == 0) {
      setState(() => _error = 'Selecciona al menos una estrella.');
      return;
    }

    context.read<AppProvider>().calificarTutor(
      reservaId:  widget.reservaId,
      estrellas:  _estrellasSeleccionadas,
      comentario: _comentarioCtrl.text.trim(),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Gracias por tu calificación! 🌟'),
        backgroundColor: AppTheme.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ícono ────────────────────────────────────────
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppTheme.yellowL,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text('⭐', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 16),

            // ── Título ───────────────────────────────────────
            Text(
              '¿Cómo estuvo la sesión?',
              style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Califica a ${widget.tutorNombre}',
              style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Estrellas ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final numeroEstrella = i + 1;
                final estaActiva = numeroEstrella <= _estrellasSeleccionadas;
                return GestureDetector(
                  onTap: () => setState(
                        () => _estrellasSeleccionadas = numeroEstrella,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        estaActiva ? '★' : '☆',
                        key: ValueKey(estaActiva),
                        style: TextStyle(
                          fontSize: 36,
                          color: estaActiva
                              ? const Color(0xFFF59E0B)
                              : AppTheme.border,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ── Label de estrella seleccionada ───────────────
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _labelEstrellas(_estrellasSeleccionadas),
                key: ValueKey(_estrellasSeleccionadas),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _estrellasSeleccionadas > 0
                      ? const Color(0xFFF59E0B)
                      : AppTheme.muted,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Error ────────────────────────────────────────
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.redL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.nunito(
                    color: AppTheme.red, fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Comentario ───────────────────────────────────
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario (opcional)...',
                hintStyle: GoogleFonts.nunito(
                  color: AppTheme.muted, fontSize: 13,
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // ── Botones ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text(
                      'Ahora no',
                      style: GoogleFonts.nunito(
                        color: AppTheme.muted, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _enviarCalificacion,
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelEstrellas(int n) {
    switch (n) {
      case 1: return 'Muy mala 😞';
      case 2: return 'Regular 😐';
      case 3: return 'Buena 🙂';
      case 4: return 'Muy buena 😊';
      case 5: return 'Excelente 🤩';
      default: return 'Toca una estrella';
    }
  }
}