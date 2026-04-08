import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/features/organizations/domain/repositories/organization_repository.dart';
import 'package:Livora/features/organizations/data/datasources/organization_remote_data_source.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteDataSource remoteDataSource;

  OrganizationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Organization>> getOrganizations() async {
    return await remoteDataSource.getOrganizations();
  }

  @override
  Future<List<Organization>> getLiveOrganizations() async {
    return await remoteDataSource.getLiveOrganizations();
  }

  @override
  Future<Organization?> getOrganizationById(String id) async {
    return await remoteDataSource.getOrganizationById(id);
  }

  @override
  Future<List<Organization>> searchOrganizations(String query) async {
    // Simplistic client-side search for MVP. 
    // Ideally use Algolia or backend search service for scalability.
    final allOrgs = await remoteDataSource.getOrganizations();
    final lowerQuery = query.toLowerCase();
    return allOrgs.where((org) {
      return org.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
