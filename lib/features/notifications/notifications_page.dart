import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  int _selectedFilter = 0; // 0 = Összes, 1 = Üzenetek, 2 = Rendszer

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'id': '1',
      'title': 'Sikeres NTAK Ellenőrzés! 🎉',
      'message': 'A Mátrai Panoráma Vendégház NTAK regisztrációját az adminisztrátor jóváhagyta. A szálláshelyed élesben megjelent!',
      'time': '10 perce',
      'type': 'system',
      'isUnread': true,
      'icon': Icons.verified_user_rounded,
      'iconColor': accent,
    },
    {
      'id': '2',
      'title': 'Új érdeklődés (Chat) 💬',
      'message': 'Kovács Péter érdeklődött a Mátrai Panoráma Vendégház iránt október 18-20. időszakra.',
      'time': '2 órája',
      'type': 'message',
      'isUnread': true,
      'icon': Icons.chat_bubble_rounded,
      'iconColor': Colors.lightBlueAccent,
    },
    {
      'id': '3',
      'title': 'Szezonális HegyGO Kedvezmény 🌲',
      'message': 'Helyi Partnerünk, a Mátra Quad Szafari 15% kedvezményt biztosít minden HegyGO felhasználónak ezen a hétvégén!',
      'time': 'Tegnap',
      'type': 'system',
      'isUnread': false,
      'icon': Icons.local_offer_rounded,
      'iconColor': Colors.orangeAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _allNotifications.where((item) {
      if (_selectedFilter == 1) return item['type'] == 'message';
      if (_selectedFilter == 2) return item['type'] == 'system';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Értesítések',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: accent, size: 22),
            tooltip: 'Mindegyik olvasottnak jelölése',
            onPressed: () {
              setState(() {
                for (var item in _allNotifications) {
                  item['isUnread'] = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF0D2113),
                  content: Text('Minden értesítés olvasottnak jelölve!', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SZŰRŐ TABOK (ÖSSZES, ÜZENETEK, RENDSZER)
            Row(
              children: [
                _buildFilterChip(0, 'Összes'),
                const SizedBox(width: 8),
                _buildFilterChip(1, 'Üzenetek'),
                const SizedBox(width: 8),
                _buildFilterChip(2, 'Rendszer'),
              ],
            ),

            const SizedBox(height: 20),

            // ÉRTESÍTÉSEK LISTÁJA
            Expanded(
              child: filteredNotifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Nincs ebben a kategóriában értesítés.',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final item = filteredNotifications[index];
                        return _buildNotificationCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accent : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final bool isUnread = item['isUnread'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? accent.withValues(alpha: 0.4) : Colors.white12,
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (item['iconColor'] as Color).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, color: item['iconColor'] as Color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      item['time'],
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['message'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}