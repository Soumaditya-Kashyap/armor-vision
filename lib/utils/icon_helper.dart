import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IconHelper {
  // Map icon names to Iconsax IconData
  static IconData getIconData(String iconName) {
    final iconMap = {
      // General
      'label': Iconsax.tag,
      'folder': Iconsax.folder,
      'document': Iconsax.document,
      'bookmark': Iconsax.bookmark,
      'star': Iconsax.star,
      'heart': Iconsax.heart,
      'flag': Iconsax.flag,
      'shield': Iconsax.shield_tick,
      'lock': Iconsax.lock,
      'key': Iconsax.key,
      'home': Iconsax.home,
      'archive': Iconsax.archive,

      // Social & Media
      'people': Iconsax.people,
      'message': Iconsax.message,
      'notification': Iconsax.notification,
      'sms': Iconsax.sms,
      'call': Iconsax.call,
      'video': Iconsax.video,
      'camera': Iconsax.camera,
      'gallery': Iconsax.gallery,
      'music': Iconsax.music,
      'microphone': Iconsax.microphone,
      'headphone': Iconsax.headphone,
      'share': Iconsax.share,

      // Finance & Business
      'bank': Iconsax.bank,
      'wallet': Iconsax.wallet,
      'card': Iconsax.card,
      'money': Iconsax.money,
      'dollar_circle': Iconsax.dollar_circle,
      'chart': Iconsax.chart,
      'graph': Iconsax.graph,
      'trend_up': Iconsax.trend_up,
      'shop': Iconsax.shop,
      'bag': Iconsax.bag,
      'receipt': Iconsax.receipt,
      'coin': Iconsax.coin,

      // Work & Productivity
      'briefcase': Iconsax.briefcase,
      'clipboard': Iconsax.clipboard,
      'note': Iconsax.note,
      'task': Iconsax.task_square,
      'calendar': Iconsax.calendar,
      'timer': Iconsax.timer,
      'alarm': Iconsax.alarm,
      'edit': Iconsax.edit,
      'copy': Iconsax.copy,
      'trash': Iconsax.trash,
      'printer': Iconsax.printer,
      'scan': Iconsax.scan,

      // Entertainment
      'game': Iconsax.game,
      'gameboy': Iconsax.gameboy,
      'monitor': Iconsax.monitor,
      'movie': Iconsax.video_square,
      'book': Iconsax.book,
      'music_library': Iconsax.music_library_2,
      'television': Iconsax.monitor_mobbile,
      'ticket': Iconsax.ticket,
      'award': Iconsax.award,
      'gift': Iconsax.gift,
      'emoji_happy': Iconsax.emoji_happy,
      'emoji_normal': Iconsax.emoji_normal,

      // Health & Lifestyle
      'heart_tick': Iconsax.heart_tick,
      'activity': Iconsax.activity,
      'health': Iconsax.health,
      'hospital': Iconsax.hospital,
      'shield_cross': Iconsax.shield_cross,
      'coffee': Iconsax.coffee,
      'cup': Iconsax.cup,
      'restaurant': Iconsax.cake,
      'weight': Iconsax.weight,
      'running': Iconsax.repeate_music,
      'bicycle': Iconsax.driving,
      'moon': Iconsax.moon,

      // Travel & Places
      'airplane': Iconsax.airplane,
      'car': Iconsax.car,
      'bus': Iconsax.bus,
      'ship': Iconsax.ship,
      'location': Iconsax.location,
      'map': Iconsax.map,
      'global': Iconsax.global,
      'building': Iconsax.building,
      'house': Iconsax.house,
      'courthouse': Iconsax.courthouse,
      'gas_station': Iconsax.gas_station,
      'reserve': Iconsax.reserve,

      // Education & Tech
      'teacher': Iconsax.teacher,
      'graduation': Iconsax.status,
      'book_square': Iconsax.book_square,
      'note_text': Iconsax.note_text,
      'calculator': Iconsax.calculator,
      'code': Iconsax.code,
      'programming': Iconsax.programming_arrows,
      'cpu': Iconsax.cpu,
      'cloud': Iconsax.cloud,
      'database': Iconsax.data,
      'security_user': Iconsax.security_user,
      'wifi': Iconsax.wifi,
    };

    return iconMap[iconName] ?? Iconsax.tag; // Default to tag icon
  }

  // Get icon name for default categories based on category name
  static String getDefaultIconName(String categoryName) {
    final category = categoryName.toLowerCase();

    // Email & Communication
    if (category.contains('email') ||
        category.contains('mail') ||
        category.contains('gmail') ||
        category.contains('outlook')) {
      return 'message';
    }
    // Social Media
    else if (category.contains('social') ||
        category.contains('facebook') ||
        category.contains('twitter') ||
        category.contains('instagram') ||
        category.contains('linkedin')) {
      return 'people';
    }
    // Banking & Finance
    else if (category.contains('bank') ||
        category.contains('finance') ||
        category.contains('payment')) {
      return 'bank';
    }
    // Shopping
    else if (category.contains('shop') ||
        category.contains('store') ||
        category.contains('ecommerce') ||
        category.contains('amazon')) {
      return 'shop';
    }
    // Work & Business
    else if (category.contains('work') ||
        category.contains('office') ||
        category.contains('business')) {
      return 'briefcase';
    }
    // Entertainment
    else if (category.contains('entertainment') ||
        category.contains('movie') ||
        category.contains('music') ||
        category.contains('streaming') ||
        category.contains('netflix')) {
      return 'movie';
    }
    // Gaming
    else if (category.contains('game') ||
        category.contains('gaming') ||
        category.contains('steam') ||
        category.contains('xbox') ||
        category.contains('playstation')) {
      return 'game';
    }
    // Health
    else if (category.contains('health') ||
        category.contains('fitness') ||
        category.contains('medical') ||
        category.contains('hospital')) {
      return 'health';
    }
    // Education
    else if (category.contains('school') ||
        category.contains('education') ||
        category.contains('university') ||
        category.contains('learning')) {
      return 'book';
    }
    // Travel
    else if (category.contains('travel') ||
        category.contains('flight') ||
        category.contains('hotel')) {
      return 'airplane';
    }

    return 'label'; // Default
  }
}
