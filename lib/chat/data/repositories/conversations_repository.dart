import 'package:dio/dio.dart';
import 'package:frontend/chat/data/models/conversation.dart';
import 'package:frontend/chat/data/models/create_conversation_request.dart';
import 'package:frontend/core/core.dart';

class ConversationsRepository {
  ConversationsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Gets all conversations for the authenticated user.
  Future<ApiResponse<List<Conversation>>> getConversations() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.conversations,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) {
          final list = json! as List<dynamic>;
          return list
              .map(
                (item) =>
                    Conversation.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Creates or retrieves an existing conversation with the given user.
  Future<ApiResponse<Conversation>> createConversation(int userId) async {
    try {
      final request = CreateConversationRequest(userId: userId);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.conversations,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => Conversation.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
