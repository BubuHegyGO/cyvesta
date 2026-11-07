import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';

/// Valódi, hónapozható foglalási naptár. A foglalt éjszakák (pl. iCal-ból) pirosak, nem választhatók.
class BookingCalendarWidget extends StatefulWidget {
  /// Éjszakánkénti ár (csak ha a hirdetés éjszakai áras), különben null.
  final int? pricePerNight;

  /// Foglalt éjszakák (csak dátum, idő nélkül).
  final Set<DateTime> blockedNights;

  /// Van-e a hirdetéshez kapcsolt külső naptár (ettől függ a tájékoztató szöveg).
  final bool synced;

  final Function(DateTimeRange?, int)? onBookingSelected;

  const BookingCalendarWidget({
    super.key,
    this.pricePerNight,
    this.blockedNights = const {},
    this.synced = false,
    this.onBookingSelected,
  });

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  static const Color greenColor = Color(0xFF5A9E32);
  static const Color redColor = Color(0xFFC83A3A);
  static const Color blueColor = Color(0xFF4B80C3);
  static const Color pastColor = Color(0xFF3A3A5A);
  static const Color deepBlueBackground = Color(0xFF080838);

  late DateTime _month;
  DateTime? _start;
  DateTime? _end;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _month = DateTime(_today.year, _today.month);
  }

  DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

  bool _isBlocked(DateTime day) => widget.blockedNights.contains(_d(day));

  /// A [start, end) éjszakák mind szabadok-e.
  bool _rangeFree(DateTime start, DateTime end) {
    var d = start;
    while (d.isBefore(end)) {
      if (_isBlocked(d)) return false;
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return true;
  }

  void _onDayTap(DateTime day) {
    if (day.isBefore(_today)) return;

    setState(() {
      if (_start == null || _end != null) {
        // Új választás: érkezés napja (foglalt éjszakán nem lehet érkezni)
        if (_isBlocked(day)) return;
        _start = day;
        _end = null;
      } else {
        if (!day.isAfter(_start!)) {
          if (_isBlocked(day)) return;
          _start = day;
          return;
        }
        // Távozás napja lehet foglalt nap is, ha a köztes éjszakák szabadok.
        if (!_rangeFree(_start!, day)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLanguage.currentLocale.value == 'hu'
                  ? 'A kiválasztott időszakban foglalt napok vannak.'
                  : 'There are booked days in the selected period.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        _end = day;
      }
    });

    if (_start != null && _end != null) {
      final nights = _end!.difference(_start!).inDays;
      widget.onBookingSelected?.call(DateTimeRange(start: _start!, end: _end!), nights);
    }
  }

  static const Map<String, List<String>> _months = {
    'hu': ['Január', 'Február', 'Március', 'Április', 'Május', 'Június', 'Július', 'Augusztus', 'Szeptember', 'Október', 'November', 'December'],
    'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    'de': ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
    'el': ['Ιανουάριος', 'Φεβρουάριος', 'Μάρτιος', 'Απρίλιος', 'Μάιος', 'Ιούνιος', 'Ιούλιος', 'Αύγουστος', 'Σεπτέμβριος', 'Οκτώβριος', 'Νοέμβριος', 'Δεκέμβριος'],
    'ru': ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'],
  };

  String _monthTitle(String locale) {
    final names = _months[locale] ?? _months['en']!;
    return '${names[_month.month - 1]} ${_month.year}';
  }

  List<String> _getWeekDays(String locale) {
    switch (locale) {
      case 'en':
        return ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      case 'el':
        return ['ΔΕ', 'ΤΡ', 'ΤΕ', 'ΠΕ', 'ΠΑ', 'ΣΑ', 'ΚΥ'];
      case 'de':
        return ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
      case 'ru':
        return ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
      case 'hu':
      default:
        return ['HÉ', 'KE', 'SZE', 'CSÜ', 'PÉ', 'SZO', 'VA'];
    }
  }

  String _fmt(DateTime d) => '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';

  void _changeMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    final first = DateTime(_today.year, _today.month);
    if (next.isBefore(first)) return; // múltba nem lapozunk
    setState(() => _month = next);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isHu = locale == 'hu';
        final weekDays = _getWeekDays(locale);
        final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
        final offset = DateTime(_month.year, _month.month, 1).weekday - 1; // hétfő = 0

        final nights = (_start != null && _end != null) ? _end!.difference(_start!).inDays : 0;
        final total = (widget.pricePerNight != null && nights > 0) ? nights * widget.pricePerNight! : null;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: deepBlueBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF99FF99), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_monthTitle(locale), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white70),
                        onPressed: () => _changeMonth(-1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white70),
                        onPressed: () => _changeMonth(1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((d) => _DayHeader(d)).toList(),
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
                itemCount: offset + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < offset) return const SizedBox();
                  final day = DateTime(_month.year, _month.month, index - offset + 1);
                  return GestureDetector(onTap: () => _onDayTap(day), child: _tile(day));
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(color: greenColor, label: AppLanguage.tr('calendar_free')),
                  _LegendItem(color: redColor, label: AppLanguage.tr('calendar_booked')),
                  _LegendItem(color: blueColor, label: isHu ? 'Kiválasztva' : 'Selected'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.synced
                    ? (isHu ? 'A foglalt napok a hirdető külső naptárából (iCal) frissülnek.' : 'Booked days are synced from the host\'s external calendar (iCal).')
                    : (isHu ? 'A hirdető nem kapcsolt külső naptárat – a szabad időpontot egyeztesd vele.' : 'No external calendar linked – please confirm availability with the host.'),
                style: const TextStyle(color: Colors.white54, fontSize: 10.5),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLanguage.tr('selected_dates_label'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        (_start != null && _end != null)
                            ? '${_fmt(_start!)} – ${_fmt(_end!)} ($nights ${isHu ? 'éj' : 'nights'})'
                            : (_start != null)
                                ? '${_fmt(_start!)} – ${isHu ? 'válassz távozást' : 'pick check-out'}'
                                : (isHu ? 'Válassz érkezési napot' : 'Pick a check-in day'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  if (total != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(AppLanguage.tr('total_price_label'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('€$total', style: const TextStyle(color: Color(0xFF8BC541), fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                ],
              ),
              if (_start != null && _end != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9F1C), foregroundColor: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(isHu ? 'Kész' : 'Done'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _tile(DateTime day) {
    final past = day.isBefore(_today);
    final blocked = _isBlocked(day);
    final selected = _start != null &&
        (_end == null ? day == _start : (!day.isBefore(_start!) && !day.isAfter(_end!)));

    Color color;
    if (selected) {
      color = blueColor;
    } else if (past) {
      color = pastColor;
    } else if (blocked) {
      color = redColor;
    } else {
      color = greenColor;
    }

    final showPrice = !past && !blocked && widget.pricePerNight != null;

    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${day.day}', style: TextStyle(color: past ? Colors.white38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          if (showPrice)
            Text('€${widget.pricePerNight}', style: const TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
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
        style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
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
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
      ],
    );
  }
}
