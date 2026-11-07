import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/ical_service.dart';
import '../../../core/widgets/photo_gallery.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';
import '../../chat/chat_detail_page.dart';
import '../../map/map_page.dart';
import 'steps/listing_details_form.dart' show ListingAmenities;
import 'widgets/booking_calendar_widget.dart';

class AccommodationDetailPage extends StatefulWidget {
  final Map<String, dynamic> accommodationData;

  const AccommodationDetailPage({
    super.key,
    required this.accommodationData,
  });

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

  Set<DateTime> _blockedNights = {};
  bool _icalLoading = false;
  bool _icalSynced = false;

  @override
  void initState() {
    super.initState();
    final item = widget.accommodationData;
    final cat = item['category']?.toString().toLowerCase() ?? '';
    final icalUrl = item['icalUrl']?.toString() ?? '';
    // Naptár-szinkron csak kiadó hirdetésnél
    if (cat != 'sale' && icalUrl.isNotEmpty) {
      _loadIcal(icalUrl);
    }
  }

  Future<void> _loadIcal(String url) async {
    setState(() => _icalLoading = true);
    final bookings = await ICalService.fetchBookingsFromIcs(url);
    if (!mounted) return;
    setState(() {
      _icalLoading = false;
      if (bookings != null) {
        _blockedNights = ICalService.blockedNights(bookings);
        _icalSynced = true;
      }
    });
  }

