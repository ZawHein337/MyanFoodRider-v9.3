import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor_driver/feature/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class OrderProductWidgetWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final List<OrderDetailsModel>? bogoGroup;
  final bool showDivider;
  const OrderProductWidgetWidget({super.key, required this.order, required this.orderDetails, this.bogoGroup, this.showDivider = true});

  @override
  Widget build(BuildContext context) {

    if(bogoGroup != null && bogoGroup!.length > 1) {
      return _BogoOrderProductWidget(bogoGroup: bogoGroup!, showDivider: showDivider);
    }

    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';

    if(orderDetails.variation!.isNotEmpty) {
      for(Variation variation in orderDetails.variation!) {
        variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        for(VariationValue value in variation.variationValues!) {
          variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
        }
        variationText = '${variationText!})';
      }
    }else if(orderDetails.oldVariation!.isNotEmpty) {
      variationText = orderDetails.oldVariation![0].type;
    }
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: CustomImageWidget(
            image: '${orderDetails.foodDetails!.imageFullUrl}',
            height: 60, width: 60, fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              orderDetails.foodDetails?.name ?? '',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            Row(children: [

              Text(
                PriceConverter.convertPrice(orderDetails.price! - orderDetails.discountOnFood!),
                style: robotoMedium,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              orderDetails.discountOnFood! > 0 ? Expanded(child: Text(
                PriceConverter.convertPrice(orderDetails.price),
                style: robotoMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              )) : const Expanded(child: SizedBox()),

              /*Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                child: Text(
                  orderDetails.foodDetails!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                ),
              ) : const SizedBox(),*/
            ]),

            addOnText.isNotEmpty ? Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(children: [
                Text('${'addons'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                Flexible(child: Text(
                  addOnText,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                )),

              ]),
            ) : const SizedBox(),

            orderDetails.foodDetails!.variations!.isNotEmpty ? Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(children: [
                Text('${'variations'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                Flexible(child: Text(
                  variationText!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                )),

              ]),
            ) : const SizedBox(),

          ]),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Column(children: [

          Row(children: [
            Text('${'quantity'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

            Text(
              orderDetails.quantity.toString(),
              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
          SizedBox(height: Dimensions.paddingSizeSmall),

          Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: Text(
              orderDetails.foodDetails!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
            ),
          ) : const SizedBox(),

        ]),

      ]),

      showDivider ? Divider(height: 35, color: Theme.of(context).hintColor.withValues(alpha: 0.3)) : const SizedBox(),

    ]);
  }
}

class _BogoOrderProductWidget extends StatelessWidget {
  final List<OrderDetailsModel> bogoGroup;
  final bool showDivider;
  const _BogoOrderProductWidget({required this.bogoGroup, this.showDivider = true});

  static List<String> _thumbnailsOf(List<OrderDetailsModel> items) {
    return items.map((item) => item.foodDetails?.imageFullUrl ?? '').where((url) => url.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {

    List<OrderDetailsModel> buyItems = bogoGroup.where((item) => !item.isFreeItem).toList();
    List<OrderDetailsModel> freeItems = bogoGroup.where((item) => item.isFreeItem).toList();
    OrderDetailsModel primaryItem = buyItems.isNotEmpty ? buyItems.first : bogoGroup.first;
    double totalPrice = bogoGroup.fold(0, (sum, item) => sum + (item.price ?? 0));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(children: [
        Expanded(
          child: Text(
            '${primaryItem.foodDetails?.name ?? ''} ${'bogo'.tr}',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Text(
            '${'quantity'.tr}: ${primaryItem.quantity ?? bogoGroup.length}',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          ),
        ),
      ]),
      const SizedBox(height: 3),

      Text(
        PriceConverter.convertPrice(totalPrice),
        style: robotoMedium, textDirection: TextDirection.ltr,
      ),
      SizedBox(height: Dimensions.paddingSizeSmall),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _BundleThumbnailGroup(label: 'buying_item'.tr, thumbnails: _thumbnailsOf(buyItems)),
        const SizedBox(width: Dimensions.paddingSizeExtraLarge),
        _BundleThumbnailGroup(label: 'free_item'.tr, thumbnails: _thumbnailsOf(freeItems)),
      ]),

      showDivider ? Divider(height: 35, color: Theme.of(context).hintColor.withValues(alpha: 0.3)) : const SizedBox(),

    ]);
  }
}

/// Two overlapping thumbnails with a "+N" overflow badge for the remainder.
class _BundleThumbnailGroup extends StatelessWidget {
  final String label;
  final List<String> thumbnails;
  const _BundleThumbnailGroup({required this.label, required this.thumbnails});

  static const double _size = 44;
  static const double _overlap = 26;

  @override
  Widget build(BuildContext context) {
    final List<String> visible = thumbnails.take(2).toList();
    final int overflow = thumbnails.length - visible.length;
    final int cardCount = visible.length + (overflow > 0 ? 1 : 0);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      visible.isEmpty ? const SizedBox() : SizedBox(
        height: _size,
        width: _size + (cardCount - 1) * _overlap,
        child: Stack(
          children: [
            ...List.generate(visible.length, (index) => Positioned(
              left: index * _overlap,
              child: Container(
                width: _size, height: _size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: Theme.of(context).cardColor, width: 2),
                ),
                child: CustomImageWidget(image: visible[index], height: _size, width: _size, fit: BoxFit.cover),
              ),
            )),

            if(overflow > 0) Positioned(
              left: visible.length * _overlap,
              child: Container(
                height: _size, width: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: Theme.of(context).cardColor, width: 2),
                ),
                child: Text('+$overflow', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}