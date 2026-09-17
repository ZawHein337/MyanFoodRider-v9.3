import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:stackfood_multivendor_driver/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor_driver/helper/date_converter_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class OrderEtaHelper {
  const OrderEtaHelper._();

  static EtaModel? resolve(OrderModel? order, EtaModel? detailsEta) {
    if (_hasWindow(detailsEta)) {
      return detailsEta;
    }
    if (_hasWindow(order?.eta)) {
      return order!.eta;
    }
    return null;
  }

  static bool _hasWindow(EtaModel? eta) => eta?.window != null && eta!.window!.trim().isNotEmpty;

  static String? windowText(EtaModel? eta) {
    final String? window = eta?.window?.trim();
    return (window == null || window.isEmpty) ? null : window;
  }

  static String? dateText(EtaModel? eta) {
    if (eta == null) return null;
    final String? from = dayLabel(eta.fromAt);
    final String? to = dayLabel(eta.toAt);
    if (from == null) return to;
    if (to == null || to == from) return from;
    return '$from - $to';
  }

  static String? dayLabel(String? stamp) {
    final DateTime? day = _dateOnly(stamp);
    if (day == null) return null;

    final DateTime now = DateTime.now();
    final int diff = day.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return _tr('today', 'Today');
    if (diff == 1) return _tr('tomorrow', 'Tomorrow');
    return DateFormat('dd MMM').format(day);
  }

  static String _tr(String key, String fallback) {
    final String value = key.tr;
    return value == key ? fallback : value;
  }

  /// Date portion only - never the clock, never a timezone shift.
  static DateTime? _dateOnly(String? stamp) {
    if (stamp == null || stamp.length < 10) return null;
    try {
      return DateTime.parse(stamp.substring(0, 10));
    } catch (_) {
      return null;
    }
  }
}

class EstimatedDeliveryWidget extends StatelessWidget {
  final OrderModel order;
  final EtaModel? detailsEta;

  const EstimatedDeliveryWidget({super.key, required this.order, this.detailsEta});

  @override
  Widget build(BuildContext context) {
    final EtaModel? eta = OrderEtaHelper.resolve(order, detailsEta);
    final String? window = OrderEtaHelper.windowText(eta);
    final String? date = OrderEtaHelper.dateText(eta);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Row(children: [
        CustomAssetImageWidget(
          image: Images.cooking,
          height: 60, width: 60, fit: BoxFit.contain,
        ),
        const SizedBox(width: Dimensions.paddingSizeLarge),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('food_need_to_deliver_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          if(window != null) ...[
            Text(
              window,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              textDirection: TextDirection.ltr,
            ),

            if(date != null) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(date, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
            ],
          ] else
            _FallbackRange(order: order),
        ])),
      ]),
    );
  }
}

class _FallbackRange extends StatelessWidget {
  final OrderModel order;
  const _FallbackRange({required this.order});

  @override
  Widget build(BuildContext context) {
    final int minutes = DateConverter.differenceInMinute(order.restaurantDeliveryTime, order.createdAt, order.processingTime, order.scheduleAt);
    final String range = minutes < 5 ? '1 - 5' : '${minutes - 5} - $minutes';

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(range, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textDirection: TextDirection.ltr),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

      Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
    ]);
  }
}
