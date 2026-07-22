import 'package:flutter/material.dart';
import '../../core/services/data_service.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();

  // Szűrő állapotok
  RangeValues _priceRange = const RangeValues(10000, 80000);
  String? _selectedCategory;
  final Set<String> _selectedAmenities = {};

  final List<String> _categories = ['Lombház', 'Faház', 'Vendégház', 'Borkóstoló'];
  final List<String> _amenities = ['Dézsafürdő', 'Szauna', 'Kutyabarát', 'Panoráma', 'Klíma', 'Wi-Fi'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      if (_categories.contains(widget.initialQuery)) {
        _selectedCategory = widget.initialQuery;
      } else {
        _searchController.text = widget.initialQuery!;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Szűrő ablak megnyitása (Bottom Sheet)
  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D2113),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CÍM & BEZÁRÁS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Részletes Szűrők',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),

                  // 1. ÁR CSÚSZKA
                  Text(
                    'Árkategória: ${_priceRange.start.round()} Ft - ${_priceRange.end.round()} Ft / éj',
                    style: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 5000,
                    max: 100000,
                    divisions: 19,
                    activeColor: accent,
                    inactiveColor: Colors.white12,
                    onChanged: (values) {
                      setModalState(() => _priceRange = values);
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. KATEGÓRIA VÁLASZTÓ
                  const Text('Kategória', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: accent,
                        backgroundColor: Colors.black38,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          setModalState(() => _selectedCategory = selected ? cat : null);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 3. EXTRA SZOLGÁLTATÁSOK
                  const Text('Extrák & Szolgáltatások', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _amenities.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity),
                        selected: isSelected,
                        selectedColor: accent.withValues(alpha: 0.3),
                        checkmarkColor: accent,
                        backgroundColor: Colors.black38,
                        labelStyle: TextStyle(
                          color: isSelected ? accent : Colors.white70,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // SZŰRŐK TÖRLÉSE & ALKALMAZÁS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _priceRange = const RangeValues(10000, 80000);
                              _selectedCategory = null;
                              _selectedAmenities.clear();
                            });
                            setState(() {});
                          },
                          child: const Text('Alaphelyzet', style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Szűrés', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Szűrési logika
  List<Map<String, dynamic>> _getFilteredResults() {
    final all = [..._dataService.getAccommodations(), ..._dataService.getExperiences()];
    final query = _searchController.text.toLowerCase();

    return all.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final location = (item['location'] ?? '').toString().toLowerCase();
      final category = item['category'] ?? '';

      final matchesQuery = query.isEmpty || title.contains(query) || location.contains(query);
      final matchesCategory = _selectedCategory == null || category == _selectedCategory;

      final priceNum = int.tryParse((item['price'] ?? '').toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      final matchesPrice = priceNum >= _priceRange.start && priceNum <= _priceRange.end;

      return matchesQuery && matchesCategory && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _getFilteredResults();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // KERESŐSÁV + SZŰRŐ GOMB FEJLÉC
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Település, szállás név...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              child: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // SZŰRŐ GOMB
                  GestureDetector(
                    onTap: _openFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedCategory != null || _selectedAmenities.isNotEmpty
                            ? accent
                            : Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _selectedCategory != null || _selectedAmenities.isNotEmpty
                            ? Colors.black
                            : accent,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TALÁLATOK LISTÁJA
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'Nincs a szűrésnek megfelelő találat.',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return _buildResultCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccommodationDetailPage(accommodationData: item),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Image.asset(
                item['image'] ?? 'assets/images/matra_background.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'] ?? '',
                    style: const TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['location'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['price'] ?? '',
                    style: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}