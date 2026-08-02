import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class TutorCard extends StatelessWidget {
  final Tutor tutor;
  final int colorIdx;
  final VoidCallback onTap;

  const TutorCard({
    super.key,
    required this.tutor,
    required this.colorIdx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avBg = AppTheme.avBg[colorIdx % AppTheme.avBg.length];
    final avFg = AppTheme.avFg[colorIdx % AppTheme.avFg.length];
    final stars = _starsWidget(tutor.rating);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          color: avBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(tutor.iniciales,
                          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: avFg)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tutor.nombre,
                              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textColor)),
                            const SizedBox(height: 3),
                            Text(
                              tutor.bio.length > 60 ? '${tutor.bio.substring(0, 60)}...' : tutor.bio,
                              style: GoogleFonts.nunito(fontSize: 12.5, color: AppTheme.muted),
                            ),
                            const SizedBox(height: 6),
                            // Estrellas y rating
                            Row(
                              children: [
                                stars,
                                const SizedBox(width: 6),
                                Text(tutor.rating.toString(),
                                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 4),
                                Text('(${tutor.totalResenas})',
                                  style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Materias chips ─────────────────────────
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: tutor.materias.take(3).map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentL,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(m,
                        style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                    )).toList(),
                  ),
                  const SizedBox(height: 14),

                  // ── Footer ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.accent),
                            children: [
                              TextSpan(text: 'S/${tutor.precioPorHora.toStringAsFixed(0)}'),
                              TextSpan(text: ' / hora',
                                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: tutor.disponible ? AppTheme.greenL : AppTheme.yellowL,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tutor.disponible ? '● Disponible' : '○ Ocupado',
                            style: GoogleFonts.nunito(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: tutor.disponible ? AppTheme.green : AppTheme.yellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _starsWidget(double rating) {
    final full = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Text(
        i < full ? '★' : '☆',
        style: TextStyle(
          fontSize: 13,
          color: i < full ? const Color(0xFFF59E0B) : AppTheme.border,
          height: 1,
        ),
      )),
    );
  }
}
