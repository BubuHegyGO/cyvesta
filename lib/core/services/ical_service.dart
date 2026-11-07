import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ICalBooking {
  final DateTime start; // első foglalt éjszaka
  final DateTime end; // távozás napja (kizárólagos, RFC 5545 szerint)
  final String summary;

  ICalBooking({required this.start, required this.end, required this.summary});
}

class ICalService {
  static const int _maxBytes = 2 * 1024 * 1024; // 2 MB felső korlát

  /// A beírt linket egységesíti: webcal:// -> https://. Csak https engedélyezett.
  static String? normalizeUrl(String raw) {
    var url = raw.trim();
    if (url.isEmpty) return null;
    if (url.toLowerCase().startsWith('webcal://')) {
      url = 'https://${url.substring(9)}';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    if (url.length > 500) return null;
    return url;
  }

  /// Letölti és feldolgozza az iCal (.ics) naptárat (Airbnb, Booking.com, VRBO).
  /// Hiba esetén null-t ad (a hívó el tudja dönteni, mit mutat), üres naptárnál üres listát.
  static Future<List<ICalBooking>?> fetchBookingsFromIcs(String icsUrl) async {
    final url = normalizeUrl(icsUrl);
    if (url == null) return null;

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200 && response.bodyBytes.length <= _maxBytes) {
        return parseIcsContent(utf8.decode(response.bodyBytes, allowMalformed: true));
      }
    } catch (e) {
      debugPrint('iCal letöltési hiba: $e');
    }
    return null;
  }

  /// ICS formátum értelmezése (RFC 5545): sortörés-összefűzés, lemondott foglalások kihagyása.
  static List<ICalBooking> parseIcsContent(String icsData) {
    final List<ICalBooking> bookings = [];

    // A hosszú sorokat az ICS "behajtja" (a folytatósor szóközzel/tabbal kezdődik) – összefűzzük.
    final rawLines = const LineSplitter().convert(icsData);
    final lines = <String>[];
    for (final l in rawLines) {
      if ((l.startsWith(' ') || l.startsWith('\t')) && lines.isNotEmpty) {
        lines[lines.length - 1] += l.substring(1);
      } else {
        lines.add(l);
      }
    }

    bool insideEvent = false;
    DateTime? dtStart;
    DateTime? dtEnd;
    bool cancelled = false;
    String summary = 'Foglalt';

    for (var line in lines) {
      line = line.trim();
      if (line == 'BEGIN:VEVENT') {
        insideEvent = true;
        dtStart = null;
        dtEnd = null;
        cancelled = false;
        summary = 'Foglalt';
      } else if (line == 'END:VEVENT') {
        if (insideEvent && !cancelled && dtStart != null) {
          var end = dtEnd ?? dtStart.add(const Duration(days: 1));
          if (!end.isAfter(dtStart)) end = dtStart.add(const Duration(days: 1));
          bookings.add(ICalBooking(start: dtStart, end: end, summary: summary));
        }
        insideEvent = false;
      } else if (insideEvent) {
        if (line.startsWith('DTSTART')) {
          dtStart = _parseIcsDate(line);
        } else if (line.startsWith('DTEND')) {
          dtEnd = _parseIcsDate(line);
        } else if (line.startsWith('STATUS:') && line.substring(7).trim().toUpperCase() == 'CANCELLED') {
          cancelled = true;
        } else if (line.startsWith('SUMMARY:')) {
          summary = line.substring(8);
        }
      }
    }
    return bookings;
  }

  /// A foglalt éjszakák halmaza (csak dátum, idő nélkül). A távozás napja nem számít foglaltnak.
  static Set<DateTime> blockedNights(List<ICalBooking> bookings) {
    final set = <DateTime>{};
    for (final b in bookings) {
      var d = DateTime(b.start.year, b.start.month, b.start.day);
      final end = DateTime(b.end.year, b.end.month, b.end.day);
      var guard = 0;
      while (d.isBefore(end) && guard < 800) {
        set.add(d);
        d = DateTime(d.year, d.month, d.day + 1);
        guard++;
      }
    }
    return set;
  }

  static DateTime? _parseIcsDate(String line) {
    try {
      final valPart = line.split(':').last.trim();
      if (valPart.length >= 8) {
        final year = int.parse(valPart.substring(0, 4));
        final month = int.parse(valPart.substring(4, 6));
        final day = int.parse(valPart.substring(6, 8));
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }
}
