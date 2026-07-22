class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final List<Map<String, dynamic>> _accommodations = [
    {
      'id': '1',
      'title': 'Panoráma Vendégház',
      'category': 'Vendégház',
      'location': 'Visegrád',
      'price': '35.000 Ft / éj',
      'rating': '4.9',
      'image': 'assets/images/matra_background.png',
      'isFavorite': false,
      'latitude': 47.8723,
      'longitude': 20.0031,
      'status': 'approved', // Jóváhagyva
      'ntakNumber': 'MA22001111',
    },
    {
      'id': '2',
      'title': 'Mátrai Panoráma Lombház',
      'category': 'Lombház',
      'location': 'Mátrafüred',
      'price': '38.000 Ft / éj',
      'rating': '5.0',
      'image': 'assets/images/matra_background.png',
      'isFavorite': true,
      'latitude': 47.8311,
      'longitude': 19.9682,
      'status': 'approved',
      'ntakNumber': 'MA22002222',
    },
  ];

  final List<Map<String, dynamic>> _experiences = [
    {
      'id': 'e1',
      'title': 'Bükki Borkóstoló & Pincetúra',
      'category': 'Borkóstoló',
      'location': 'Eger',
      'price': '12.000 Ft / fő',
      'rating': '4.8',
      'image': 'assets/images/matra_background.png',
      'isFavorite': false,
      'latitude': 47.9026,
      'longitude': 20.3732,
      'status': 'approved',
      'ntakNumber': 'NTAK-EGER-01',
    },
  ];

  // Csak a JÓVÁHAGYOTT szállásokat adjuk vissza a vendég felületre
  List<Map<String, dynamic>> getAccommodations() {
    return _accommodations.where((item) => item['status'] == 'approved').toList();
  }

  List<Map<String, dynamic>> getExperiences() {
    return _experiences.where((item) => item['status'] == 'approved').toList();
  }

  // Admin felületnek: az ÖSSZES szállás (a várakozókkal együtt)
  List<Map<String, dynamic>> getAllAccommodationsForAdmin() => _accommodations;

  // Új szállás feltöltése -> Alapértelmezetten 'pending' (ellenőrzésre vár)
  void addAccommodation(Map<String, dynamic> newAccommodation) {
    newAccommodation['status'] = 'pending';
    _accommodations.insert(0, newAccommodation);
  }

  // Admin jóváhagyás
  void approveAccommodation(String id) {
    for (var item in _accommodations) {
      if (item['id'] == id) {
        item['status'] = 'approved';
        break;
      }
    }
  }

  // Admin elutasítás
  void rejectAccommodation(String id) {
    _accommodations.removeWhere((item) => item['id'] == id);
  }

  void toggleFavorite(String id) {
    for (var item in [..._accommodations, ..._experiences]) {
      if (item['id'] == id) {
        item['isFavorite'] = !(item['isFavorite'] ?? false);
        break;
      }
    }
  }
}