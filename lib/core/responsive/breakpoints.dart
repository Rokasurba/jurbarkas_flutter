/// Responsive breakpoint definitions for web and mobile layouts.
abstract final class Breakpoints {
  /// Mobile breakpoint (< 600px)
  static const double mobile = 600;

  /// Tablet breakpoint (600px - 1024px)
  static const double tablet = 1024;

  /// Desktop breakpoint (> 1024px)
  static const double desktop = 1440;
}

/// Device type based on screen width.
enum DeviceType {
  mobile,
  tablet,
  desktop;

  /// Returns true if device is mobile.
  bool get isMobile => this == DeviceType.mobile;

  /// Returns true if device is tablet.
  bool get isTablet => this == DeviceType.tablet;

  /// Returns true if device is desktop.
  bool get isDesktop => this == DeviceType.desktop;

  /// Returns true if device is mobile or tablet.
  bool get isMobileOrTablet => isMobile || isTablet;

  /// Returns true if device is tablet or desktop.
  bool get isTabletOrDesktop => isTablet || isDesktop;
}
