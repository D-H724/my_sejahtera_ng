
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RainingIcons extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const RainingIcons({
    super.key, 
    required this.child, 
    this.enabled = true
  });

  @override
  State<RainingIcons> createState() => _RainingIconsState();
}

class _RainingIconsState extends State<RainingIcons> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FallingItem> _items = [];
  final Random _random = Random();
  
  // List of icons to rain
  final List<IconData> _icons = [
    LucideIcons.pill,
    LucideIcons.leaf,
    LucideIcons.heart,
    LucideIcons.droplet,
    LucideIcons.sun,
    LucideIcons.zap,
    LucideIcons.music,
    LucideIcons.star,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 10)
    )..repeat();
    
    // Initialize some items
    for (int i = 0; i < 20; i++) {
        _items.add(_generateItem(true));
    }

    _controller.addListener(() {
      if (widget.enabled) {
        setState(() {
          for (var item in _items) {
            item.y += item.speed;
            item.rotation += item.rotationSpeed;
            if (item.y > 1.1) { // Reset if falls below screen
               _resetItem(item);
            }
          }
        });
      }
    });
  }

  _FallingItem _generateItem(bool randomY) {
    return _FallingItem(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : -0.1,
      size: 15 + _random.nextDouble() * 20,
      icon: _icons[_random.nextInt(_icons.length)],
      speed: 0.002 + _random.nextDouble() * 0.005,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.05,
      opacity: 0.1 + _random.nextDouble() * 0.3,
      color: Colors.white.withOpacity(0.1 + _random.nextDouble() * 0.2),
    );
  }

  void _resetItem(_FallingItem item) {
    item.y = -0.1 - _random.nextDouble() * 0.5; // Stagger re-entry
    item.x = _random.nextDouble();
    item.size = 15 + _random.nextDouble() * 20;
    item.icon = _icons[_random.nextInt(_icons.length)];
    item.speed = 0.002 + _random.nextDouble() * 0.005;
    item.color = Colors.white.withOpacity(0.1 + _random.nextDouble() * 0.2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.enabled)
          ..._items.map((item) {
            return Positioned(
              left: item.x * MediaQuery.of(context).size.width,
              top: item.y * MediaQuery.of(context).size.height,
              child: Transform.rotate(
                angle: item.rotation,
                child: Icon(
                  item.icon,
                  size: item.size,
                  color: item.color,
                ),
              ),
            );
          }),
        widget.child,
      ],
    );
  }
}

class _FallingItem {
  double x;
  double y;
  double size;
  IconData icon;
  double speed;
  double rotation;
  double rotationSpeed;
  double opacity;
  Color color;

  _FallingItem({
    required this.x,
    required this.y,
    required this.size,
    required this.icon,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.color,
  });
}
