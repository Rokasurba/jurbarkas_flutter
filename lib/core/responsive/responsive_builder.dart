import 'package:flutter/material.dart';
import 'package:frontend/core/responsive/breakpoints.dart';

/// Provides responsive layout information based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.builder,
    super.key,
  });

  /// Builder function that receives responsive context.
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final info = ResponsiveInfo.fromWidth(constraints.maxWidth);
        return builder(context, info);
      },
    );
  }
}

/// Contains responsive layout information.
class ResponsiveInfo {
  const ResponsiveInfo._({
    required this.screenWidth,
    required this.deviceType,
  });

  factory ResponsiveInfo.fromWidth(double width) {
    final DeviceType deviceType;
    if (width < Breakpoints.mobile) {
      deviceType = DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.desktop;
    }

    return ResponsiveInfo._(
      screenWidth: width,
      deviceType: deviceType,
    );
  }

  /// Current screen width.
  final double screenWidth;

  /// Current device type based on screen width.
  final DeviceType deviceType;

  /// Returns true if current device is mobile.
  bool get isMobile => deviceType.isMobile;

  /// Returns true if current device is tablet.
  bool get isTablet => deviceType.isTablet;

  /// Returns true if current device is desktop.
  bool get isDesktop => deviceType.isDesktop;
}

/// Widget that builds different layouts based on device type.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  /// Widget to show on mobile devices.
  final Widget mobile;

  /// Widget to show on tablet devices. Falls back to mobile if not provided.
  final Widget? tablet;

  /// Widget to show on desktop devices. Falls back to tablet/mobile if not provided.
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        return switch (info.deviceType) {
          DeviceType.desktop => desktop ?? tablet ?? mobile,
          DeviceType.tablet => tablet ?? mobile,
          DeviceType.mobile => mobile,
        };
      },
    );
  }
}
