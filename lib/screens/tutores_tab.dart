import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/tutor_card.dart';
import '../widgets/modal_reserva.dart';

class TutoresTab extends StatelessWidget {
  const TutoresTab({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lista = prov.tutoresFiltrados;

    return Column(
      children: [
        // ── Barra de búsqueda ──────────────────────────
        Container(
          color: AppTheme.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            children: [
              // Search input
              TextField(
                onChanged: prov.setBusqueda,
                decoration: InputDecoration(
                  hintText: 'Buscar por materia o nombre...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.muted, size: 20),
                  hintStyle: GoogleFonts.nunito(color: AppTheme.muted, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              // Filtro disponibles
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: prov.toggleSoloDisponibles,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: prov.soloDisponibles ? AppTheme.accentL : AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: prov.soloDisponibles ? AppTheme.accent : AppTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '● Solo disponibles',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: prov.soloDisponibles ? AppTheme.accent : AppTheme.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),

        // ── Lista de tutores ───────────────────────────
        Expanded(
          child: lista.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TutorCard(
                      tutor: lista[i],
                      colorIdx: i,
                      onTap: () => mostrarModalReserva(ctx, lista[i], i),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 14),
        Text('Sin resultados',
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textColor)),
        const SizedBox(height: 8),
        Text('Intenta con otro término de búsqueda',
          style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.muted)),
      ],
    ),
  );
}
