import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/tutor_card.dart';
import '../widgets/modal_reserva.dart';

class InicioTab extends StatelessWidget {
  const InicioTab({super.key});

  String _formatFecha(DateTime d) {
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final proxima = prov.proximaReserva;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats grid ────────────────────────────────
          Row(
            children: [
              Expanded(child: _StatCard(
                label: 'Tutores disponibles',
                value: '${prov.tutoresDisponibles}',
                sub: 'listos para ayudarte',
                color: AppTheme.accent,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                label: 'Mis reservas',
                value: '${prov.totalReservas}',
                sub: 'sesiones agendadas',
                color: AppTheme.green,
              )),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: 'Próxima sesión',
            value: proxima != null ? _formatFecha(proxima.fecha) : 'Ninguna',
            sub: proxima != null ? '${proxima.hora} — ${proxima.materia}' : 'Reserva tu primera sesión',
            color: AppTheme.yellow,
            isWide: true,
          ),
          const SizedBox(height: 24),

          // ── Tutores destacados ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tutores destacados',
                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () {
                  // Navegar al tab Buscar (índice 1)
                  // Usamos DefaultTabController no aplica aquí, pero podemos emitir un evento
                },
                child: Text('Ver todos →',
                  style: GoogleFonts.nunito(color: AppTheme.accent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cards de tutores disponibles
          ...prov.tutoresDestacados.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TutorCard(
              tutor: e.value,
              colorIdx: e.key,
              onTap: () => mostrarModalReserva(context, e.value, e.key),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool isWide;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
            style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.muted, letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Text(value,
            style: GoogleFonts.spaceMono(fontSize: isWide ? 18 : 28, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(sub,
            style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.muted)),
        ],
      ),
    );
  }
}
