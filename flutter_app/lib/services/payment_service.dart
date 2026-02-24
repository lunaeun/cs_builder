import 'dart:js_interop';
import 'package:web/web.dart' as web;

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
      final result = await _callPortOne(
        orderId: orderId,
        planName: planName,
        amount: amount,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _callPortOne({
    required String orderId,
    required String planName,
    required int amount,
    required String buyerName,
    required String buyerEmail,
  }) async {
    final jsResult = await js_util_callPortOne(
      storeId,
      channelKey,
      orderId,
      planName,
      amount,
      buyerName,
      buyerEmail,
    );

    if (jsResult == null) {
      return {'success': false, 'message': '결제가 취소되었습니다.'};
    }

    final code = jsResult.code;
    final txId = jsResult.txId;

    if (code == null || code.isEmpty) {
      return {'success': false, 'message': '결제 응답 오류'};
    }

    return {
      'success': true,
      'paymentId': orderId,
      'transactionId': txId ?? '',
      'code': code,
    };
  }
}

// JS interop
@JS('PortOne.requestPayment')
external JSPromise<JSObject?> _portOneRequestPayment(JSObject params);

Future<_PortOneResult?> js_util_callPortOne(
  String storeId,
  String channelKey,
  String orderId,
  String planName,
  int amount,
  String buyerName,
  String buyerEmail,
) async {
  final params = JSObject();
  js_util_setProperty(params, 'storeId', storeId.toJS);
  js_util_setProperty(params, 'channelKey', channelKey.toJS);
  js_util_setProperty(params, 'paymentId', orderId.toJS);

  final orderName = planName.toJS;
  js_util_setProperty(params, 'orderName', orderName);

  final totalAmount = amount.toJS;
  js_util_setProperty(params, 'totalAmount', totalAmount);

  js_util_setProperty(params, 'currency', 'CURRENCY_KRW'.toJS);
  js_util_setProperty(params, 'payMethod', 'CARD'.toJS);

  final result = await _portOneRequestPayment(params).toDart;
  if (result == null) return null;

  final code = js_util_getProperty(result, 'code');
  final txId = js_util_getProperty(result, 'txId');

  return _PortOneResult(
    code: code?.toString(),
    txId: txId?.toString(),
  );
}

void js_util_setProperty(JSObject obj, String key, JSAny value) {
  (obj as dynamic)[key] = value;
}

JSAny? js_util_getProperty(JSObject obj, String key) {
  return (obj as dynamic)[key] as JSAny?;
}

class _PortOneResult {
  final String? code;
  final String? txId;
  _PortOneResult({this.code, this.txId});
}
