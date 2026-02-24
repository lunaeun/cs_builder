import 'dart:js_interop';
import 'package:web/web.dart' as web;

@JS('Object')
extension type JSObjectLiteral._(JSObject _) implements JSObject {
  external factory JSObjectLiteral();
}

@JS('Object.defineProperty')
external void _defineProperty(JSObject obj, JSString key, JSObject descriptor);

void _setJSProperty(JSObject obj, String key, JSAny value) {
  final descriptor = JSObjectLiteral();
  _setRawProperty(descriptor, 'value', value);
  _setRawProperty(descriptor, 'writable', true.toJS);
  _setRawProperty(descriptor, 'enumerable', true.toJS);
  _setRawProperty(descriptor, 'configurable', true.toJS);
  _defineProperty(obj, key.toJS, descriptor);
}

@JS('Reflect.set')
external void _setRawProperty(JSObject obj, String key, JSAny value);

@JS('Reflect.get')
external JSAny? _getRawProperty(JSObject obj, String key);

@JS('PortOne.requestPayment')
external JSPromise<JSAny?> _portOneRequestPayment(JSObject params);

class PaymentService {
  static const String storeId = 'store-ef9f35b0-d0cf-4b5a-b3ef-1ba341b5c10a';
  static const String channelKey = 'channel-key-873a10d7-6355-43d1-9c15-b5b79aa23e61';

  static Future<Map<String, dynamic>> requestPayment({
    required String planId,
    required String planName,
    required int amount,
    required String buyerName,
    required String buyerEmail,
  }) async {
    final orderId = 'csbuilder_${planId}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final params = JSObjectLiteral();
      _setRawProperty(params, 'storeId', storeId.toJS);
      _setRawProperty(params, 'channelKey', channelKey.toJS);
      _setRawProperty(params, 'paymentId', orderId.toJS);
      _setRawProperty(params, 'orderName', planName.toJS);
      _setRawProperty(params, 'totalAmount', amount.toJS);
      _setRawProperty(params, 'currency', 'CURRENCY_KRW'.toJS);
      _setRawProperty(params, 'payMethod', 'CARD'.toJS);

      final result = await _portOneRequestPayment(params).toDart;

      if (result == null) {
        return {'success': false, 'message': '결제가 취소되었습니다.'};
      }

      final resultObj = result as JSObject;
      final code = _getRawProperty(resultObj, 'code');
      final txId = _getRawProperty(resultObj, 'transactionId');

      if (code != null) {
        final codeStr = (code as JSString).toDart;
        if (codeStr.isNotEmpty) {
          return {
            'success': false,
            'message': '결제 실패: $codeStr',
          };
        }
      }

      return {
        'success': true,
        'paymentId': orderId,
        'transactionId': txId != null ? (txId as JSString).toDart : '',
      };
    } catch (e) {
      return {'success': false, 'message': '결제 오류: $e'};
    }
  }
}
