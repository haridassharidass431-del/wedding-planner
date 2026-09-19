import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final String imageUrl;
  final int vendorCount;
  final double startingPrice;
  final String priceUnit;
  final bool isPopular;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.imageUrl,
    required this.vendorCount,
    required this.startingPrice,
    this.priceUnit = 'per event',
    this.isPopular = false,
  });
}
