import 'package:flutter/material.dart';
import '../../core/services/data_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

class AdminModerationPage extends StatefulWidget {
  const AdminModerationPage({super.key});

  @override
  State<AdminModerationPage> createState() => _AdminModerationPageState();
}

class _AdminModerationPageState extends State<AdminModerationPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Admin Moderációs Központ 🛡️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Itt hagyhatod jóvá vagy utasíthatod el a partnerek által feltöltött hirdetéseket.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: DataService.accommodations,
                  builder: (context, items, child) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nincs jelenleg hirdetés a rendszerben.',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final title = item['title'] ?? 'Névtelen hirdetés';
                        final location = item['location'] ?? 'Ismeretlen hely';
                        final status = item['status'] ?? 'pending'; // pending, approved, rejected

                        Color statusColor = sunnyGold;
                        String statusText = 'Függőben / Ellenőrzésre vár';
                        if (status == 'approved') {
                          statusColor = Colors.greenAccent;
                          statusText = 'Jóváhagyva (Éles)';
                        } else if (status == 'rejected') {
                          statusColor = Colors.redAccent;
                          statusText = 'Elutasítva';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF093753),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor, width: 1),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Helyszín: $location', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.close_rounded, size: 16),
                                    label: const Text('Elutasítás', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      setState(() {
                                        item['status'] = 'rejected';
                                      });
                                      DataService.updateAccommodationStatus(item, 'rejected');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.check_rounded, size: 16),
                                    label: const Text('Jóváhagyás', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      setState(() {
                                        item['status'] = 'approved';
                                      });
                                      DataService.updateAccommodationStatus(item, 'approved');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}