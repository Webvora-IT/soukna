import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config['color'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: config['textColor'] as Color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING_REVIEW':
      case 'PENDING':
        return {
          'color': const Color(0xFFF59E0B).withOpacity(0.2),
          'textColor': const Color(0xFFF59E0B),
          'label': 'En attente',
        };
      case 'AVAILABLE':
      case 'ACTIVE':
      case 'CONFIRMED':
        return {
          'color': const Color(0xFF10B981).withOpacity(0.2),
          'textColor': const Color(0xFF10B981),
          'label': status == 'CONFIRMED' ? 'Confirmé' : 'Disponible',
        };
      case 'REJECTED':
        return {
          'color': const Color(0xFFEF4444).withOpacity(0.2),
          'textColor': const Color(0xFFEF4444),
          'label': 'Refusé',
        };
      case 'PREPARING':
        return {
          'color': const Color(0xFF3B82F6).withOpacity(0.2),
          'textColor': const Color(0xFF3B82F6),
          'label': 'En préparation',
        };
      case 'READY':
        return {
          'color': const Color(0xFF8B5CF6).withOpacity(0.2),
          'textColor': const Color(0xFF8B5CF6),
          'label': 'Prêt',
        };
      case 'DELIVERING':
        return {
          'color': const Color(0xFF06B6D4).withOpacity(0.2),
          'textColor': const Color(0xFF06B6D4),
          'label': 'En livraison',
        };
      case 'DELIVERED':
        return {
          'color': const Color(0xFF10B981).withOpacity(0.15),
          'textColor': const Color(0xFF10B981),
          'label': 'Livré',
        };
      case 'CANCELLED':
        return {
          'color': const Color(0xFF6B7280).withOpacity(0.2),
          'textColor': const Color(0xFF9CA3AF),
          'label': 'Annulé',
        };
      case 'SUSPENDED':
        return {
          'color': const Color(0xFFEF4444).withOpacity(0.15),
          'textColor': const Color(0xFFEF4444),
          'label': 'Suspendu',
        };
      default:
        return {
          'color': const Color(0xFF6B7280).withOpacity(0.2),
          'textColor': const Color(0xFF9CA3AF),
          'label': status,
        };
    }
  }
}
