import 'package:Livora/features/organizations/domain/entities/organization.dart';

abstract class OrganizationRepository {
  Future<List<Organization>> getOrganizations();
  Future<List<Organization>> getLiveOrganizations();
  Future<Organization?> getOrganizationById(String id);
  Future<List<Organization>> searchOrganizations(String query);
}
