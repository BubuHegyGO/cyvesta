import 'dart:async';
import 'package:flutter/material.dart';

import 'package:hegygo/features/accommodation/accommodation_page.dart';
import 'package:hegygo/features/accommodation/presentation/accommodation_detail_page.dart';
import 'package:hegygo/features/experiences/experiences_page.dart';
import 'package:hegygo/features/experiences/presentation/experience_detail_page.dart';
import 'package:hegygo/features/gastronomy/gastronomy_page.dart';
import 'package:hegygo/features/gastronomy/presentation/gastronomy_detail_page.dart';
import 'package:hegygo/features/profile/host_registration_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- MAGYARORSZÁG ÖSSZES HEGYVIDÉKE ---
  final List<String> _regions = const [
    'Mátra',
    'Bükk',
    'Börzsöny',
    'Zempléni-hegység',
    'Cserhát',
    'Aggteleki-karszt',
    'Bakony',
    'Pilis',
    'Gerecse',
    'Vértes',
    'Budai-hegység',
    'Visegrádi-hegység',
    'Velencei-hegység',
    'Kőszegi-hegység',
    'Soproni-hegység',
    'Mecsek',
    'Villányi-hegység',
  ];

  final Set<String> _selectedRegions = {};
  RangeValues _priceRange = const RangeValues(5000, 150000);
  final Set<String> _selectedAccommodationTypes = {};

  // --- SZÁLLÁSTÍPUS VÁLASZTÉK ---
  final List<Map<String, dynamic>> _accommodationTypes = [
    {'title': 'Romantikus 2 fős', 'icon': Icons.favorite_outline},
    {'title': 'Erdei & Lombházak', 'icon': Icons.forest_outlined},
    {'title': 'Wellness', 'icon': Icons.hot_tub_outlined},
    {'title': 'Medencés', 'icon': Icons.pool_outlined},
    {'title': 'Állatbarát', 'icon': Icons.pets_outlined},
    {'title': 'Családi & Gyerekbarát', 'icon': Icons.family_restroom_outlined},
    {'title': 'Ellátással', 'icon': Icons.restaurant_menu_outlined},
    {'title': 'Önellátó', 'icon': Icons.flatware_outlined},
  ];

  // --- CAROUSEL ADATAI ---
  final List<Map<String, String>> _featuredItems = [
    {
      'id': '1',
      'title': 'SZARVAS',
      'subtitle': 'vendégház a Kékesen',
      'priceTag': '10.000 Ft. /fő/éj-től',
      'imagePath': 'assets/images/szarvas.png',
      'location': 'Mátra - Kékestető',
      'price': '10.000 Ft / fő / éj-től',
      'rating': '4.9',
      'description': 'Kényelmes, fenyvesekkel körülvett hangulatos faház a Mátra szívében.',
      'isVerified': 'true',
      'type': 'accommodation',
    },
    {
      'id': '2',
      'title': 'QUAD',
      'subtitle': 'túrák a Bükkben',
      'priceTag': 'Megnézem',
      'imagePath': 'assets/images/quad.png',
      'location': 'Bükk - Szilvásvárad',
      'price': '8.000 Ft / fő-től',
      'rating': '4.95',
      'description': 'Lélegzetelállító erdei utak, profi túravezetés a Bükkben.',
      'isVerified': 'true',
      'type': 'experience',
    },
    {
      'id': '3',
      'title': 'BOROZÓ-CSÁRDA',
      'subtitle': 'a Mecsekben',
      'priceTag': 'Megnézem',
      'imagePath': 'assets/images/csarda.png',
      'location': 'Mecsek - Villányi borvidék',
      'price': 'Asztalfoglalás / Kóstoló',
      'rating': '4.9',
      'description': 'Hagyományos borvidéki pince és csárda.',
      'isVerified': 'true',
      'type': 'gastronomy',
    },
    {
      'id': '4',
      'title': 'PANORÁMA',
      'subtitle': 'apartman a Mátraházán',
      'priceTag': '12.500 Ft. /fő/éj-től',
      'imagePath': 'assets/images/panorama.png',
      'location': 'Mátra - Mátraháza',
      'price': '12.500 Ft / fő / éj-től',
      'rating': '4.8',
      'description': 'Modern, teljesen felszerelt apartman panorámával.',
      'isVerified': 'true',
      'type': 'accommodation',
    },
  ];

  int _activeCardIndex = 0;
  late PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.54, initialPage: 1000);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _openFeaturedDetail(Map<String, String> item) {
    final type = item['type'];
    if (type == 'experience') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExperienceDetailPage(experienceData: item),
        ),
      );
    } else if (type == 'gastronomy') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GastronomyDetailPage(gastronomyData: item),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccommodationDetailPage(accommodationData: item),
        ),
      );
    }
  }

  void _navigateToCategory(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AccommodationPage(),
        ),
      );
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ExperiencesPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const GastronomyPage()));
    }
  }

  // --- 1. HEGYVIDÉK KERESŐ MODAL ---
  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hegyvidék Szűrő',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    const Text(
                      'Válassz hegyvidéket:',
                      style: TextStyle(color: Color(0xFF8BC541), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _regions.map((region) {
                        final isSelected = _selectedRegions.contains(region);
                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8BC541) : Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF8BC541) : Colors.white24,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedRegions.remove(region);
                                } else {
                                  _selectedRegions.add(region);
                                }
                              });
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Text(
                                region,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC541),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Szűrés Alkalmazása', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. LENYÍLÓ SZÁLLÁSTÍPUS ÉS ÁR KERESŐ MODAL ---
  void _openTypeAndPriceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Szállás Típus & Ár Szűrő',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    const Text(
                      'Milyen típusú szállást keresel? (Több is választható):',
                      style: TextStyle(color: Color(0xFF8BC541), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _accommodationTypes.map((type) {
                        final String title = type['title'];
                        final bool isSelected = _selectedAccommodationTypes.contains(title);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                _selectedAccommodationTypes.remove(title);
                              } else {
                                _selectedAccommodationTypes.add(title);
                              }
                            });
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF8BC541) : Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF8BC541) : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type['icon'],
                                  size: 16,
                                  color: isSelected ? Colors.black : const Color(0xFF8BC541),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  title,
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
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Max. Ár / fő / éj:',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_priceRange.end.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Ft',
                          style: const TextStyle(color: Color(0xFF8BC541), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 300000,
                      divisions: 60,
                      activeColor: const Color(0xFF8BC541),
                      inactiveColor: Colors.white24,
                      labels: RangeLabels(
                        '${_priceRange.start.round()} Ft',
                        '${_priceRange.end.round()} Ft',
                      ),
                      onChanged: (RangeValues newValues) {
                        setModalState(() {
                          _priceRange = newValues;
                        });
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC541),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccommodationPage()),
                          );
                        },
                        child: const Text('Keresés Alkalmazása', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEJLÉC
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.65,
                    child: Image.asset(
                      'assets/images/logo.png',
                      key: UniqueKey(),
                      height: 50,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'HegyGO',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // SZLOGEN A KERESŐ FÖLÖTT
              const Text(
                'Hegyvidéki szállások & élmények',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),

              // 1. FELSŐ HEGYVIDÉK KERESŐ SÁV
              GestureDetector(
                onTap: _openFilterModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF8BC541), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF8BC541), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedRegions.isEmpty
                              ? 'Melyik hegyvidékre utaznál?'
                              : 'Kiválasztva: ${_selectedRegions.join(', ')}',
                          style: TextStyle(
                            color: _selectedRegions.isEmpty ? Colors.white54 : const Color(0xFF8BC541),
                            fontSize: 13,
                            fontWeight: _selectedRegions.isEmpty ? FontWeight.normal : FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.tune, color: Color(0xFF8BC541), size: 20),
                        onPressed: _openFilterModal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // KATEGÓRIÁK
              Row(
                children: [
                  _buildCategoryCard(0, 'Szállások', Icons.home),
                  const SizedBox(width: 8),
                  _buildCategoryCard(1, 'Élmények', Icons.sentiment_satisfied_alt),
                  const SizedBox(width: 8),
                  _buildCategoryCard(2, 'Gasztro', Icons.restaurant),
                ],
              ),
              const SizedBox(height: 14),

              // 2. SZÁLLÁSTÍPUS KERESŐ SÁV
              GestureDetector(
                onTap: _openTypeAndPriceModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF8BC541), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF8BC541), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedAccommodationTypes.isEmpty
                              ? 'Milyen típusú szállást keresel?'
                              : 'Kiválasztva: ${_selectedAccommodationTypes.join(', ')}',
                          style: TextStyle(
                            color: _selectedAccommodationTypes.isEmpty ? Colors.white54 : const Color(0xFF8BC541),
                            fontSize: 13,
                            fontWeight: _selectedAccommodationTypes.isEmpty ? FontWeight.normal : FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.tune, color: Color(0xFF8BC541), size: 20),
                        onPressed: _openTypeAndPriceModal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // CAROUSEL
              SizedBox(
                height: 290,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _activeCardIndex = index % _featuredItems.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _featuredItems[index % _featuredItems.length];
                    return _buildTallFeaturedCard(item);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // INDIKÁTOROK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_featuredItems.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: _activeCardIndex == index ? 22 : 6,
                    decoration: BoxDecoration(
                      color: _activeCardIndex == index ? const Color(0xFF8BC541) : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),

              // CALL TO ACTION GOMB
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A1E),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF8BC541), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HostRegistrationPage()),
                    );
                  },
                  child: const Text(
                    'Regisztrálj a kedvezményekért!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(int index, String title, IconData icon) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCategory(index),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A261C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8BC541), width: 1.2),
            ),
            child: Column(
              children: [
                Icon(icon, color: const Color(0xFF8BC541), size: 22),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CSEMPÉK ---
  Widget _buildTallFeaturedCard(Map<String, String> item) {
    final bool isAccommodation = item['type'] == 'accommodation';
    final String buttonText = isAccommodation ? item['priceTag']! : 'Megnézem';

    return GestureDetector(
      onTap: () => _openFeaturedDetail(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8BC541), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // KÉP RÉSZ
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        item['imagePath']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/default_accommodation.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: -12,
                      child: Transform.rotate(
                        angle: -0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          color: const Color(0xFFFFC107),
                          child: const Text(
                            'KIEMELT',
                            style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // FEKETE ALSÓ RÉSZ
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            item['title']!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle']!.replaceAll('\n', ' '),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A1E),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF8BC541), width: 0.8),
                        ),
                        child: Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8BC541),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}