import 'package:flutter/material.dart';

class Car {
  const Car({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.accentColor,
    required this.tagline,
  });

  final String id;
  final String name;
  final String assetPath;
  final Color accentColor;
  final String tagline;

  static const List<Car> all = [
    Car(
      id: 'red_racer',
      name: 'Premium 32',
      assetPath: 'assets/cars/car_red_racer.png',
      accentColor: Color(0xFFE53935),
      tagline: 'High-speed endurance machine',
    ),
    Car(
      id: 'white_speeder',
      name: 'MSCH Speeder',
      assetPath: 'assets/cars/car_white_speeder.png',
      accentColor: Color(0xFF00BCD4),
      tagline: 'Neon cockpit. Lightning stripes.',
    ),
    Car(
      id: 'blue_hyper',
      name: 'Blue Hyper',
      assetPath: 'assets/cars/car_blue_hyper.png',
      accentColor: Color(0xFF42A5F5),
      tagline: 'Carbon spine. Pure velocity.',
    ),
  ];
}
