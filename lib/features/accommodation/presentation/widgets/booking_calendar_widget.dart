import 'package:flutter/material.dart';

class BookingCalendarWidget extends StatefulWidget {
  final int pricePerNight;
  final Function(DateTimeRange?, int, int)? onBookingSelected;

  const BookingCalendarWidget({
    super.key,
    required this.pricePerNight,
    this.onBookingSelected,
  });

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  static const Color greenColor = Color(0xFF5A9E32);
  static const Color redColor = Color(0xFFD34545);
  static const Color orangeColor = Color(0xFFE29547);
  static const Color blueColor = Color(0xFF4A80C2);

  // Minta állapotok a naptárhoz (nap száma: típus)
  final Map<int, String> _dayStatuses = const {
    6: 'half_pending_start',
    7: 'pending',
    8: 'pending',
    9: 'pending',
    10: 'pending',
    11: 'half_pending_end',
    18: 'selected',
    19: 'selected',
    27: 'half_booked_start',
    28: 'booked',
    29: 'booked',
    30: 'half_booked_end',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FEJLÉC (HÓNAP ÉS LÉPTETŐK)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Október 2026',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 28),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 28),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // HÉT NAPJAI FEJLÉC (MAGYARUL)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayHeader('HÉ'),
              _DayHeader('KE'),
              _DayHeader('SZE'),
              _DayHeader('CSÜ'),
              _DayHeader('PÉ'),
              _DayHeader('SZO'),
              _DayHeader('VA'),
            ],
          ),

          const SizedBox(height: 12),

          // NAPTÁR RÁCS
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 33, // 2 üres cella az elején (Szerdával kezdődik) + 31 nap
            itemBuilder: (context, index) {
              if (index < 2) {
                return const SizedBox(); // Üres helyek Szerda előtt
              }

              final day = index - 1;
              final status = _dayStatuses[day] ?? 'available';

              return _buildCalendarTile(day, status);
            },
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // JELMAGYARÁZAT (MAGYARUL)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: greenColor, label: 'Szabad'),
              _LegendItem(color: redColor, label: 'Foglalt'),
              _LegendItem(color: orangeColor, label: 'Függőben'),
            ],
          ),

          const SizedBox(height: 20),

          // KIVÁLASZTOTT DÁTUM ÉS ÖSSZEGZÉS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kiválasztott időszak:',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '2026. okt. 18. – okt. 19.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ÖSSZESEN:',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '70.000 Ft',
                      style: TextStyle(color: Color(0xFF8BC541), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CSEMPE ÉPÍTŐ METÓDUS ÁTLÓS OSZTÁSSAL
  Widget _buildCalendarTile(int day, String status) {
    final String priceText = '${(widget.pricePerNight / 1000).round()}.000';

    if (status == 'selected') {
      return Container(
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: _buildTileText(day, priceText, Colors.white),
      );
    }

    if (status == 'pending') {
      return Container(
        decoration: BoxDecoration(
          color: orangeColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: _buildTileText(day, '', Colors.white),
      );
    }

    if (status == 'booked') {
      return Container(
        decoration: BoxDecoration(
          color: redColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: _buildTileText(day, '', Colors.white),
      );
    }

    // ÁTLÓS FÉL-SZÍNEZETT CSEMPÉK (Start/End váltások)
    if (status == 'half_pending_start' || status == 'half_pending_end' || status == 'half_booked_start' || status == 'half_booked_end') {
      final Color secondColor = (status.contains('pending')) ? orangeColor : redColor;
      final bool isStart = status.contains('start');

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: _DiagonalTilePainter(
            color1: isStart ? greenColor : secondColor,
            color2: isStart ? secondColor : greenColor,
          ),
          child: _buildTileText(day, priceText, Colors.white),
        ),
      );
    }

    // ALAPÉRTELMEZETT SZABAD NAP (ZÖLD)
    return Container(
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: _buildTileText(day, priceText, Colors.white),
    );
  }

  Widget _buildTileText(int day, String price, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        if (price.isNotEmpty)
          Text(
            price,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.85),
              fontSize: 8,
            ),
          ),
      ],
    );
  }
}

// ÁTLÓS RAJZOLÓ (DIAGONAL PAINTER) A FÉLIG SZÍNEZETT DÁTUMOKHOZ
class _DiagonalTilePainter extends CustomPainter {
  final Color color1;
  final Color color2;

  _DiagonalTilePainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// DAY HEADER
class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// JELMAGYARÁZAT ELEM
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text(
            '26',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}