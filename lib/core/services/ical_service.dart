import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ICalBooking {
  final DateTime start;
  final DateTime end;
  final String summary;

  ICalBooking({required this.start, required this.end, required this.summary});
}

class ICalService {
  /// Letölti és feldolgozza az iCal (.ics) naptárat (Airbnb, Booking.com, VRBO)
  static Future<List<ICalBooking>> fetchBookingsFromIcs(String icsUrl) async {
    if (icsUrl.isEmpty) return [];

    try {
      final response = await http.get(Uri.parse(icsUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return parseIcsContent(response.body);
      }
    } catch (e) {
      debugPrint("iCal letöltési hiba ($icsUrl): $e");
    }
    return [];
  }

  /// ICS formátum értelmezése (RFC 5545 szabvány szerint)
  static List<ICalBooking> parseIcsContent(String icsData) {
    final List<ICalBooking> bookings = [];
    final lines = const LineSplitter().convert(icsData);

    bool insideEvent = false;
    DateTime? dtStart;
    DateTime? dtEnd;
    String summary = 'Foglalt';

    for (var line in lines) {
      line = line.trim();
      if (line == 'BEGIN:VEVENT') {
        insideEvent = true;
        dtStart = null;
        dtEnd = null;
        summary = 'Foglalt';
      } else if (line == 'END:VEVENT') {
        if (insideEvent && dtStart != null && dtEnd != null) {
          bookings.add(ICalBooking(
            start: DateTime(dtStart.year, dtStart.month, dtStart.day),
            end: DateTime(dtEnd.year, dtEnd.month, dtEnd.day),
            summary: summary,
          ));
        }
        insideEvent = false;
      } else if (insideEvent) {
        if (line.startsWith('DTSTART')) {
          dtStart = _parseIcsDate(line);
        } else if (line.startsWith('DTEND')) {
          dtEnd = _parseIcsDate(line);
        } else if (line.startsWith('SUMMARY:')) {
          summary = line.substring(8);
        }
      }
    }
    return bookings;
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