# ASTU offline campus map asset

Place your campus plan image here:

**File name:** `astu_campus_map.png`

**Recommended:** orthographic campus layout or satellite crop of ASTU only (not the whole city).

After adding the file, enable in `pubspec.yaml`:

```yaml
  assets:
    - assets/maps/
```

The map screen uses this automatically when the device is offline.
