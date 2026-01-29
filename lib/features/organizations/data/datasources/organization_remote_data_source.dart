
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/organization.dart';

abstract class OrganizationRemoteDataSource {
  Future<List<Organization>> getOrganizations();
  Future<List<Organization>> getLiveOrganizations();
  Future<Organization?> getOrganizationById(String id);
  Future<void> addSubscriber(String orgId, String userId);
  Future<void> removeSubscriber(String orgId, String userId);
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final FirebaseFirestore firestore;

  OrganizationRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<Organization>> getOrganizations() async {
    final snapshot = await firestore.collection('organizations').get();
    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  @override
  Future<List<Organization>> getLiveOrganizations() async {
    final snapshot = await firestore
        .collection('organizations')
        .where('isLive', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  @override
  Future<Organization?> getOrganizationById(String id) async {
    final doc = await firestore.collection('organizations').doc(id).get();
    if (!doc.exists) return null;
    return _fromFirestore(doc);
  }

  @override
  Future<void> addSubscriber(String orgId, String userId) async {
    await firestore.collection('organizations').doc(orgId).update({
      'subscribers': FieldValue.arrayUnion([userId])
    });
  }

  @override
  Future<void> removeSubscriber(String orgId, String userId) async {
    await firestore.collection('organizations').doc(orgId).update({
      'subscribers': FieldValue.arrayRemove([userId])
    });
  }

  Organization _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organization(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      youtubeLiveUrl: data['youtubeLiveUrl'],
      facebookLiveUrl: data['facebookLiveUrl'],
      isLive: data['isLive'] ?? false,
      subscribers: List<String>.from(data['subscribers'] ?? []),
    );
  }
}
