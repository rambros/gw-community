import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  test('Divine Connection is a playable 12-second Lottie', () {
    final bytes = File('assets/jsons/divine_connection.json').readAsBytesSync();
    final composition = LottieComposition.parseJsonBytes(bytes);

    expect(composition.duration, const Duration(seconds: 12));
    expect(composition.markers, hasLength(6));
  });

  test('Shiva 09 light is a playable 12-second Lottie', () {
    final bytes = File('assets/jsons/shiva_09_light.json').readAsBytesSync();
    final composition = LottieComposition.parseJsonBytes(bytes);

    expect(composition.duration, const Duration(seconds: 12));
    expect(composition.markers, hasLength(6));
  });

  test('Shiva 02 rays of peace is a playable 12-second Lottie', () {
    final bytes =
        File('assets/jsons/shiva_02_rays_of_peace.json').readAsBytesSync();
    final composition = LottieComposition.parseJsonBytes(bytes);

    expect(composition.duration, const Duration(seconds: 12));
    expect(composition.markers, hasLength(6));
  });

  test('Bliss Radiance is a playable 16-second Lottie', () {
    final bytes = File('assets/jsons/bliss_radiance.json').readAsBytesSync();
    final composition = LottieComposition.parseJsonBytes(bytes);

    expect(composition.duration, const Duration(seconds: 16));
    expect(composition.markers, hasLength(4));
  });

  test('Meditation Bliss Radiance is a playable 14-second Lottie', () {
    final bytes =
        File('assets/jsons/bliss_radiance_meditation.json').readAsBytesSync();
    final composition = LottieComposition.parseJsonBytes(bytes);

    expect(composition.duration, const Duration(seconds: 14));
    expect(composition.markers, hasLength(4));
  });
}
