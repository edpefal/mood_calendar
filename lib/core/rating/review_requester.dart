import 'package:in_app_review/in_app_review.dart';

abstract class ReviewRequester {
  Future<void> requestReview();
  Future<void> openStoreListing();
}

class InAppReviewRequester implements ReviewRequester {
  InAppReviewRequester({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  static const String appStoreId = '6752843360';

  final InAppReview _inAppReview;

  @override
  Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  @override
  Future<void> openStoreListing() {
    return _inAppReview.openStoreListing(appStoreId: appStoreId);
  }
}
