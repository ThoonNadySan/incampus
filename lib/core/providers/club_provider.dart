import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/club_model.dart';
import '../../services/firestore_service.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Stream provider for all clubs
final allClubsProvider = StreamProvider<List<ClubModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllClubs();
});

// Get user's subscribed club IDs
final userSubscribedClubsProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserSubscribedClubIds(userId);
});

// Update user's club subscriptions
class UpdateClubSubscriptionsParams {
  final String userId;
  final List<String> clubIds;

  UpdateClubSubscriptionsParams({
    required this.userId,
    required this.clubIds,
  });
}

final updateUserClubSubscriptionsProvider = FutureProvider.family<void, UpdateClubSubscriptionsParams>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  await firestoreService.updateUserClubSubscriptions(params.userId, params.clubIds);
  
  // Refresh the subscriptions after updating
  ref.invalidate(userSubscribedClubsProvider(params.userId));
});

// Get a single club by ID
final clubProvider = FutureProvider.family<ClubModel?, String>((ref, clubId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getClubById(clubId);
});
