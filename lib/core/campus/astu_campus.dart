import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Adama Science & Technology University (ASTU) — campus map data (works offline).
class AstuCampus {
  AstuCampus._();

  static const String universityName = 'Adama Science & Technology University';
  static const String shortName = 'ASTU';
  static const String city = 'Adama, Ethiopia';

  /// Map focus point (main campus).
  static const LatLng center = LatLng(8.5630, 39.2900);

  /// Southwest corner of ASTU main campus (for map bounds / offline tiles).
  static const LatLng southWest = LatLng(8.5580, 39.2845);

  /// Northeast corner of ASTU main campus.
  static const LatLng northEast = LatLng(8.5685, 39.2960);

  static const double defaultZoom = 16.0;
  static const double minZoom = 15.0;
  static const double maxZoom = 18.0;

  /// Optional bundled campus plan image (add PNG to assets/maps/).
  static const String? offlineMapAsset = 'assets/maps/astu_campus_map.png';

  static const List<String> categories = [
    'All',
    'Academic',
    'Residential',
    'Services',
    'Sports',
    'Admin',
  ];

  static final List<CampusPoi> pointsOfInterest = [
    CampusPoi(
      id: 'main_gate',
      name: 'Main Gate',
      category: 'Admin',
      icon: Icons.door_front_door_rounded,
      color: Color(0xFF1565C0),
      position: LatLng(8.5630, 39.2900),
      description: 'Primary campus entrance.',
    ),
    CampusPoi(
      id: 'admin_building',
      name: 'Admin Building',
      category: 'Admin',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFFF6F00),
      position: LatLng(8.5635, 39.2905),
    ),
    CampusPoi(
      id: 'registrar',
      name: 'Registrar Office',
      category: 'Admin',
      icon: Icons.assignment_ind_rounded,
      color: Color(0xFFFF6F00),
      position: LatLng(8.5633, 39.2908),
    ),
    CampusPoi(
      id: 'security',
      name: 'Security Office',
      category: 'Admin',
      icon: Icons.security_rounded,
      color: Color(0xFFB00020),
      position: LatLng(8.5628, 39.2898),
    ),
    CampusPoi(
      id: 'block_101',
      name: 'Block 101 (Engineering)',
      category: 'Academic',
      icon: Icons.engineering_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5640, 39.2910),
    ),
    CampusPoi(
      id: 'block_102',
      name: 'Block 102 (Computing)',
      category: 'Academic',
      icon: Icons.computer_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5642, 39.2915),
    ),
    CampusPoi(
      id: 'block_103',
      name: 'Block 103 (Applied Science)',
      category: 'Academic',
      icon: Icons.science_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5645, 39.2920),
    ),
    CampusPoi(
      id: 'ict',
      name: 'ICT Center',
      category: 'Academic',
      icon: Icons.router_rounded,
      color: Color(0xFF1565C0),
      position: LatLng(8.5632, 39.2920),
    ),
    CampusPoi(
      id: 'main_library',
      name: 'Main Library',
      category: 'Academic',
      icon: Icons.library_books_rounded,
      color: Color(0xFF1565C0),
      position: LatLng(8.5648, 39.2905),
    ),
    CampusPoi(
      id: 'pg_library',
      name: 'Post Graduate Library',
      category: 'Academic',
      icon: Icons.local_library_rounded,
      color: Color(0xFF1565C0),
      position: LatLng(8.5652, 39.2908),
    ),
    CampusPoi(
      id: 'architecture',
      name: 'Architecture Studio',
      category: 'Academic',
      icon: Icons.design_services_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5640, 39.2900),
    ),
    CampusPoi(
      id: 'mech_lab',
      name: 'Mechanical Lab',
      category: 'Academic',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5660, 39.2920),
    ),
    CampusPoi(
      id: 'civil_lab',
      name: 'Civil Lab',
      category: 'Academic',
      icon: Icons.architecture_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5662, 39.2922),
    ),
    CampusPoi(
      id: 'workshop_1',
      name: 'Workshop 1',
      category: 'Academic',
      icon: Icons.handyman_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5655, 39.2915),
    ),
    CampusPoi(
      id: 'workshop_2',
      name: 'Workshop 2',
      category: 'Academic',
      icon: Icons.handyman_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5658, 39.2918),
    ),
    CampusPoi(
      id: 'research',
      name: 'Research Center',
      category: 'Academic',
      icon: Icons.biotech_rounded,
      color: Color(0xFF1565C0),
      position: LatLng(8.5645, 39.2925),
    ),
    CampusPoi(
      id: 'graduation_hall',
      name: 'Graduation Hall',
      category: 'Academic',
      icon: Icons.school_rounded,
      color: Color(0xFFFF6F00),
      position: LatLng(8.5630, 39.2910),
    ),
    CampusPoi(
      id: 'freshmen_1',
      name: 'Freshmen Dorms (Block 1)',
      category: 'Residential',
      icon: Icons.hotel_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5620, 39.2890),
    ),
    CampusPoi(
      id: 'freshmen_2',
      name: 'Freshmen Dorms (Block 2)',
      category: 'Residential',
      icon: Icons.hotel_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5622, 39.2885),
    ),
    CampusPoi(
      id: 'senior_a',
      name: 'Senior Dorms (Block A)',
      category: 'Residential',
      icon: Icons.hotel_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5615, 39.2880),
    ),
    CampusPoi(
      id: 'senior_b',
      name: 'Senior Dorms (Block B)',
      category: 'Residential',
      icon: Icons.hotel_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5610, 39.2885),
    ),
    CampusPoi(
      id: 'female_dorms',
      name: 'Female Dorms',
      category: 'Residential',
      icon: Icons.hotel_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5650, 39.2895),
    ),
    CampusPoi(
      id: 'staff_res',
      name: 'Staff Residences',
      category: 'Residential',
      icon: Icons.house_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5670, 39.2890),
    ),
    CampusPoi(
      id: 'cafeteria',
      name: 'Main Cafeteria',
      category: 'Services',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6F00),
      position: LatLng(8.5638, 39.2895),
    ),
    CampusPoi(
      id: 'staff_lounge',
      name: 'Staff Lounge',
      category: 'Services',
      icon: Icons.coffee_rounded,
      color: Color(0xFFFF6F00),
      position: LatLng(8.5636, 39.2900),
    ),
    CampusPoi(
      id: 'clinic',
      name: 'Student Clinic',
      category: 'Services',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFB00020),
      position: LatLng(8.5625, 39.2910),
    ),
    CampusPoi(
      id: 'bookstore',
      name: 'Book Store',
      category: 'Services',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFFF6F00),
      position: LatLng(8.5635, 39.2898),
    ),
    CampusPoi(
      id: 'market',
      name: 'Mini Market',
      category: 'Services',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF2E7D32),
      position: LatLng(8.5625, 39.2885),
    ),
    CampusPoi(
      id: 'bus_stop',
      name: 'Bus Stop',
      category: 'Services',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF1565C0),
      position: LatLng(8.5620, 39.2905),
    ),
    CampusPoi(
      id: 'stadium',
      name: 'Stadium / Sports Field',
      category: 'Sports',
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5610, 39.2920),
    ),
    CampusPoi(
      id: 'basketball',
      name: 'Basketball Courts',
      category: 'Sports',
      icon: Icons.sports_basketball_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5615, 39.2915),
    ),
    CampusPoi(
      id: 'tennis',
      name: 'Tennis Courts',
      category: 'Sports',
      icon: Icons.sports_tennis_rounded,
      color: Color(0xFF00897B),
      position: LatLng(8.5618, 39.2918),
    ),
  ];

  static List<CampusPoi> filter({String query = '', String category = 'All'}) {
    final q = query.trim().toLowerCase();
    return pointsOfInterest.where((p) {
      final catOk = category == 'All' || p.category == category;
      final searchOk = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false);
      return catOk && searchOk;
    }).toList();
  }
}

class CampusPoi {
  const CampusPoi({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.position,
    this.description,
  });

  final String id;
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final LatLng position;
  final String? description;
}
