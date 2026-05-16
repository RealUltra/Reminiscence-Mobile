import 'package:in_app_review/in_app_review.dart';
import 'package:reminiscence/features/data_storage/app_review.dart';

const minDataLoads = 3;
const maxReviewRequests = 3;
const reviewRequestCooldown = Duration(days: 30);

Future<void> requestReview() async {
  try {
    final dataLoads = await getDataLoads();
    final requestCount = await getReviewRequestCount();
    final lastRequest = await getLastReviewRequest();

    if (dataLoads < minDataLoads) return;
    if (requestCount >= maxReviewRequests) return;

    if (lastRequest != null &&
        DateTime.now().difference(lastRequest) < reviewRequestCooldown) {
      return;
    }

    final review = InAppReview.instance;

    if (await review.isAvailable()) {
      await incrementReviewRequestCount();
      await setLastReviewRequest(DateTime.now());
      await review.requestReview();
    }
  } catch (_) {}
}
