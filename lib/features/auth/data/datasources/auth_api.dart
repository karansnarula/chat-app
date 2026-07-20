import 'package:chat_app/features/auth/data/models/auth_response_dto.dart';
import 'package:chat_app/features/auth/data/models/login_request_dto.dart';
import 'package:chat_app/features/auth/data/models/register_request_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST('/auth/login')
  Future<AuthResponseDto> login(@Body() LoginRequestDto body);

  @POST('/auth/register')
  Future<AuthResponseDto> register(@Body() RegisterRequestDto body);

  @POST('/auth/logout')
  Future<void> logout();
}
