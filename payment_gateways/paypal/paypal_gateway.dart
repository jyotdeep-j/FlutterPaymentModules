
class PayPalGateWay {
  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;
  // log queue
  List<String> logQueue = [];
  void initPayPal() async {
    //set debugMode for error logging
    FlutterPaypalNative.isDebugMode = false;

    //initiate payPal plugin
    await _flutterPaypalNativePlugin.init(
      //your app id !!! No Underscore!!! see readme.md for help
      returnUrl: 'nativexo://paypalpay', 
      //client id from developer dashboard
      clientID: Environment.payPalKey.toString(),
      //sandbox, staging, live etc
      payPalEnvironment: FPayPalEnvironment.sandbox,
      //what currency do you plan to use? default is US dollars
      currencyCode: FPayPalCurrencyCode.usd,
      //action paynow?
      action: FPayPalUserAction.payNow,
    );
    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          showResult("cancel");
        },
        onSuccess: (data) {
        

          //successfully paid
          //remove all items from queue
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          String visitor = data.cart?.shippingAddress?.firstName ?? 'Visitor';
          String address =
              data.cart?.shippingAddress?.line1 ?? 'Unknown Address';
          showResult(
            "Order successful ${data.payerId ?? ""} - ${data.orderId ?? ""} - $visitor -$address",
          );

          Future.delayed(const Duration(seconds: 3), () {
            Get.find<PaymentController>()
                .createPaypalPayment(data.orderId.toString());
          });
        },
        onError: (data) {
          Get.find<PaymentController>().isLoading(false);

          //an error occured
          showResult("error: ${data.reason}");
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          showResult(
            "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}",
          );
        },
      ),
    );
  }

  //add card items
  void addCardItems(double amount) async {
    for (String t in logQueue) {
      print(t);
    }

    _flutterPaypalNativePlugin.addPurchaseUnit(
      FPayPalPurchaseUnit(
        amount: amount,

        ///please use your own algorithm for referenceId. Maybe ProductID?
        referenceId: FPayPalStrHelper.getRandomString(16),
      ),
    );
  }

  //PayNow
  void createPayPalPayment(double amount) {
    addCardItems(amount);
    _flutterPaypalNativePlugin.makeOrder(
      action: FPayPalUserAction.payNow,
    );
  }

  // all to log queue
  showResult(String text) {
    logQueue.add(text);
  }
}
