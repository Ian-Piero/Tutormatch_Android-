import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ReservasTab extends StatelessWidget {
  const ReservasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lista = prov.reservasFiltradas;

    return Column(
      children: [
        // ── Filtros ──────────────────────────────────
        Container(
          color: AppTheme.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Todas',      estado: null,                    current: prov.filtroEstado),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pendientes', estado: EstadoReserva.pendiente,  current: prov.filtroEstado),
                const SizedBox(width: 8),
                _FilterChip(label: 'Confirmadas',estado: EstadoReserva.confirmada, current: prov.filtroEstado),
                const SizedBox(width: 8),
                _FilterChip(label: 'Completadas',estado: EstadoReserva.completada, current: prov.filtroEstado),
                const SizedBox(width: 8),
                _FilterChip(label: 'Canceladas', estado: EstadoReserva.cancelada,  current: prov.filtroEstado),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),

        // ── Lista ─────────────────────────────────────
        Expanded(
          child: lista.isEmpty
              ? _EmptyReservas()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ReservaCard(reserva: lista[i], colorIdx: i),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Chip de filtro ────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final EstadoReserva? estado;
  final EstadoReserva? current;

  const _FilterChip({required this.label, required this.estado, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = estado == current;
    return GestureDetector(
      onTap: () => context.read<AppProvider>().setFiltroEstado(estado),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentL : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.accent : AppTheme.border,
            width: 1.5,
          ),
        ),
        child: Text(label,
          style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: isActive ? AppTheme.accent : AppTheme.muted,
          )),
      ),
    );
  }
}

// ── Card de reserva ───────────────────────────────────────────────────────
class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final int colorIdx;

  const _ReservaCard({required this.reserva, required this.colorIdx});

  String _formatFecha(DateTime d) {
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.read<AppProvider>();
    final avBg   = AppTheme.avBg[colorIdx % AppTheme.avBg.length];
    final avFg   = AppTheme.avFg[colorIdx % AppTheme.avFg.length];
    final initials = reserva.tutorNombre
        .split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: avBg, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(initials,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: avFg)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reserva.materia,
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('con ${reserva.tutorNombre}',
                      style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.muted)),
                  ],
                ),
              ),
              _EstadoPill(estado: reserva.estado),
            ],
          ),
          const SizedBox(height: 14),

          // Meta grid
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
            child: Row(
              children: [
                Expanded(child: _MetaItem('FECHA', _formatFecha(reserva.fecha))),
                Expanded(child: _MetaItem('HORA', reserva.hora)),
                Expanded(child: _MetaItem('DURACIÓN', '${reserva.duracionMinutos} min')),
                Expanded(child: _MetaItem('TOTAL', 'S/${reserva.precioTotal}', valueColor: AppTheme.accent)),
              ],
            ),
          ),

          // Nota
          if (reserva.nota.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('📝 ${reserva.nota}',
              style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.muted)),
          ],

          // Acciones
          const SizedBox(height: 14),
          Wrap(
            spacing: 10, runSpacing: 8,
            children: _buildBotones(context, prov, reserva),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBotones(BuildContext ctx, AppProvider prov, Reserva r) {
    final botones = <Widget>[];

    if (r.estado == EstadoReserva.pendiente || r.estado == EstadoReserva.confirmada) {
      botones.add(_ActionBtn(
        label: 'Cancelar',
        color: AppTheme.red,
        bgColor: AppTheme.redL,
        onTap: () => _confirmarCambio(ctx, prov, r.id, EstadoReserva.cancelada, 'cancelada'),
      ));
    }

    if (r.estado == EstadoReserva.confirmada) {
      botones.add(_ActionBtn(
        label: 'Marcar completada',
        color: AppTheme.green,
        bgColor: AppTheme.greenL,
        onTap: () => _confirmarCambio(ctx, prov, r.id, EstadoReserva.completada, 'completada'),
      ));
    }

    if (r.estado == EstadoReserva.completada) {
      botones.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text('✓ Completada',
          style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w700)),
      ));
    }

    return botones;
  }

  void _confirmarCambio(BuildContext ctx, AppProvider prov, String id, EstadoReserva estado, String label) {
    prov.cambiarEstado(id, estado);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Reserva marcada como "$label"'),
        backgroundColor: estado == EstadoReserva.cancelada ? AppTheme.red : AppTheme.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Pill de estado ────────────────────────────────────────────────────────
class _EstadoPill extends StatelessWidget {
  final EstadoReserva estado;
  const _EstadoPill({required this.estado});

  @override
  Widget build(BuildContext context) {
    final colors = {
      EstadoReserva.pendiente:  (AppTheme.yellowL, AppTheme.yellow),
      EstadoReserva.confirmada: (AppTheme.accentL,  AppTheme.accent),
      EstadoReserva.completada: (AppTheme.greenL,   AppTheme.green),
      EstadoReserva.cancelada:  (AppTheme.redL,     AppTheme.red),
    };
    final (bg, fg) = colors[estado]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(estado.label,
        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── Meta item ─────────────────────────────────────────────────────────────
class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _MetaItem(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
        style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700,
            color: AppTheme.muted, letterSpacing: 0.5)),
      const SizedBox(height: 3),
      Text(value,
        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700,
            color: valueColor ?? AppTheme.textColor)),
    ],
  );
}

// ── Botón de acción ───────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(label,
        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────
class _EmptyReservas extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('📅', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 14),
        Text('Sin reservas',
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Busca un tutor y reserva tu primera sesión',
          style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.muted)),
      ],
    ),
  );
}
