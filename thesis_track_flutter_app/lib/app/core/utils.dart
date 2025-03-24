import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Utils {
  static String getInitials(String name) {
    return name.split(' ').map((e) => e[0] + e[1]).join().toUpperCase();
  }

  static (IconData, Color) getResearchFieldIconAndColor(String researchField) {
    // Lowercase dan hapus spasi untuk memudahkan matching
    final field = researchField.toLowerCase().replaceAll(' ', '');

    switch (field) {
      // Computer Science / IT
      case 'artificialintelligence':
      case 'machinelearning':
        return (Iconsax.component, const Color(0xFF7B61FF)); // Purple
      case 'computernetworks':
      case 'networking':
        return (Iconsax.global, const Color(0xFF2196F3)); // Blue
      case 'cybersecurity':
      case 'security':
        return (Iconsax.shield_tick, const Color(0xFF4CAF50)); // Green
      case 'datascience':
      case 'bigdata':
        return (Iconsax.data, const Color(0xFF00BCD4)); // Cyan
      case 'mobiledevelopment':
      case 'mobilecomputing':
        return (Iconsax.mobile, const Color(0xFF3F51B5)); // Indigo
      case 'webdevelopment':
        return (Iconsax.code, const Color(0xFF009688)); // Teal
      case 'cloudcomputing':
        return (Iconsax.cloud, const Color(0xFF03A9F4)); // Light Blue
      case 'iot':
      case 'internetofthings':
        return (Iconsax.wifi, const Color(0xFF00BFA5)); // Teal Accent
      case 'blockchain':
        return (Iconsax.text_block, const Color(0xFF607D8B)); // Blue Grey
      case 'gamedev':
      case 'gamedevelopment':
        return (Iconsax.game, const Color(0xFFE91E63)); // Pink

      // Information Systems
      case 'informationsystems':
      case 'mis':
        return (Iconsax.diagram, const Color(0xFF9C27B0)); // Purple
      case 'businessintelligence':
        return (Iconsax.chart_2, const Color(0xFF673AB7)); // Deep Purple
      case 'erp':
      case 'enterpriseresourceplanning':
        return (Iconsax.building_4, const Color(0xFF3949AB)); // Indigo

      // Software Engineering
      case 'softwareengineering':
      case 'softwaredevelopment':
        return (Iconsax.code_1, const Color(0xFF1E88E5)); // Blue
      case 'systemdesign':
        return (Iconsax.hierarchy_square_2, const Color(0xFF00897B)); // Teal
      case 'testing':
      case 'qualityassurance':
        return (Iconsax.tick_square, const Color(0xFF43A047)); // Green

      // Default colors based on first letter for variety
      default:
        final firstChar = field.isEmpty ? 'a' : field[0];
        IconData icon;
        Color color;

        switch (firstChar) {
          case 'a':
          case 'b':
            icon = Iconsax.document_text;
            color = const Color(0xFFF44336); // Red
            break;
          case 'c':
          case 'd':
            icon = Iconsax.document_code;
            color = const Color(0xFFE91E63); // Pink
            break;
          case 'e':
          case 'f':
            icon = Iconsax.document_favorite;
            color = const Color(0xFF9C27B0); // Purple
            break;
          case 'g':
          case 'h':
            icon = Iconsax.document_cloud;
            color = const Color(0xFF673AB7); // Deep Purple
            break;
          case 'i':
          case 'j':
            icon = Iconsax.document_normal;
            color = const Color(0xFF3F51B5); // Indigo
            break;
          case 'k':
          case 'l':
            icon = Iconsax.document_filter;
            color = const Color(0xFF2196F3); // Blue
            break;
          case 'm':
          case 'n':
            icon = Iconsax.document_forward;
            color = const Color(0xFF03A9F4); // Light Blue
            break;
          case 'o':
          case 'p':
            icon = Iconsax.document_download;
            color = const Color(0xFF00BCD4); // Cyan
            break;
          case 'q':
          case 'r':
            icon = Iconsax.document_upload;
            color = const Color(0xFF009688); // Teal
            break;
          case 's':
          case 't':
            icon = Iconsax.document_text_1;
            color = const Color(0xFF4CAF50); // Green
            break;
          case 'u':
          case 'v':
            icon = Iconsax.document_like;
            color = const Color(0xFF8BC34A); // Light Green
            break;
          default:
            icon = Iconsax.document_text;
            color = const Color(0xFF607D8B); // Blue Grey
        }
        return (icon, color);
    }
  }
}
