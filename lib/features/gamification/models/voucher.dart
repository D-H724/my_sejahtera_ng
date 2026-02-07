
import 'package:flutter/material.dart';

class Voucher {
  final String id;
  final String title;
  final String description;
  final String discountCode;
  final String expiryDate;
  final String logoUrl; // Just a placeholder for now
  final int cost;
  final Color brandColor;

  const Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.discountCode,
    required this.expiryDate,
    required this.cost,
    required this.brandColor,
    this.logoUrl = '',
  });
}
