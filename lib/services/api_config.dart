import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get host {
    if (kIsWeb) return 'localhost';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => '10.0.2.2',
      _ => 'localhost',
    };
  }
}
