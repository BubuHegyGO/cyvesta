import 'package:flutter/material.dart';

class BookingCalendarWidget extends StatefulWidget {
  final int pricePerNight;
  final Function(DateTimeRange? range, int totalPrice) onBookingSelected;

  const BookingCalendarWidget({
    super.key,
    required this.pricePerNight,
    required this.onBookingSelected,
  });

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  static const Color accent = Color(0xFF8BC541); // Zöld (Szabad)
  static const Color bookedColor = Color(0xFFD32F2F); // Piros (Foglalt)
  static const Color pendingColor = Color(0xFFE67E22); // Narancs (Függőben)
  static const Color selectedColor = Color(0xFF2980B9); // Kék (Kijelölt)

  DateTime _focusedMonth = DateTime(2026, 10, 1);
  DateTime? _startDate;
  DateTime? _endDate;

  // Szimulált nézetbeli adatok (minta foglaltsághoz)
  final List<int> _bookedDays = [7, 8, 9, 10, 28, 29];
  final List<int> _pendingDays = [];

  // Dátum kijelölés logikája
  void _onDaySelected(int day) {
    if (_bookedDays.contains(day)) return; // Foglalt napra nem lehet kattintani

    final selected = DateTime(_focusedMonth.year, _focusedMonth.month, day);

    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = selected;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (selected.isBefore(_startDate!)) {
          _startDate = selected;
        } else {
          _endDate = selected;
        }
      }
    });

    if (_startDate != null && _endDate != null) {
      final range = DateTimeRange(start: _startDate!, end: _endDate!);
      final nights = range.duration.inDays;
      widget.onBookingSelected(range, nights * widget.pricePerNight);
    } else {
      widget.onBookingSelected(null, 0);
    }
  }

  int get _calculatedNights {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1 = Hétfő

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FEJLÉC (HÓNAP ÉS LÉPTETŐK)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // NAPOK NEVEI (MAGYARUL) - JAVÍTVA MainAxisAlignment.spaceAround
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeekdayText('HÉ'),
              _WeekdayText('KE'),
              _WeekdayText('SZE'),
              _WeekdayText('CSÜ'),
              _WeekdayText('PÉ'),
              _WeekdayText('SZO'),
              _WeekdayText('VA'),
            ],
          ),

          const SizedBox(height: 8),

          // NAPTÁR RÁCS
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (daysInMonth + (firstDayOfWeek - 1)),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek - 1) {
                return const SizedBox(); // Üres cellák a hónap kezdete előtt
              }

              final day = index - (firstDayOfWeek - 2);
              final currentDateTime = DateTime(_focusedMonth.year, _focusedMonth.month, day);

              bool isBooked = _bookedDays.contains(day);
              bool isPending = _pendingDays.contains(day);
              bool isSelected = false;

              if (_startDate != null && _endDate != null) {
                isSelected = (currentDateTime.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                    currentDateTime.isBefore(_endDate!.add(const Duration(days: 1))));
              } else if (_startDate != null) {
                isSelected = currentDateTime.isAtSameMomentAs(_startDate!);
              }

              Color tileColor = accent; // Alapértelmezett: Szabad (Zöld)
              if (isBooked) tileColor = bookedColor; // Foglalt (Piros)
              if (isPending) tileColor = pendingColor; // Függőben (Narancs)
              if (isSelected) tileColor = selectedColor; // Kijelölt (Kék)

              return GestureDetector(
                onTap: () => _onDaySelected(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.pricePerNight ~/ 1000}k',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),

          // JELMAGYARÁZAT (JELÖLÉSEK MAGYARUL)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Szabad', accent),
              _buildLegendItem('Foglalt', bookedColor),
              _buildLegendItem('Függőben', pendingColor),
              _buildLegendItem('Kijelölve', selectedColor),
            ],
          ),

          const SizedBox(height: 16),

          // ÖSSZEGZŐ SÁV AZ ALJÁN
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dátumok:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      _startDate == null
                          ? 'Válassz dátumot'
                          : _endDate == null
                              ? '${_formatDate(_startDate!)} - ...'
                              : '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Összesen:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      '${_calculatedNights * widget.pricePerNight} Ft',
                      style: const TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Január', 'Február', 'Március', 'Április', 'Május', 'Június',
      'Július', 'Augusztus', 'Szeptember', 'Október', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}.';
  }
}

class _WeekdayText extends StatelessWidget {
  final String text;
  const _WeekdayText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}