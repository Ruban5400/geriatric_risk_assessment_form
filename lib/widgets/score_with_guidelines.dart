import 'package:flutter/material.dart';
import 'package:geriatric_risk_assessment_form/widgets/speedometer.dart';

import '../screens/view_details.dart';
import '../xtras/scan_qr_page.dart';

enum RiskLevel { high, moderate, low }

class ScoreWithGuidelinesPage extends StatelessWidget {
  final int score;
  final int maxScore;

  const ScoreWithGuidelinesPage({
    Key? key,
    required this.score,
    this.maxScore = 26, // match your speedometer default (adjust if you change)
  }) : super(key: key);

  RiskLevel _riskLevelForScore(int s) {
    // Adjust thresholds to your clinical cutoffs; using same logic as earlier:
    if (s <= 18) return RiskLevel.high;
    if (s <= 24) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  Color _riskColor(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return Colors.red.shade700;
      case RiskLevel.moderate:
        return Colors.orange.shade700;
      case RiskLevel.low:
      default:
        return Colors.green.shade700;
    }
  }

  // Guideline sections
  List<String> _medical(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return [
          'Immediate physician review for reversible causes (orthostatic hypotension, infections, arrhythmia).',
          'Medication review: stop/adjust sedatives, review antihypertensives.',
          'Arrange vision and neuropathy assessment.',
        ];
      case RiskLevel.moderate:
        return [
          'Periodic medication & vision checks; assess for reversible causes.',
          'Consider referral to physiotherapy if recurring instability.',
        ];
      case RiskLevel.low:
      default:
        return [
          'Annual medication & vision review; report new dizziness early.',
        ];
    }
  }

  List<String> _exercise(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return [
          'Supervised physiotherapy focusing on strength and transfer training.',
          'Avoid unsupervised challenging balance tasks until stable.',
        ];
      case RiskLevel.moderate:
        return [
          'Home exercise: 20–30 min daily — balance, gait and leg strength.',
          'Consider group classes (tai chi) to improve balance and confidence.',
        ];
      case RiskLevel.low:
      default:
        return [
          'Maintain regular activity: walking, balance & strength 2–3×/week.',
        ];
    }
  }

  List<String> _home(RiskLevel r) {
    final base = [
      'Remove loose rugs and clutter; keep floors clear.',
      'Improve lighting (hallways, stairs) and use night lights.',
      'Use non-slip mats in wet areas and proper footwear indoors.',
    ];
    if (r == RiskLevel.high) {
      return [
        'Install grab rails at toilet, shower, and stairs.',
        'Consider shower chair and supervised toileting until stable.',
        ...base,
      ];
    } else if (r == RiskLevel.moderate) {
      return ['Mark step edges with contrast tape', ...base];
    } else {
      return base;
    }
  }

  List<String> _awareness(RiskLevel r) {
    switch (r) {
      case RiskLevel.high:
        return [
          'Stand up slowly; pause after sitting or lying.',
          'Keep phone/personal alarm within reach; use assistive device as prescribed.',
        ];
      case RiskLevel.moderate:
        return [
          'Avoid rushing; use appropriate footwear and be cautious on uneven ground.',
        ];
      case RiskLevel.low:
      default:
        return [
          'Stay active and monitor any new balance or dizziness symptoms.',
        ];
    }
  }

  Widget _sectionCard(
    BuildContext context,
    IconData icon,
    String title,
    List<String> items,
    Color accent,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: accent.withOpacity(0.12),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _riskLevelForScore(score);
    final levelColor = _riskColor(level);
    final levelLabel = level == RiskLevel.high
        ? 'High Fall Risk'
        : (level == RiskLevel.moderate
              ? 'Moderate Fall Risk'
              : 'Low Fall Risk');

    final med = _medical(level);
    final ex = _exercise(level);
    final home = _home(level);
    final aw = _awareness(level);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'POMA — Score & Guidelines',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 173, 23, 143),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // SPEEDOMETER + header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: levelColor.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        // PomaSpeedometer centered
                        Center(
                          child: PomaSpeedometer(
                            score: score,
                            maxScore: maxScore,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          levelLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: levelColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'POMA score: $score / $maxScore',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Guidelines sections
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _sectionCard(
                                    context,
                                    Icons.medical_services,
                                    'Medical Review',
                                    med,
                                    levelColor,
                                  ),
                                  _sectionCard(
                                    context,
                                    Icons.fitness_center,
                                    'Exercise & Rehab',
                                    ex,
                                    levelColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  _sectionCard(
                                    context,
                                    Icons.home,
                                    'Home Safety',
                                    home,
                                    levelColor,
                                  ),
                                  _sectionCard(
                                    context,
                                    Icons.self_improvement,
                                    'Personal Awareness',
                                    aw,
                                    levelColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _sectionCard(
                              context,
                              Icons.medical_services,
                              'Medical Review',
                              med,
                              levelColor,
                            ),
                            _sectionCard(
                              context,
                              Icons.fitness_center,
                              'Exercise & Rehab',
                              ex,
                              levelColor,
                            ),
                            _sectionCard(
                              context,
                              Icons.home,
                              'Home Safety',
                              home,
                              levelColor,
                            ),
                            _sectionCard(
                              context,
                              Icons.self_improvement,
                              'Personal Awareness',
                              aw,
                              levelColor,
                            ),
                          ],
                        ),

                  const SizedBox(height: 18),

                  // Quick actions footer
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick tips',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Keep a list of current medications and share with your physician.',
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '• If a fall occurs, seek medical review even if there are no immediate injuries.',
                          ),
                          const SizedBox(height: 12),
                          // Take to view report page
                          // ElevatedButton.icon(
                          //   icon: const Icon(Icons.view_list),
                          //   label: const Text('View'),
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (_) => ViewDetails(maxScore: maxScore,score: score,
                          //       ),
                          //     ));
                          //   },
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    173,
                                    23,
                                    143,
                                  ),
                                  // foregroundColor: forgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  // Fixed height for a good button
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Back to Home',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) =>  QRViewExample())),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