  String _datesText() {
    final r = _selectedDateRange;
    if (r == null) return '';
    String f(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return ' (${f(r.start)} – ${f(r.end)})';
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) {
      _snack('A hirdető nem adott meg telefonszámot.');
      return;
    }
    final text = 'Érdeklődöm a következő hirdetés iránt: $title${_datesText()}';
    final url = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(text)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _snack('A WhatsApp nem nyitható meg.');
    }
  }

  void _openChat(Map<String, dynamic> item, String title) {
    final uid = AuthState.currentUserId;
    if (uid == null) {
      _snack('Az üzenetküldéshez jelentkezz be.');
      return;
    }
    final listingId = item['id']?.toString() ?? '';
    final partnerId = item['partnerId']?.toString() ?? '';
    if (listingId.isEmpty || partnerId.isEmpty) {
      _snack('Ehhez a hirdetéshez nem érhető el az üzenetküldés.');
      return;
    }
    if (partnerId == uid) {
      _snack('Ez a saját hirdetésed.');
      return;
    }
    final name = item['contactName']?.toString().trim() ?? '';
    final partnerName = name.isNotEmpty ? name : 'Hirdető';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          seed: ChatSeed(listingId: listingId, listingTitle: title, partnerId: partnerId, partnerName: partnerName),
          partnerName: partnerName,
          partnerSubtitle: title,
          initialText: _selectedDateRange == null ? null : 'Szia! Érdeklődöm a hirdetés iránt${_datesText()}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.accommodationData;
    final title = item['title']?.toString() ?? 'CYVESTA Ingatlan';
    final location = item['location']?.toString() ?? 'Ciprus';
    final price = item['price']?.toString() ?? '';
    final rating = item['rating']?.toString() ?? '4.95';
    final imagePath = item['imagePath']?.toString() ?? 'assets/images/szarvas.png';
    final category = item['category']?.toString().toLowerCase() ?? '';
    
    final bool isSale = category == 'sale';
    final details = item['details'] is Map ? Map<String, dynamic>.from(item['details'] as Map) : <String, dynamic>{};
    final galleryImages = (item['imageUrls'] is List && (item['imageUrls'] as List).isNotEmpty)
        ? (item['imageUrls'] as List).map((e) => e.toString()).toList()
        : [imagePath];
    final contactPhone = item['contactPhone']?.toString() ?? '';
    final nightly = (item['priceUnit'] == 'night' && item['priceValue'] is num) ? (item['priceValue'] as num).round() : null;
    final userDescription = item['description']?.toString().trim() ?? '';

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      PhotoGallery(images: galleryImages, height: 260),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: CircleAvatar(
                          backgroundColor: deepBlueIcon,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: turquoiseGlass,
                            borderRadius: BorderRadius.circular(18),
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
                                      style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  if (rating.isNotEmpty)
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
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: deepBlueIcon, size: 16),
                                  const SizedBox(width: 4),
                                  Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12.5, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (price.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    price,
                                    style: const TextStyle(color: sunnyGold, fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.chat_rounded, size: 18),
                                label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                onPressed: () => _openWhatsApp(contactPhone, title),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: deepBlueIcon,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: const BorderSide(color: mintGreenBorder, width: 1),
                                ),
                                icon: const Icon(Icons.forum_rounded, size: 18),
                                // Fordított Belső Chat gomb:
                                label: Text(AppLanguage.tr('btn_internal_chat'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                onPressed: () => _openChat(item, title),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (isSale) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF093753),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: sunnyGold, width: 1.4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ingatlan Adatok & Tulajdonos 🏠',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const Divider(color: Colors.white24, height: 16),
                                ..._saleRows(details),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          if (details.isNotEmpty) ...[
                            _rentDetailsCard(details),
                            const SizedBox(height: 16),
                          ],
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF093753),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: mintGreenBorder, width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLanguage.tr('calendar_section_title'),
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                if (_icalLoading)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: LinearProgressIndicator(minHeight: 2),
                                  ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            color: deepBlueIcon,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                            border: Border(top: BorderSide(color: mintGreenBorder, width: 1)),
                                          ),
                                          child: SingleChildScrollView(
                                            child: BookingCalendarWidget(
                                              pricePerNight: nightly,
                                              blockedNights: _blockedNights,
                                              synced: _icalSynced,
                                              onBookingSelected: (range, nightCount) {
                                                if (range != null) {
                                                  setState(() {
                                                    _selectedDateRange = range;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: turquoiseGlass,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, color: textDark, size: 18),
                                            const SizedBox(width: 8),
                                            // Fordított Dátum kiválasztása gomb:
                                            Text(
                                              _selectedDateRange == null
                                                  ? AppLanguage.tr('btn_select_date')
                                                  : '${_selectedDateRange!.start.toString().substring(5, 10)} ➔ ${_selectedDateRange!.end.toString().substring(5, 10)}',
                                              style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 12.5),
                                            ),
                                          ],
                                        ),
                                        // Fordított Módosítás gomb:
                                        Text(
                                          AppLanguage.tr('btn_modify'),
                                          style: const TextStyle(color: textDark, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF093753),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLanguage.tr('details_section_title'),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userDescription.isNotEmpty
                                    ? userDescription
                                    : (isSale ? AppLanguage.tr('desc_sale') : AppLanguage.tr('desc_rent')),
                                style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: turquoiseGlass,
                              foregroundColor: textDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: mintGreenBorder, width: 1.2),
                            ),
                            icon: const Icon(Icons.map_rounded, size: 20),
                            // Fordított Megtekintés Térképen gomb:
                            label: Text(
                              AppLanguage.tr('btn_view_map'),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _num(dynamic v) {
    if (v is! num) return null;
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  List<Widget> _spaced(List<Widget> rows) {
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) out.add(const SizedBox(height: 8));
      out.add(rows[i]);
    }
    return out;
  }

  Widget _amenityWrap(dynamic keys, Map<String, String> labels) {
    final list = keys is List ? keys.map((e) => e.toString()).where(labels.containsKey).toList() : <String>[];
    if (list.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: list
          .map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mintGreenBorder.withValues(alpha: 0.5)),
                ),
                child: Text(labels[k]!, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
              ))
          .toList(),
    );
  }

  List<Widget> _saleRows(Map<String, dynamic> d) {
    final rows = <Widget>[];
    final area = _num(d['areaM2']);
    if (area != null) rows.add(_buildInfoRow(Icons.aspect_ratio_rounded, 'Alapterület:', '$area m²'));
    final plot = _num(d['plotM2']);
    if (plot != null) rows.add(_buildInfoRow(Icons.landscape_rounded, 'Telek:', '$plot m²'));
    final bed = _num(d['bedrooms']);
    if (bed != null) rows.add(_buildInfoRow(Icons.meeting_room_rounded, 'Hálószobák:', bed));
    final bath = _num(d['bathrooms']);
    if (bath != null) rows.add(_buildInfoRow(Icons.bathtub_rounded, 'Fürdőszobák:', bath));
    final floor = _num(d['floor']);
    if (floor != null) rows.add(_buildInfoRow(Icons.stairs_rounded, 'Emelet:', floor == '0' ? 'Földszint' : '$floor. emelet'));
    final year = _num(d['yearBuilt']);
    if (year != null) rows.add(_buildInfoRow(Icons.calendar_month_rounded, 'Építés éve:', year));
    final cond = ListingAmenities.conditions[d['condition']?.toString()];
    if (cond != null) rows.add(_buildInfoRow(Icons.home_repair_service_rounded, 'Állapot:', cond));
    final park = _num(d['parkingSpaces']);
    if (park != null && park != '0') rows.add(_buildInfoRow(Icons.local_parking_rounded, 'Parkolóhely:', park));
    if (d['titleDeed'] == true) rows.add(_buildInfoRow(Icons.verified_rounded, 'Title deed:', 'Rendelkezésre áll'));
    final extras = _amenityWrap(d['amenities'], ListingAmenities.sale);
    final out = _spaced(rows);
    if (extras is! SizedBox) {
      out.add(const SizedBox(height: 12));
      out.add(extras);
    }
    return out;
  }

  Widget _rentDetailsCard(Map<String, dynamic> d) {
    final rows = <Widget>[];
    final guests = _num(d['guests']);
    if (guests != null) rows.add(_buildInfoRow(Icons.groups_rounded, 'Maximum vendég:', guests));
    final bed = _num(d['bedrooms']);
    if (bed != null) rows.add(_buildInfoRow(Icons.meeting_room_rounded, 'Hálószobák:', bed));
    final beds = _num(d['beds']);
    if (beds != null) rows.add(_buildInfoRow(Icons.bed_rounded, 'Ágyak:', beds));
    final bath = _num(d['bathrooms']);
    if (bath != null) rows.add(_buildInfoRow(Icons.bathtub_rounded, 'Fürdőszobák:', bath));
    final area = _num(d['areaM2']);
    if (area != null) rows.add(_buildInfoRow(Icons.aspect_ratio_rounded, 'Alapterület:', '$area m²'));
    final amenities = _amenityWrap(d['amenities'], ListingAmenities.rent);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF093753),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sunnyGold, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Szálláshely adatai & felszereltség', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24, height: 16),
          ..._spaced(rows),
          if (amenities is! SizedBox) ...[const SizedBox(height: 12), amenities],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: sunnyGold, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
      ],
    );
  }
}