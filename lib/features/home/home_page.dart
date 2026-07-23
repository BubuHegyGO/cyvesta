import 'dart:ui';
import 'package:flutter/material.dart';

import '../accommodation/presentation/accommodation_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  bool _isFilterExpanded = false;
  RangeValues _priceRange = const RangeValues(15000, 80000);

  final PageController _accommodationPageController = PageController(viewportFraction: 0.88);
  final PageController _experiencePageController = PageController(viewportFraction: 0.88);

  int _currentAccommodationIndex = 0;
  int _currentExperienceIndex = 0;

  final List<String> _regions = const [
    'Mátra', 'Bükk', 'Börzsöny', 'Zempléni-hegység', 'Cserhát',
    'Aggteleki-karszt', 'Cserehát', 'Dunántúli-középhegység', 'Bakony',
    'Pilis', 'Gerecse', 'Vértes', 'Budai-hegység', 'Velencei-hegység',
    'Keszthelyi-hegység', 'Balaton-felvidék', 'Alpokalja', 'Kőszegi-hegység',
    'Soproni-hegység', 'Mecsek',
  ];

  String? _selectedRegion;

  // AZ ÖSSZES ELÉRHERŐ SZÁLLÁS LISTÁJA
  final List<Map<String, dynamic>> _allAccommodations = const [
    {
      'title': 'Mátrai Panoráma Vendégház',
      'location': 'Mátraháza',
      'region': 'Mátra',
      'rating': '4.9',
      'price': '35.000 Ft / éj',
      'badge': '0% Jutalék / Közvetlen',
      'image': 'assets/images/matra_background.png',
      'description': 'Gyönyörű erdei panorámás vendégház a Mátra szívében.',
      'hostName': 'Kovács János',
      'hostPhone': '+36301234567',
    },
    {
      'title': 'Bükki Erdei Luxe Faház',
      'location': 'Szilvásvárad',
      'region': 'Bükk',
      'rating': '4.8',
      'price': '28.000 Ft / éj',
      'badge': 'Dézsafürdős',
      'image': 'assets/images/matra_background.png',
      'description': 'Privát dézsafürdős faház közvetlenül a Bükki Nemzeti Park szélén.',
      'hostName': 'Nagy Éva',
      'hostPhone': '+36309876543',
    },
    {
      'title': 'Börzsönyi A-Frame Kabin',
      'location': 'Zebegény',
      'region': 'Börzsöny',
      'rating': '5.0',
      'price': '42.000 Ft / éj',
      'badge': 'Öko-Lodge',
      'image': 'assets/images/matra_background.png',
      'description': 'Modern, stílusos A-Frame faház Dunai panorámával.',
      'hostName': 'Szabó Péter',
      'hostPhone': '+36205551234',
    },
    {
      'title': 'Bakonyi Patakparti Vendégház',
      'location': 'Bakonybél',
      'region': 'Bakony',
      'rating': '4.7',
      'price': '24.000 Ft / éj',
      'badge': 'Családbarát',
      'image': 'assets/images/matra_background.png',
      'description': 'Csendes erdei környezetben fekvő felújított parasztház cserépkályhával.',
      'hostName': 'Tóth Katalin',
      'hostPhone': '+36301112233',
    },
    {
      'title': 'Zempléni Várpanoráma Apartman',
      'location': 'Füzér',
      'region': 'Zempléni-hegység',
      'rating': '4.9',
      'price': '31.000 Ft / éj',
      'badge': 'Szaunás',
      'image': 'assets/images/matra_background.png',
      'description': 'Közvetlen kilátás a füzéri várra, privát szaunával és borospincével.',
      'hostName': 'Molnár Gábor',
      'hostPhone': '+36704445566',
    },
  ];

  final List<Map<String, dynamic>> _featuredExperiences = const [
    {
      'title': 'Vezetett E-bike Túra a Mátra Bércein',
      'location': 'Galyatető',
      'region': 'Mátra',
      'rating': '4.9',
      'price': '12.500 Ft / fő',
      'badge': 'Felszereléssel',
      'image': 'assets/images/matra_background.png',
      'description': 'Fedezd fel a Mátra legszebb gerinceit prémium E-bike nyergében!',
      'hostName': 'Mátra Bike Csapat',
      'hostPhone': '+36304443322',
    },
    {
      'title': 'Sziklamászás & Via Ferrata',
      'location': 'Csesznek',
      'region': 'Bakony',
      'rating': '5.0',
      'price': '15.000 Ft / fő',
      'badge': 'Profi Vezetővel',
      'image': 'assets/images/matra_background.png',
      'description': 'Felejthetetlen sziklamászó élmény szakképzett túravezetővel.',
      'hostName': 'Bakony Adventure',
      'hostPhone': '+36307778899',
    },
  ];

  void _navigateToDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccommodationDetailPage(
          accommodationData: item,
        ),
      ),
    );
  }

  // TELJES KÉPERNYŐS TALÁLATI LISTA MEGNYITÁSA
  void _openFullListPage({String? filterRegion, String pageTitle = 'Összes Szállás'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullAccommodationListPage(
          title: pageTitle,
          accommodations: filterRegion != null
              ? _allAccommodations.where((item) => item['region'] == filterRegion).toList()
              : _allAccommodations,
          selectedRegion: filterRegion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEJLÉC
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/hegygo_logo.png',
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // KERESŐ DOBOZ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onTap: () {
                          if (!_isFilterExpanded) {
                            setState(() {
                              _isFilterExpanded = true;
                            });
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Hová utaznál?',
                          hintStyle: const TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(Icons.search_rounded, color: accent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: _isFilterExpanded ? accent : Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFilterExpanded = !_isFilterExpanded;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(color: Colors.white12, height: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Válassz hegyvidéket:',
                                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _regions.map((region) {
                                      final isSelected = _selectedRegion == region;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedRegion = isSelected ? null : region;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected ? accent : Colors.white.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected ? accent : accent.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.landscape_rounded,
                                                color: isSelected ? Colors.black : accent,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                region,
                                                style: TextStyle(
                                                  color: isSelected ? Colors.black : Colors.white,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 18),
                                  const Divider(color: Colors.white12),
                                  const SizedBox(height: 12),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Árkategória (éjszakánként):',
                                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${_priceRange.start.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Ft - ${_priceRange.end.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Ft',
                                        style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  RangeSlider(
                                    values: _priceRange,
                                    min: 10000,
                                    max: 150000,
                                    divisions: 28,
                                    activeColor: accent,
                                    inactiveColor: Colors.white12,
                                    labels: RangeLabels(
                                      '${_priceRange.start.round()} Ft',
                                      '${_priceRange.end.round()} Ft',
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        _priceRange = values;
                                      });
                                    },
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _isFilterExpanded = false;
                                        });
                                        _openFullListPage(
                                          filterRegion: _selectedRegion,
                                          pageTitle: _selectedRegion != null ? 'Szállások: $_selectedRegion' : 'Keresési Találatok',
                                        );
                                      },
                                      icon: const Icon(Icons.check_rounded, color: accent, size: 18),
                                      label: const Text('Keresés indítása', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        crossFadeState: _isFilterExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // A 3 ÜVEGHATÁSÚ ZÖLD CSEMPE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildGlassCategoryCard(
                      icon: Icons.home_rounded,
                      title: 'Szállások',
                      onTap: () => _openFullListPage(pageTitle: 'Összes Szállás'),
                    ),
                    const SizedBox(width: 12),
                    _buildGlassCategoryCard(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      title: 'Élmények',
                      onTap: () => _openFullListPage(pageTitle: 'Hegyvidéki Élmények'),
                    ),
                    const SizedBox(width: 12),
                    _buildGlassCategoryCard(
                      icon: Icons.restaurant_rounded,
                      title: 'Gasztro',
                      onTap: () => _openFullListPage(pageTitle: 'Hegyvidéki Gasztro'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // KIEMELT SZÁLLÁSOK
              _buildSectionHeader('Kiemelt Szállások', onSeeAll: () => _openFullListPage(pageTitle: 'Összes Szállás')),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: _accommodationPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentAccommodationIndex = index;
                    });
                  },
                  itemCount: _allAccommodations.length > 3 ? 3 : _allAccommodations.length,
                  itemBuilder: (context, index) {
                    final item = _allAccommodations[index];
                    return _build3DCarouselCard(item);
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildPageIndicator(3, _currentAccommodationIndex),

              const SizedBox(height: 32),

              // KIEMELT ÉLMÉNYEK
              _buildSectionHeader('Kiemelt Élmények', onSeeAll: () => _openFullListPage(pageTitle: 'Összes Élmény')),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: _experiencePageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentExperienceIndex = index;
                    });
                  },
                  itemCount: _featuredExperiences.length,
                  itemBuilder: (context, index) {
                    final item = _featuredExperiences[index];
                    return _build3DCarouselCard(item);
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildPageIndicator(_featuredExperiences.length, _currentExperienceIndex),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.star_rounded,
                color: accent,
                size: 20,
              ),
            ],
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Összes', style: TextStyle(color: accent, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _build3DCarouselCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _navigateToDetail(item),
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.asset(
                item['image'],
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    item['badge'],
                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item['rating'],
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: accent, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '${item['location']} (${item['region']})',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['price'],
                      style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count, int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isSelected ? 22 : 6,
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.white24,
            borderRadius: BorderRadius.circular(3),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.6),
                      blurRadius: 6,
                    )
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildGlassCategoryCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: accent.withValues(alpha: 0.3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: accent, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TELJES KÉPERNYŐS TALÁLATI LISTA WIDGET
// ==========================================
class FullAccommodationListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> accommodations;
  final String? selectedRegion;

  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  const FullAccommodationListPage({
    super.key,
    required this.title,
    required this.accommodations,
    this.selectedRegion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: accommodations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, color: Colors.white38, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Sajnos nem találtunk szállást az alábbi régióban:\n${selectedRegion ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: accommodations.length,
              itemBuilder: (context, index) {
                final item = accommodations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccommodationDetailPage(accommodationData: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Stack(
                            children: [
                              Image.asset(
                                item['image'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['badge'],
                                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['rating'],
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: accent, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['location']} (${item['region']})',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['price'],
                                    style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  const Row(
                                    children: [
                                      Text(
                                        'Részletek',
                                        style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 12),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}