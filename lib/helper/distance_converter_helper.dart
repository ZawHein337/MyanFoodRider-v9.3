import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';

class DistanceConverter {

  /// Converts a distance measured in kilometer to the unit configured from admin panel.
  static double convertDistance(double distanceInKm) {
    return isMile ? distanceInKm * 0.621371 : distanceInKm;
  }

  /// Unit label configured from admin panel, ex: km / mi.
  static String get unitLabel {
    String? label = Get.find<SplashController>().configModel?.distanceUnitLabel;
    return (label != null && label.isNotEmpty) ? label : (isMile ? 'mi'.tr : 'km'.tr);
  }

  static bool get isMile => Get.find<SplashController>().configModel?.distanceUnit == 'mi';

  /// Formats a distance measured in kilometer with the configured unit, ex: 1.20 km / 1000+ mi.
  static String convertDistanceWithUnit(double distanceInKm, {int decimalPoint = 2, double maxDistance = 1000}) {
    double distance = convertDistance(distanceInKm);
    return '${distance > maxDistance ? '${maxDistance.toInt()}+' : distance.toStringAsFixed(decimalPoint)} $unitLabel';
  }

}