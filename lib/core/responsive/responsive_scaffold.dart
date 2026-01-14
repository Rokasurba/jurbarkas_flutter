import 'package:flutter/material.dart';
import 'package:frontend/core/responsive/breakpoints.dart';
import 'package:frontend/core/responsive/responsive_builder.dart';

/// A scaffold that provides responsive layout with constrained content width
/// for web and full-width for mobile.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.maxContentWidth = 1200,
    this.padding,
    super.key,
  });

  /// The primary content of the scaffold.
  final Widget body;

  /// An app bar to display at the top.
  final PreferredSizeWidget? appBar;

  /// A floating action button.
  final Widget? floatingActionButton;

  /// A drawer to show on the side.
  final Widget? drawer;

  /// A bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// The background color of the scaffold.
  final Color? backgroundColor;

  /// Maximum width for content on larger screens.
  final double maxContentWidth;

  /// Padding around the content.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      body: ResponsiveBuilder(
        builder: (context, info) {
          final content = padding != null
              ? Padding(padding: padding!, child: body)
              : body;

          // On desktop/tablet, constrain the content width
          if (info.isDesktop || info.isTablet) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: content,
              ),
            );
          }

          // On mobile, use full width
          return content;
        },
      ),
    );
  }
}

/// A card container that adapts to responsive layouts.
/// On desktop: shows as an elevated card with max width.
/// On mobile: shows as full-width with minimal elevation.
class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({
    required this.child,
    this.maxWidth = 480,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  /// The content of the card.
  final Widget child;

  /// Maximum width of the card on larger screens.
  final double maxWidth;

  /// Padding inside the card.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        final cardContent = Padding(
          padding: padding,
          child: child,
        );

        if (info.isMobile) {
          // On mobile, use minimal styling
          return cardContent;
        }

        // On tablet/desktop, use elevated card with constraints
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Card(
              elevation: 4,
              child: cardContent,
            ),
          ),
        );
      },
    );
  }
}

/// Responsive padding that adjusts based on screen size.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding = const EdgeInsets.all(24),
    this.desktopPadding = const EdgeInsets.all(32),
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Padding on mobile devices.
  final EdgeInsets mobilePadding;

  /// Padding on tablet devices.
  final EdgeInsets tabletPadding;

  /// Padding on desktop devices.
  final EdgeInsets desktopPadding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        final padding = switch (info.deviceType) {
          DeviceType.mobile => mobilePadding,
          DeviceType.tablet => tabletPadding,
          DeviceType.desktop => desktopPadding,
        };

        return Padding(padding: padding, child: child);
      },
    );
  }
}
