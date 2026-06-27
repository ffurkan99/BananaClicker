import 'dart:io';

void main() {
  final mappings = {
    // target path : source path
    'assets/images/backgrounds/jungle.png': 'assets/images/pixel_jungle_bg.png',
    'assets/images/monkeys/classic_monkey.png': 'assets/images/pixel_monkey.png',
    'assets/images/monkeys/ninja_monkey.png': 'assets/images/pixel_monkey.png',
    'assets/images/monkeys/pirate_monkey.png': 'assets/images/monkey_pirate.png',
    'assets/images/monkeys/king_monkey.png': 'assets/images/monkey_golden.png',
    'assets/images/icons/banana.png': 'assets/images/pixel_banana.png',
    'assets/images/icons/coin.png': 'assets/images/pixel_banana.png',
    'assets/images/icons/palm.png': 'assets/images/pixel_banana.png',
    'assets/images/icons/upgrade_arrow.png': 'assets/images/pixel_banana.png',
    'assets/images/icons/trophy.png': 'assets/images/pixel_banana.png',
    'assets/images/icons/shop_basket.png': 'assets/images/pixel_banana.png',
    'assets/images/icons/golden_banana.png': 'assets/images/upgrade_golden_banana.png',
    'assets/images/icons/banana_boost.png': 'assets/images/upgrade_banana_boost.png',
    'assets/images/icons/monkey_helper.png': 'assets/images/upgrade_monkey_helper.png',
    'assets/images/icons/jungle_basket.png': 'assets/images/upgrade_jungle_basket.png',
  };

  for (var entry in mappings.entries) {
    final target = File(entry.key);
    final source = File(entry.value);
    if (source.existsSync()) {
      target.parent.createSync(recursive: true);
      source.copySync(target.path);
      print('Copied ${source.path} -> ${target.path}');
    } else {
      print('Source file not found: ${source.path}');
    }
  }
  print('Asset copy completed successfully!');
}
