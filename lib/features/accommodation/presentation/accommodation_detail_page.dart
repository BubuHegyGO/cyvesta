import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/ical_service.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';
import '../../chat/chat_detail_page.dart';

class AccommodationDetailPage extends StatefulWidget {
  final Map<String, dynamic> accommodationData;

  const AccommodationDetailPage({super.key, required this.accommodationData});

  @override
  State<AccommodationDetailPage> createState() => _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  DateTimeRange? _selectedDateRange;
  List<ICalBooking> _externalBookings = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 20),
      end: DateTime(now.year, now.month, 25),
    );

    _loadIcalFeed();
  }

  void _loadIcalFeed() async {
    final icalUrl = widget.accommodationData['ical_url']?.toString() ?? '';
    if (icalUrl.isNotEmpty) {
      final bookings = await ICalService.fetchBookingsFromIcs(icalUrl);
      if (mounted) {
        setState(() {
          _externalBookings = bookings;
        });
      }
    } else {
      setState(() {
        _externalBookings = [
          ICalBooking(start: DateTime(2026, 8, 8), end: DateTime(2026, 8, 14), summary: 'Airbnb Booking'),
          ICalBooking(start: DateTime(2026, 8, 27), end: DateTime(2026, 8, 31), summary: 'Booking.com'),
        ];
      });
    }
  }

  void _openCustomCalendarModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomCalendarModal(
        initialRange: _selectedDateRange,
        externalBookings: _externalBookings,
        onRangeSelected: (range) {
          setState(() => _selectedDateRange = range);
        },
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone, String title) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final nights = _selectedDateRange != null ? _selectedDateRange!.duration.inDays : 5;
    final startStr = _selectedDateRange != null
        ? "${_selectedDateRange!.start.year}.${_selectedDateRange!.start.month.toString().padLeft(2, '0')}.${_selectedDateRange!.start.day.toString().padLeft(2, '0')}"
        : "";
    final endStr = _selectedDateRange != null
        ? "${_selectedDateRange!.end.year}.${_selectedDateRange!.end.month.toString().padLeft(2, '0')}.${_selectedDateRange!.end.day.toString().padLeft(2, '0')}"
        : "";

    final msg = Uri.encodeComponent(
      "Hello! I am inquiring about $title via CYVESTA App. Requested dates: $startStr - $endStr ($nights nights)."
    );
    final uri = Uri.parse("https://wa.me/$cleanPhone?text=$msg");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWebsite(String url) async {
    String finalUrl = url.trim();
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.accommodationData;
    final title = item['title']?.toString() ?? 'Cyprus Property';
    final location = item['location']?.toString() ?? 'Cyprus';
    final price = item['price']?.toString() ?? '';
    final rating = item['rating']?.toString() ?? '4.95';
    final imagePath = item['imagePath']?.toString() ?? 'assets/images/szarvas.png';
    final desc = item['description']?.toString() ??
        'Gyönyörű tengerparti ingatlan prémium felszereltséggel, medencével és lélegzetelállító kilátással.';
    final phone = item['phone']?.toString() ?? item['whatsapp']?.toString() ?? '+35799123456';
    final website = item['website']?.toString() ?? 'https://cyvesta.com';

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isEn = locale != 'hu';

        final descTitle = isEn ? 'Description & Details 📖' : 'Leírás & Részletek 📖';
        final calendarTitle = isEn ? 'Availability & iCal Calendar 📅' : 'Foglaltsági Naptár & iCal 📅';
        final changeDateText = isEn ? 'Select Dates ✏️' : 'Dátum kiválasztása ✏️';
        final nightsText = isEn ? 'nights' : 'éjszaka';
        final amenitiesTitle = isEn ? 'Amenities & Highlights 🏊' : 'Felszereltség & Jellemzők 🏊';
        final inAppChatText = isEn ? 'In-App Chat' : 'Belső Chat';
        final bookCtaText = isEn ? 'WhatsApp Contact' : 'Közvetlen Kapcsolat (WhatsApp)';
        final websiteBtnText = isEn ? "Owner's Website 🌐" : 'Saját Weboldal Címe 🌐';

        final List<Map<String, dynamic>> amenities = [
          {'icon': Icons.sync_rounded, 'name': 'iCal Sync (Airbnb / Booking)'},
          {'icon': Icons.pool_rounded, 'name': isEn ? 'Private Pool' : 'Saját medence'},
          {'icon': Icons.wifi_rounded, 'name': 'High-Speed Wi-Fi'},
          {'icon': Icons.ac_unit_rounded, 'name': isEn ? 'Air Conditioning' : 'Klímaberendezés'},
          {'icon': Icons.local_parking_rounded, 'name': isEn ? 'Free Parking' : 'Ingyenes parkolás'},
          {'icon': Icons.waves_rounded, 'name': isEn ? 'Sea Panorama' : 'Tengeri panoráma'},
        ];

        final nightsCount = _selectedDateRange != null ? _selectedDateRange!.duration.inDays : 0;

        return CyvestaScaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 260,
                    pinned: true,
                    backgroundColor: const Color(0xFF061822),
                    leading: CircleAvatar(
                      backgroundColor: deepBlueIcon.withValues(alpha: 0.8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: mintGreenBorder, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: DataService.favoriteItems,
                        builder: (context, favs, child) {
                          final isFav = DataService.isFavorite(item);
                          return CircleAvatar(
                            backgroundColor: deepBlueIcon.withValues(alpha: 0.8),
                            child: IconButton(
                              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white, size: 20),
                              onPressed: () => DataService.toggleFavorite(item),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: deepBlueIcon, child: const Icon(Icons.villa_rounded, size: 60, color: mintGreenBorder)),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: turquoiseGlass,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder, width: 1.4),
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
                                        style: const TextStyle(color: textDark, fontSize: 16.5, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: sunnyGold, size: 14),
                                          const SizedBox(width: 4),
                                          Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: deepBlueIcon, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (price.isNotEmpty)
                                  Text(price, style: const TextStyle(color: deepBlueIcon, fontSize: 16, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // KAPCSOLATFELVÉTELI GOMBOK (WhatsApp + Belső Chat)
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.chat_rounded, size: 18),
                                  label: Text(bookCtaText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  onPressed: () => _launchWhatsApp(phone, title),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: deepBlueIcon,
                                    foregroundColor: mintGreenBorder,
                                    side: const BorderSide(color: mintGreenBorder, width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.forum_outlined, size: 18),
                                  label: Text(inAppChatText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatDetailPage(
                                          partnerName: title,
                                          partnerSubtitle: location,
                                          avatarPath: imagePath,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // SAJÁT WEBOLDAL CÍME GOMB (Teli, sötétkék prémium háttérrel)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF072A40),
                                foregroundColor: sunnyGold,
                                side: const BorderSide(color: sunnyGold, width: 1.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.language_rounded, size: 18, color: sunnyGold),
                              label: Text(
                                websiteBtnText,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.3),
                              ),
                              onPressed: () => _launchWebsite(website),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // FOGLALTSÁGI NAPTÁR SZEKCIÓ
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          calendarTitle,
                                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.cloud_done_rounded, color: mintGreenBorder, size: 16),
                                      ],
                                    ),
                                    if (nightsCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: sunnyGold, borderRadius: BorderRadius.circular(6)),
                                        child: Text(
                                          '$nightsCount $nightsText',
                                          style: const TextStyle(color: textDark, fontSize: 10.5, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _openCustomCalendarModal,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: turquoiseGlass,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: mintGreenBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_month_rounded, color: deepBlueIcon, size: 20),
                                            const SizedBox(width: 10),
                                            Text(
                                              _selectedDateRange != null
                                                  ? "${_selectedDateRange!.start.month.toString().padLeft(2, '0')}.${_selectedDateRange!.start.day.toString().padLeft(2, '0')} ➔ ${_selectedDateRange!.end.month.toString().padLeft(2, '0')}.${_selectedDateRange!.end.day.toString().padLeft(2, '0')}"
                                                  : changeDateText,
                                              style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          changeDateText,
                                          style: const TextStyle(color: deepBlueIcon, fontSize: 11, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // LEÍRÁS
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  descTitle,
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  desc,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // FELSZERELTSÉG
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amenitiesTitle,
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: amenities.map((a) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF093753),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(a['icon'] as IconData, color: sunnyGold, size: 16),
                                        const SizedBox(width: 6),
                                        Text(a['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomCalendarModal extends StatefulWidget {
  final DateTimeRange? initialRange;
  final List<ICalBooking> externalBookings;
  final ValueChanged<DateTimeRange> onRangeSelected;

  const _CustomCalendarModal({
    this.initialRange,
    required this.externalBookings,
    required this.onRangeSelected,
  });

  @override
  State<_CustomCalendarModal> createState() => _CustomCalendarModalState();
}

class _CustomCalendarModalState extends State<_CustomCalendarModal> {
  static const Color darkBg = Color(0xFF061822);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color sunnyGold = Color(0xFFFF9F1C);
  static const Color textDark = Color(0xFF0F172A);

  DateTime _focusedMonth = DateTime(2026, 8, 1);
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange?.start;
    _endDate = widget.initialRange?.end;
    if (_startDate != null) {
      _focusedMonth = DateTime(_startDate!.year, _startDate!.month, 1);
    }
  }

  bool _isDateBlockedByIcal(DateTime day) {
    for (final booking in widget.externalBookings) {
      if (day.isAfter(booking.start.subtract(const Duration(days: 1))) && day.isBefore(booking.end)) {
        return true;
      }
    }
    return false;
  }

  void _onDayTapped(DateTime day) {
    if (_isDateBlockedByIcal(day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ez az időpont már foglalt (Airbnb / Booking szinkronizáció) 🔒')),
      );
      return;
    }

    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = day;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (day.isBefore(_startDate!)) {
          _startDate = day;
        } else if (day.isAtSameMomentAs(_startDate!)) {
          _startDate = day;
          _endDate = null;
        } else {
          _endDate = day;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLanguage.currentLocale.value;
    final isEn = locale != 'hu';

    final monthNames = isEn
        ? ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
        : ['Január', 'Február', 'Március', 'Április', 'Május', 'Június', 'Július', 'Augusztus', 'Szeptember', 'Október', 'November', 'December'];

    final weekDays = isEn ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'] : ['H', 'K', 'Sze', 'Cs', 'P', 'Szo', 'V'];

    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: mintGreenBorder, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 45,
              height: 4,
              decoration: BoxDecoration(color: mintGreenBorder.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    isEn ? 'Select Dates 📅' : 'Időpont Kiválasztása 📅',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF093753), borderRadius: BorderRadius.circular(6)),
                    child: const Text('iCal Live Sync', style: TextStyle(color: mintGreenBorder, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: mintGreenBorder, size: 28),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                "${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}",
                style: const TextStyle(color: sunnyGold, fontSize: 15, fontWeight: FontWeight.w900),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: mintGreenBorder, size: 28),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((d) => SizedBox(
              width: 38,
              child: Text(d, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            )).toList(),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayOffset = index - (firstDayWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox();
                }

                final currentDay = DateTime(_focusedMonth.year, _focusedMonth.month, dayOffset + 1);

                bool isIcalBlocked = false;
                bool isIcalCheckIn = false;
                bool isIcalCheckOut = false;

                for (final b in widget.externalBookings) {
                  if (DateUtils.isSameDay(b.start, currentDay)) isIcalCheckIn = true;
                  if (DateUtils.isSameDay(b.end, currentDay)) isIcalCheckOut = true;
                  if (currentDay.isAfter(b.start) && currentDay.isBefore(b.end)) {
                    isIcalBlocked = true;
                  }
                }

                final isUserCheckIn = _startDate != null && DateUtils.isSameDay(_startDate!, currentDay);
                final isUserCheckOut = _endDate != null && DateUtils.isSameDay(_endDate!, currentDay);
                final isUserRange = _startDate != null && _endDate != null && currentDay.isAfter(_startDate!) && currentDay.isBefore(_endDate!);

                final isCheckIn = isUserCheckIn || isIcalCheckIn;
                final isCheckOut = isUserCheckOut || isIcalCheckOut;
                final isInRange = isUserRange || isIcalBlocked;

                return GestureDetector(
                  onTap: () => _onDayTapped(currentDay),
                  child: CustomPaint(
                    painter: _DiagonalDayPainter(
                      isCheckIn: isCheckIn,
                      isCheckOut: isCheckOut,
                      isInRange: isInRange,
                      hasCheckOutSelected: _endDate != null || isIcalCheckOut,
                    ),
                    child: Center(
                      child: Text(
                        '${currentDay.day}',
                        style: TextStyle(
                          color: (isCheckIn || isCheckOut || isInRange) ? textDark : Colors.white,
                          fontSize: 13,
                          fontWeight: (isCheckIn || isCheckOut || isInRange) ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Jelmagyarázat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: deepBlueIcon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  customWidget: Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF093753), borderRadius: BorderRadius.circular(3), border: Border.all(color: Colors.white24))),
                  label: isEn ? 'Available' : 'Szabad',
                ),
                _buildLegendItem(
                  customWidget: Container(width: 14, height: 14, decoration: BoxDecoration(color: sunnyGold, borderRadius: BorderRadius.circular(3))),
                  label: isEn ? 'Booked (iCal)' : 'Foglalt (iCal)',
                ),
                _buildLegendItem(
                  customWidget: CustomPaint(
                    size: const Size(14, 14),
                    painter: _DiagonalDayPainter(isCheckIn: true, isCheckOut: false, isInRange: false, hasCheckOutSelected: true),
                  ),
                  label: isEn ? 'Check-in/out' : 'Érkezés/Távozás',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sunnyGold,
                foregroundColor: textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_startDate != null) {
                  final finalEnd = _endDate ?? _startDate!.add(const Duration(days: 1));
                  widget.onRangeSelected(DateTimeRange(start: _startDate!, end: finalEnd));
                }
                Navigator.pop(context);
              },
              child: Text(
                isEn ? 'Apply Dates' : 'Időpont Jóváhagyása',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Widget customWidget, required String label}) {
    return Row(
      children: [
        customWidget,
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DiagonalDayPainter extends CustomPainter {
  final bool isCheckIn;
  final bool isCheckOut;
  final bool isInRange;
  final bool hasCheckOutSelected;

  _DiagonalDayPainter({
    required this.isCheckIn,
    required this.isCheckOut,
    required this.isInRange,
    required this.hasCheckOutSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final defaultBg = Paint()..color = const Color(0xFF093753);
    final fillPaint = Paint()..color = const Color(0xFFFF9F1C);
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8));

    canvas.drawRRect(rrect, defaultBg);

    if (isInRange) {
      canvas.drawRRect(rrect, fillPaint);
    } else if (isCheckIn && !hasCheckOutSelected) {
      canvas.drawRRect(rrect, fillPaint);
    } else if (isCheckIn) {
      final path = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.clipRRect(rrect);
      canvas.drawPath(path, fillPaint);
    } else if (isCheckOut) {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(0, size.height)
        ..close();
      canvas.clipRRect(rrect);
      canvas.drawPath(path, fillPaint);
    }

    final borderPaint = Paint()
      ..color = (isCheckIn || isCheckOut) ? Colors.white : const Color(0xFF99FF99).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isCheckIn || isCheckOut) ? 1.5 : 0.8;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalDayPainter oldDelegate) {
    return oldDelegate.isCheckIn != isCheckIn ||
        oldDelegate.isCheckOut != isCheckOut ||
        oldDelegate.isInRange != isInRange ||
        oldDelegate.hasCheckOutSelected != hasCheckOutSelected;
  }
}