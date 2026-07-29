import 'package:flutter/material.dart';

class BookingCalendarWidget extends StatefulWidget {
  final int pricePerNight;
  final Function(DateTimeRange?, int)? onBookingSelected;

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
  static const Color redColor = Color(0xFFC83A3A);
  static const Color orangeColor = Color(0xFFE29547);
  static const Color blueColor = Color(0xFF4B80C3);

  int? _selectedStartDay = 18;
  int? _selectedEndDay = 19;

  final Map<int, String> _dayStatuses = const {
    6: 'half_pending_start',
    7: 'pending',
    8: 'pending',
    9: 'pending',
    10: 'pending',
    11: 'half_pending_end',
    27: 'half_booked_start',
    28: 'booked',
    29: 'booked',
    30: 'half_booked_end',
  };

  void _onDayTap(int day) {
    final status = _dayStatuses[day];
    if (status == 'booked' || status == 'pending') return;

    setState(() {
      if (_selectedStartDay == null || (_selectedStartDay != null && _selectedEndDay != null)) {
        _selectedStartDay = day;
        _selectedEndDay = null;
      } else if (_selectedStartDay != null && _selectedEndDay == null) {
        if (day >= _selectedStartDay!) {
          _selectedEndDay = day;
        } else {
          _selectedStartDay = day;
          _selectedEndDay = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int nightCount = (_selectedStartDay != null && _selectedEndDay != null)
        ? (_selectedEndDay! - _selectedStartDay! + 1)
        : (_selectedStartDay != null ? 1 : 0);
    final int totalPrice = nightCount * widget.pricePerNight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Július 2026',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white70),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 33,
            itemBuilder: (context, index) {
              if (index < 2) {
                return const SizedBox();
              }
              final day = index - 1;
              bool isSelected = false;
              if (_selectedStartDay != null && _selectedEndDay != null) {
                isSelected = day >= _selectedStartDay! && day <= _selectedEndDay!;
              } else if (_selectedStartDay != null) {
                isSelected = day == _selectedStartDay;
              }
              final status = isSelected ? 'selected' : (_dayStatuses[day] ?? 'available');

              return GestureDetector(
                onTap: () => _onDayTap(day),
                child: _buildCalendarTile(day, status),
              );
            },
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: greenColor, label: 'Szabad'),
              _LegendItem(color: redColor, label: 'Foglalt'),
              _LegendItem(color: orangeColor, label: 'Függőben'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kiválasztott dátumok:',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (_selectedStartDay != null && _selectedEndDay != null)
                        ? 'Júl $_selectedStartDay. – Júl $_selectedEndDay.'
                        : (_selectedStartDay != null)
                            ? 'Júl $_selectedStartDay.'
                            : 'Válassz dátumot',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Összesen:',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Ft',
                    style: const TextStyle(
                      color: Color(0xFF8BC541),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTile(int day, String status) {
    final String priceText = '${(widget.pricePerNight / 1000).round()}k Ft';

    if (status == 'selected') {
      return Container(
        decoration: BoxDecoration(color: blueColor, borderRadius: BorderRadius.circular(4)),
        child: _buildTileText(day, priceText, Colors.white),
      );
    }
    if (status == 'pending') {
      return Container(
        decoration: BoxDecoration(color: orangeColor, borderRadius: BorderRadius.circular(4)),
        child: _buildTileText(day, '', Colors.white),
      );
    }
    if (status == 'booked') {
      return Container(
        decoration: BoxDecoration(color: redColor, borderRadius: BorderRadius.circular(4)),
        child: _buildTileText(day, '', Colors.white),
      );
    }
    if (status.startsWith('half_')) {
      final Color secondColor = status.contains('pending') ? orangeColor : redColor;
      final bool isStart = status.contains('start');

      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: _DiagonalTilePainter(
            color1: isStart ? greenColor : secondColor,
            color2: isStart ? secondColor : greenColor,
          ),
          child: _buildTileText(day, priceText, Colors.white),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: greenColor, borderRadius: BorderRadius.circular(4)),
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
            fontSize: 12,
          ),
        ),
        if (price.isNotEmpty)
          Text(
            price,
            style: TextStyle(
              color: textColor.withAlpha(220),
              fontSize: 7.5,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

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

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: const Text(
            '26',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '- $label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}