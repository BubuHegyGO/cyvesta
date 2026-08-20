import 'package:flutter/material.dart';

class AppLanguage {
  static final ValueNotifier<String> currentLocale = ValueNotifier<String>('hu');

  static void setLanguage(String langCode) {
    currentLocale.value = langCode;
  }

  static final Map<String, Map<String, String>> _dict = {
    'hu': {
      // Főoldal & Slogan
      'slogan': 'Fedezd fel Ciprust: Szállások, Ízek & Túrák',
      'search_region_hint': 'Válassz ciprusi régiót vagy várost...',
      'cat_accommodations': 'Apartmanok\n& Ingatlanok',
      'cat_experiences': 'Élmények\n& Túrák',
      'cat_gastronomy': 'Gasztronómia\n& Bárok',
      'cat_transfer': 'Reptéri\ntranszfer ✈️',
      'nearby_search_bar': 'Autóbérlés, patikák, boltok a közeledben...',
      'nearby_services_title': 'Közeli szolgáltatások térképen 🗺️',
      'choose_region_title': 'Válassz ciprusi úti célt 🏝️',
      'view_details': 'Megtekintés',
      'featured_badge': 'KIEMELT',
      'all_regions': 'Összes régió (Egész Ciprus)',

      // Bejelentkezés & Regisztráció & Auth
      'auth_login_title': 'CYVESTA Bejelentkezés',
      'auth_register_title': 'Új Fiók Létrehozása',
      'auth_desc': 'Mentsd el kedvenceidet és kezeld a foglalásaidat!',
      'auth_email_hint': 'E-mail cím',
      'auth_password_hint': 'Jelszó',
      'auth_name_hint': 'Teljes név',
      'auth_forgot_pass': 'Elfelejtetted a jelszavadat?',
      'auth_login_btn': 'Bejelentkezés',
      'auth_register_btn': 'Regisztráció',
      'auth_or_social': 'Vagy folytasd a következőkkel:',
      'auth_google': 'Folytatás Google fiókkal',
      'auth_apple': 'Folytatás Apple fiókkal',
      'auth_facebook': 'Folytatás Facebook fiókkal',
      'auth_switch_to_register': 'Nincs még fiókod? Regisztrálj itt!',
      'auth_switch_to_login': 'Már van fiókod? Jelentkezz be!',
      'auth_logout_btn': 'Kijelentkezés',
      'auth_logged_in_as': 'Bejelentkezve mint:',
      'auth_btn_main': 'Bejelentkezés & Fiók 👤',

      // Profil Fül & Menüpontok
      'profile_title': 'Profil & Fiókkezelés 👤',
      'admin_badge': 'ADMINISZTRÁTOR',
      'admin_center': 'Admin Moderációs Központ',
      'admin_center_desc': 'Jóváhagyásra váró új hirdetések ellenőrzése',
      'host_reg': 'Hirdetésfeladás & Partnerregisztráció',
      'host_reg_desc': 'Új villa, szállás, túra vagy szolgáltatás regisztrálása',
      'host_packages': 'Hirdetői Csomagok & Tagság',
      'host_packages_desc': 'Basic, PRO és VIP előfizetési csomagok (Stripe)',
      'crm_dashboard': 'CRM Műszerfal & Lead Követés',
      'crm_dashboard_desc': 'Megtekintések, érdeklődők és statisztikák',
      'edit_profile': 'Profil Adatok Módosítása',
      'edit_profile_desc': 'Név, e-mail cím, telefonszám szerkesztése',

      // Ingatlan típus választó
      'choose_property_type': 'Válassz Kategóriát 🏡',
      'rent_apartments': 'Kiadó apartmanok 🏖️',
      'rent_apartments_desc': 'Nyaraláshoz kiadó prémium apartmanok és tengerparti villák',
      'sale_properties': 'Eladó ingatlanok 🔑',
      'sale_properties_desc': 'Befektetésre és letelepedésre kínált ciprusi ingatlanok',

      // Navigáció
      'nav_home': 'Kezdőlap',
      'nav_map': 'Térkép',
      'nav_favorites': 'Kedvencek',
      'nav_alerts': 'Értesítések',
      'nav_profile': 'Profil',
      'lang_title': 'Nyelv kiválasztása / Language',
      'plans_title': 'Hirdetői Tagságok 💎',

      // Szolgáltatások
      'serv_car_rental': 'Autókölcsönzők',
      'serv_car_rental_desc': 'Bérautók reptéri vagy szállási átvétellel',
      'serv_bike_rental': 'Kerékpár & Robogó bérlés',
      'serv_bike_rental_desc': 'E-bike, robogó és quad bérlés',
      'serv_pharmacy': 'Gyógyszertárak (Ügyeletes)',
      'serv_pharmacy_desc': '24 órás ügyelet és patikák',
      'serv_supermarket': 'Élelmiszerboltok & Szupermarketek',
      'serv_supermarket_desc': 'Lidl, Metro, helyi szupermarketek',
      'serv_nightlife': 'Szórakozóhelyek & Bárok',
      'serv_nightlife_desc': 'Beach clubok, koktélbárok, bulik',
      'serv_bus_stop': 'Buszmegállók & Menetrend',
      'serv_bus_stop_desc': '615, reptéri és távolsági buszok',
      'serv_atm': 'ATM & Pénzváltók',
      'serv_atm_desc': 'Bankautomaták és valutaváltók',

      // Gasztronómia & Transzfer
      'dining_spots': 'Gasztronómia & Éttermek 🍽️',
      'book_table_btn': 'Részletek & Asztalfoglalás 🌐',
      'opening_hours': 'Nyitvatartás',
      'cuisine_type': 'Konyha típusa',
      'menu_preview': 'Kiemelt Étlap & Kínálat',
      'call_restaurant': 'Közvetlen Hívás',
      'table_reservation': 'Asztalfoglalás (WhatsApp)',
      'transfer_title': 'Reptéri Transzfer ✈️🚖',
      'transfer_header_title': 'Megbízható Ciprusi Transzferek',
      'transfer_header_desc': 'Larnaca (LCA) és Paphos (PFO) repülőterekről fix áras transzferek.',
      'transfer_step1_title': '1. Transzfer Iránya',
      'transfer_dir_to_stay': 'Reptér ➔ Szállás',
      'transfer_dir_to_airport': 'Szállás ➔ Reptér',
      'transfer_step2_title': '2. Járat & Úti Cél Részletei',
      'transfer_airport_label': 'Válassz Repülőteret *',
      'transfer_dest_hint': 'Szállás / Város neve',
      'transfer_passengers': 'Utasok száma',
      'transfer_flight_num': 'Járatszám (pl. W6 2451)',
      'transfer_phone_hint': 'Telefonszámod / WhatsApp *',
      'transfer_submit_btn': 'Transzfer Árajánlat Kérése (WhatsApp) 🚖',
      'transfer_fill_required': 'Kérjük töltsd ki a célállomást és az elérhetőségedet!',
    },

    'en': {
      'slogan': 'Discover Cyprus: Stays, Tastes & Tours',
      'search_region_hint': 'Select a Cyprus region or city...',
      'cat_accommodations': 'Apartments\n& Real Estate',
      'cat_experiences': 'Experiences\n& Tours',
      'cat_gastronomy': 'Dining\n& Bars',
      'cat_transfer': 'Airport\nTransfer ✈️',
      'nearby_search_bar': 'Car rentals, pharmacies, stores near you...',
      'nearby_services_title': 'Nearby Services on Map 🗺️',
      'choose_region_title': 'Choose Destination in Cyprus 🏝️',
      'view_details': 'View Details',
      'featured_badge': 'FEATURED',
      'all_regions': 'All Regions (Whole Cyprus)',

      'auth_login_title': 'CYVESTA Sign In',
      'auth_register_title': 'Create New Account',
      'auth_desc': 'Save your favorites and manage bookings!',
      'auth_email_hint': 'Email Address',
      'auth_password_hint': 'Password',
      'auth_name_hint': 'Full Name',
      'auth_forgot_pass': 'Forgot your password?',
      'auth_login_btn': 'Sign In',
      'auth_register_btn': 'Register',
      'auth_or_social': 'Or continue with:',
      'auth_google': 'Continue with Google',
      'auth_apple': 'Continue with Apple',
      'auth_facebook': 'Continue with Facebook',
      'auth_switch_to_register': "Don't have an account? Sign up here!",
      'auth_switch_to_login': 'Already have an account? Sign in!',
      'auth_logout_btn': 'Log Out',
      'auth_logged_in_as': 'Logged in as:',
      'auth_btn_main': 'Sign In & Account 👤',

      'profile_title': 'Profile & Account 👤',
      'admin_badge': 'ADMINISTRATOR',
      'admin_center': 'Admin Moderation Center',
      'admin_center_desc': 'Review and approve pending listings',
      'host_reg': 'List Property & Partner Registration',
      'host_reg_desc': 'Submit new villa, stay, tour or service',
      'host_packages': 'Host Packages & Membership',
      'host_packages_desc': 'Basic, PRO and VIP subscription plans (Stripe)',
      'crm_dashboard': 'CRM Dashboard & Lead Tracking',
      'crm_dashboard_desc': 'Views, customer leads and statistics',
      'edit_profile': 'Edit Profile Details',
      'edit_profile_desc': 'Manage name, email and phone number',

      'choose_property_type': 'Select Category 🏡',
      'rent_apartments': 'Holiday Rentals 🏖️',
      'rent_apartments_desc': 'Luxury holiday apartments & beachfront villas for rent',
      'sale_properties': 'Properties for Sale 🔑',
      'sale_properties_desc': 'Prime investment real estate and villas for sale in Cyprus',

      'nav_home': 'Home',
      'nav_map': 'Explore Map',
      'nav_favorites': 'Favorites',
      'nav_alerts': 'Alerts',
      'nav_profile': 'Profile',
      'lang_title': 'Select Language',
      'plans_title': 'Host Membership Plans 💎',

      'serv_car_rental': 'Car Rentals',
      'serv_car_rental_desc': 'Car hire with airport or hotel delivery',
      'serv_bike_rental': 'Bike & Scooter Rentals',
      'serv_bike_rental_desc': 'E-bikes, scooters and quad rentals',
      'serv_pharmacy': 'Pharmacies (On Duty)',
      'serv_pharmacy_desc': '24/7 duty pharmacies and chemists',
      'serv_supermarket': 'Grocery & Supermarkets',
      'serv_supermarket_desc': 'Lidl, Metro, local supermarkets',
      'serv_nightlife': 'Nightlife & Beach Bars',
      'serv_nightlife_desc': 'Beach clubs, cocktail lounges, parties',
      'serv_bus_stop': 'Bus Stops & Timetables',
      'serv_bus_stop_desc': 'Route 615, airport & intercity buses',
      'serv_atm': 'ATMs & Currency Exchange',
      'serv_atm_desc': 'Cash machines and money exchange',

      'dining_spots': 'Dining & Restaurants 🍽️',
      'book_table_btn': 'Details & Table Booking 🌐',
      'opening_hours': 'Opening Hours',
      'cuisine_type': 'Cuisine Type',
      'menu_preview': 'Featured Menu & Specialties',
      'call_restaurant': 'Direct Call',
      'table_reservation': 'Table Booking (WhatsApp)',
      'transfer_title': 'Airport Transfer ✈️🚖',
      'transfer_header_title': 'Reliable Cyprus Airport Transfers',
      'transfer_header_desc': 'Fixed-price transfers from Larnaca & Paphos airports.',
      'transfer_step1_title': '1. Transfer Direction',
      'transfer_dir_to_stay': 'Airport ➔ Stay',
      'transfer_dir_to_airport': 'Stay ➔ Airport',
      'transfer_step2_title': '2. Flight & Destination Details',
      'transfer_airport_label': 'Select Airport *',
      'transfer_dest_hint': 'Stay / City name',
      'transfer_passengers': 'Passengers',
      'transfer_flight_num': 'Flight Number (e.g. W6 2451)',
      'transfer_phone_hint': 'Phone Number / WhatsApp Contact *',
      'transfer_submit_btn': 'Request Transfer Quote (WhatsApp) 🚖',
      'transfer_fill_required': 'Please enter destination and contact details!',
    },
  };

  static String tr(String key) {
    final lang = currentLocale.value;
    if (_dict.containsKey(lang) && _dict[lang]!.containsKey(key)) {
      return _dict[lang]![key]!;
    }
    if (_dict['en'] != null && _dict['en']!.containsKey(key)) {
      return _dict['en']![key]!;
    }
    if (_dict['hu'] != null && _dict['hu']!.containsKey(key)) {
      return _dict['hu']![key]!;
    }
    return key;
  }
}