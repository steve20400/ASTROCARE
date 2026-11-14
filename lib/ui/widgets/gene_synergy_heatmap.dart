import 'package:flutter/material.dart';
import '../theme.dart';

class GeneDataRow {
  final String symbol;
  final String function;
  final double control;
  final double radiationOnly;
  final double microgravityOnly;
  final double combined;
  final bool isSynergistic;

  const GeneDataRow({
    required this.symbol,
    required this.function,
    required this.control,
    required this.radiationOnly,
    required this.microgravityOnly,
    required this.combined,
    required this.isSynergistic,
  });

  double get synergyDelta => combined - (radiationOnly + microgravityOnly);
}

class GeneSynergyHeatmapCard extends StatefulWidget {
  const GeneSynergyHeatmapCard({super.key});

  @override
  State<GeneSynergyHeatmapCard> createState() => _GeneSynergyHeatmapCardState();
}

class _GeneSynergyHeatmapCardState extends State<GeneSynergyHeatmapCard> {
  bool _filterSynergisticOnly = false;

  static const List<GeneDataRow> _dataset = [
    GeneDataRow(
      symbol: 'Gadd45a',
      function: 'DNA damage arrest & checkpoint control',
      control: 0.00,
      radiationOnly: 0.18,
      microgravityOnly: 0.10,
      combined: 0.93,
      isSynergistic: true,
    ),
    GeneDataRow(
      symbol: 'Trp53',
      function: 'Master tumor suppressor & apoptosis',
      control: 0.00,
      radiationOnly: 0.15,
      microgravityOnly: 0.08,
      combined: 0.65,
      isSynergistic: true,
    ),
    GeneDataRow(
      symbol: 'Atm',
      function: 'DSB recognition kinase sensor',
      control: 0.00,
      radiationOnly: 0.22,
      microgravityOnly: 0.12,
      combined: 0.72,
      isSynergistic: true,
    ),
    GeneDataRow(
      symbol: 'Rad51',
      function: 'Homologous recombination DNA repair',
      control: 0.00,
      radiationOnly: 0.14,
      microgravityOnly: 0.06,
      combined: 0.67,
      isSynergistic: true,
    ),
    GeneDataRow(
      symbol: 'Bax',
      function: 'Pro-apoptotic mitochondrial pore factor',
      control: 0.00,
      radiationOnly: 0.08,
      microgravityOnly: -0.05,
      combined: 0.38,
      isSynergistic: true,
    ),
    GeneDataRow(
      symbol: 'Cdkn1a',
      function: 'p21 cyclin-dependent kinase inhibitor',
      control: 0.00,
      radiationOnly: 0.12,
      microgravityOnly: 0.09,
      combined: 0.24,
      isSynergistic: false,
    ),
    GeneDataRow(
      symbol: 'Fen1',
      function: 'Flap endonuclease 1 in base excision',
      control: 0.00,
      radiationOnly: 0.05,
      microgravityOnly: 0.03,
      combined: 0.09,
      isSynergistic: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayedGenes = _filterSynergisticOnly
        ? _dataset.where((g) => g.isSynergistic).toList()
        : _dataset;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      color: AstroTheme.spaceCyan,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'NASA GENELAB OSD-288 // OMICS HEATMAP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AstroTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AstroTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AstroTheme.borderCard),
                ),
                child: const Text(
                  'RNA-SEQ // ISS MOUSE SPLEEN',
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: 'monospace',
                    color: AstroTheme.spaceCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scientific Rationale Subtitle
          const Text(
            'Cross-referencing cellular transcriptomics: Under combined microgravity and radiation, DNA repair genes exhibit severe non-linear hyper-activation (synergy score > 1.5× baseline additive sum).',
            style: TextStyle(
              fontSize: 11,
              color: AstroTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Filter Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _filterSynergisticOnly = !_filterSynergisticOnly;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _filterSynergisticOnly
                        ? AstroTheme.cautionAmber.withValues(alpha: 0.15)
                        : AstroTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _filterSynergisticOnly
                          ? AstroTheme.cautionAmber
                          : AstroTheme.borderCard,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _filterSynergisticOnly
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 13,
                        color: _filterSynergisticOnly
                            ? AstroTheme.cautionAmber
                            : AstroTheme.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ONLY NON-ADDITIVE SYNERGIES (⚡)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: _filterSynergisticOnly
                              ? AstroTheme.cautionAmber
                              : AstroTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '${displayedGenes.length} GENES DISPLAYED',
                style: const TextStyle(
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AstroTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AstroTheme.borderCard),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'GENE / PATHWAY',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AstroTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'RAD ONLY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AstroTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'uG ONLY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AstroTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'COMBINED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AstroTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SYNERGY',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AstroTheme.spaceCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Rows
          ...displayedGenes.map((gene) => _buildGeneRow(gene)),

          const SizedBox(height: 10),
          // Footer citation
          const Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              Text(
                'DATA SOURCE: NASA GENELAB GLDS-288 / OSD-288',
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
              Text(
                'THRESHOLD: Δ > 1.5×(RAD + uG)',
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: 'monospace',
                  color: AstroTheme.cautionAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneRow(GeneDataRow gene) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: gene.isSynergistic
            ? AstroTheme.cautionAmber.withValues(alpha: 0.05)
            : AstroTheme.bgDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: gene.isSynergistic
              ? AstroTheme.cautionAmber.withValues(alpha: 0.3)
              : AstroTheme.borderCard,
        ),
      ),
      child: Row(
        children: [
          // Gene Symbol & brief function
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      gene.symbol,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: AstroTheme.textPrimary,
                      ),
                    ),
                    if (gene.isSynergistic) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.bolt,
                        size: 12,
                        color: AstroTheme.cautionAmber,
                      ),
                    ],
                  ],
                ),
                Text(
                  gene.function,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AstroTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Radiation only
          Expanded(
            flex: 2,
            child: Text(
              gene.radiationOnly >= 0
                  ? '+${gene.radiationOnly.toStringAsFixed(2)}'
                  : gene.radiationOnly.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: AstroTheme.textSecondary,
              ),
            ),
          ),

          // Microgravity only
          Expanded(
            flex: 2,
            child: Text(
              gene.microgravityOnly >= 0
                  ? '+${gene.microgravityOnly.toStringAsFixed(2)}'
                  : gene.microgravityOnly.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: AstroTheme.textSecondary,
              ),
            ),
          ),

          // Combined
          Expanded(
            flex: 2,
            child: Text(
              gene.combined >= 0
                  ? '+${gene.combined.toStringAsFixed(2)}'
                  : gene.combined.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: gene.isSynergistic
                    ? AstroTheme.criticalCoral
                    : AstroTheme.textPrimary,
              ),
            ),
          ),

          // Synergy Score
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: gene.isSynergistic
                      ? AstroTheme.cautionAmber.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  gene.isSynergistic
                      ? '+${gene.synergyDelta.toStringAsFixed(2)} ⚡'
                      : 'ADDITIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: gene.isSynergistic
                        ? AstroTheme.cautionAmber
                        : AstroTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
