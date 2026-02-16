import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == 'test@planno.com' && password == 'password') {
      return const UserModel(id: '1', email: 'test@planno.com', name: 'Test User');
    } else {
      throw const ServerFailure('Invalid credentials');
    }
  }
}
