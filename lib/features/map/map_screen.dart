import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/campus/astu_campus.dart';
import '../../core/constants/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Stored as late final so flutter_map never sees "changed" options,
  // which prevents the cameraConstraint assertion on every setState.
  late final MapOptions _mapOptions;

  String _query = '';
  String _category = 'All';
  CampusPoi? _selectedPoi;
  bool _isOnline = true;
  bool _hasBundledCampusImage = false;
  double _currentZoom = AstuCampus.defaultZoom;

  List<CampusPoi> get _visiblePois =>
      AstuCampus.filter(query: _query, category: _category);

  @override
  void initState() {
    super.initState();
    // Build MapOptions once and keep it stable — do NOT put this in build().
    _mapOptions = MapOptions(
      initialCenter: AstuCampus.center,
      initialZoom: AstuCampus.defaultZoom,
      minZoom: AstuCampus.minZoom,
      maxZoom: AstuCampus.maxZoom,
      cameraConstraint: CameraConstraint.contain(
        bounds: LatLngBounds(AstuCampus.southWest, AstuCampus.northEast),
      ),
      onTap: (_, __) => setState(() => _selectedPoi = null),
      onPositionChanged: (camera, hasGesture) {
        if (mounted && camera.zoom != _currentZoom) {
          setState(() {
            _currentZoom = camera.zoom;
          });
        }
      },
    );
    _searchController.addListener(() => setState(() => _query = _searchController.text));
    _checkConnectivity();
    _probeOfflineAsset();
    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted && online != _isOnline) setState(() => _isOnline = online);
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (mounted) setState(() => _isOnline = online);
  }

  Future<void> _probeOfflineAsset() async {
    const path = AstuCampus.offlineMapAsset;
    if (path == null) return;
    try {
      await rootBundle.load(path);
      if (mounted) setState(() => _hasBundledCampusImage = true);
    } catch (_) {
      // Asset not added yet — see assets/maps/README.md
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _focusPoi(CampusPoi poi) {
    setState(() => _selectedPoi = poi);
    _mapController.move(poi.position, 17);
    _showPoiSheet(poi);
  }

  void _showPoiSheet(CampusPoi poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: poi.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(poi.icon, color: poi.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poi.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${poi.category} · ${AstuCampus.shortName}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (poi.description != null) ...[
              const SizedBox(height: 12),
              Text(poi.description!, style: const TextStyle(height: 1.5)),
            ],
            const SizedBox(height: 12),
            Text(
              'GPS: ${poi.position.latitude.toStringAsFixed(5)}, ${poi.position.longitude.toStringAsFixed(5)}',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _mapController.move(poi.position, 17.5);
                },
                icon: const Icon(Icons.center_focus_strong_rounded),
                label: const Text('Center on map'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useNetworkTiles = _isOnline;
    final useBundledImage = !_isOnline && _hasBundledCampusImage;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ASTU Campus Map', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text(
              _isOnline ? 'Online · OpenStreetMap' : 'Offline · Campus mode',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset view',
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () => _mapController.move(AstuCampus.center, AstuCampus.defaultZoom),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Theme.of(context).colorScheme.onErrorContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hasBundledCampusImage
                          ? 'Offline — using bundled ASTU campus map'
                          : 'Offline — building labels work; add assets/maps/astu_campus_map.png for background',
                      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ASTU buildings…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: AstuCampus.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = AstuCampus.categories[i];
                final selected = _category == cat;
                return FilterChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: AppColors.primary100,
                  checkmarkColor: AppColors.primary600,
                );
              },
            ),
          ),
          if (_visiblePois.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('No buildings match your search.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: _mapOptions,
                  children: [
                    if (useNetworkTiles)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.campusone.campus_one',
                      ),
                    if (useBundledImage)
                      OverlayImageLayer(
                        overlayImages: [
                          OverlayImage(
                            bounds: LatLngBounds(AstuCampus.southWest, AstuCampus.northEast),
                            imageProvider: const AssetImage('assets/maps/astu_campus_map.png'),
                            opacity: 0.92,
                          ),
                        ],
                      ),
                    if (!useNetworkTiles && !useBundledImage)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: [
                              LatLng(AstuCampus.northEast.latitude, AstuCampus.southWest.longitude),
                              AstuCampus.northEast,
                              LatLng(AstuCampus.southWest.latitude, AstuCampus.northEast.longitude),
                              AstuCampus.southWest,
                            ],
                            color: const Color(0xFFE8F5E9).withValues(alpha: 0.85),
                            borderColor: const Color(0xFF2E7D32),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _visiblePois.map(_buildLabeledMarker).toList(),
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Column(
                    children: [
                      _MapFab(
                        icon: Icons.add,
                        onTap: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MapFab(
                        icon: Icons.remove,
                        onTap: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_visiblePois.length <= 8 && _query.isNotEmpty)
            Container(
              height: 56,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _visiblePois.length,
                itemBuilder: (_, i) {
                  final p = _visiblePois[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(p.icon, size: 18, color: p.color),
                      label: Text(p.name, style: const TextStyle(fontSize: 11)),
                      onPressed: () => _focusPoi(p),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Marker _buildLabeledMarker(CampusPoi poi) {
    final isSelected = _selectedPoi?.id == poi.id;
    
    // Dynamically show labels to prevent overcrowding:
    // 1. Show if selected/tapped.
    // 2. OR show if a specific category is selected (not 'All' - as it is filtered down).
    // 3. OR show if the user is zoomed in (zoom >= 16.5) so labels are spread out.
    final showLabel = isSelected || _category != 'All' || _currentZoom >= 16.5;

    // Use a fixed size marker with center alignment so the circle/pin itself NEVER shifts or jumps.
    const double markerWidth = 140.0;
    const double markerHeight = 90.0;

    return Marker(
      point: poi.position,
      width: markerWidth,
      height: markerHeight,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. The Pin Circle (Centered precisely on the coordinate)
          Positioned(
            top: isSelected ? 15 : 19,
            child: GestureDetector(
              onTap: () => _focusPoi(poi),
              child: Container(
                width: isSelected ? 40 : 32,
                height: isSelected ? 40 : 32,
                decoration: BoxDecoration(
                  color: poi.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                  boxShadow: [
                    BoxShadow(
                      color: poi.color.withValues(alpha: 0.5),
                      blurRadius: isSelected ? 14 : 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(poi.icon, color: Colors.white, size: isSelected ? 20 : 16),
              ),
            ),
          ),
          
          // 2. The Building Label (Positioned below the pin)
          if (showLabel)
            Positioned(
              top: isSelected ? 58 : 55,
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 8 : 6,
                    vertical: isSelected ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? poi.color : Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected
                        ? null
                        : Border.all(color: poi.color.withValues(alpha: 0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    poi.name,
                    textAlign: TextAlign.center,
                    maxLines: isSelected ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontSize: isSelected ? 9.5 : 8.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.primary600),
        ),
      ),
    );
  }
}
