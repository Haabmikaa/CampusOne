# ASTU Offline Campus Map Guide

CampusOne is scoped to **Adama Science & Technology University (ASTU)**. Building names and coordinates work **without internet**. Map *tiles* (satellite/street background) need extra setup for full offline use.

## What works offline today

| Feature | Offline? |
|---------|----------|
| Building names & search | Yes (bundled in app) |
| Category filters | Yes |
| Tap building → details | Yes |
| Campus boundary outline | Yes |
| OpenStreetMap background tiles | No (needs network) |

## Option A — Bundled campus map image (recommended for ASTU-only)

1. Export a campus plan from ASTU GIS / Google Earth / survey PDF as **PNG** (2000×2000px+).
2. Save as: `assets/maps/astu_campus_map.png`
3. Uncomment in `pubspec.yaml`:
   ```yaml
   assets:
     - assets/maps/
   ```
4. Calibrate corners in `lib/core/campus/astu_campus.dart` if needed (`bounds` LatLng).

The app shows this image when offline instead of blank tiles.

## Option B — Cache OpenStreetMap tiles (wifi once)

Add package `flutter_map_tile_caching` and download only the ASTU bounding box (see `AstuCampus.bounds` in code). Typical size: ~5–15 MB for zoom 15–17.

Steps (high level):

1. `flutter pub add flutter_map_tile_caching path_provider`
2. On first launch with Wi‑Fi, run store download for `AstuCampus.bounds`
3. Point `TileLayer` to the cached store path

## Option C — Calibrate building pins (pinpoint names)

Coordinates are in `lib/core/campus/astu_campus.dart` → `CampusPoi.position`.

**To set accurate GPS for each building:**

1. Open [Google Maps](https://maps.google.com), find ASTU campus.
2. Right-click a building → copy lat/lng.
3. Update the matching `LatLng(8.xxxx, 39.xxxx)` in `astu_campus.dart`.
4. Hot restart the app.

**Or** use the in-app admin workflow (future): long-press map → “Set POI here”.

## Adding a new building

```dart
CampusPoi(
  id: 'new_lab',
  name: 'Chemical Engineering Lab',
  category: 'Academic',
  icon: Icons.science_rounded,
  color: Color(0xFF00897B),
  position: LatLng(8.5641, 39.2912),
  description: 'Block 104, ground floor.',
),
```

Add to `AstuCampus.pointsOfInterest` list.

## Firestore sync (optional production path)

Store POIs in collection `campus_pois` with fields: `name`, `category`, `lat`, `lng`, `campusId: "astu"`.  
Cache to Hive on first fetch; map reads cache when offline.
