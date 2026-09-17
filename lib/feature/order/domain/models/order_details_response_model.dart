import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_model.dart';

/// Payload of the order-details endpoint.
///
/// The endpoint used to answer with a bare list of order items. It now wraps
/// them in `details` and carries the arrival window the server worked out in
/// `eta`, so both shapes are accepted here and old backends keep working.
class OrderDetailsResponseModel {
  final List<OrderDetailsModel> details;
  final EtaModel? eta;

  OrderDetailsResponseModel({required this.details, this.eta});

  factory OrderDetailsResponseModel.fromResponse(dynamic body) {
    if (body is Map) {
      return OrderDetailsResponseModel(
        details: _parseDetails(body['details']),
        eta: body['eta'] is Map ? EtaModel.fromJson(Map<String, dynamic>.from(body['eta'])) : null,
      );
    }
    return OrderDetailsResponseModel(details: _parseDetails(body));
  }

  static List<OrderDetailsModel> _parseDetails(dynamic raw) {
    final List<OrderDetailsModel> details = [];
    if (raw is List) {
      for (final dynamic item in raw) {
        if (item is Map) {
          details.add(OrderDetailsModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return details;
  }
}
