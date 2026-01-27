import 'package:dio/dio.dart';
import 'package:frontend/chat/data/models/chat_message.dart';
import 'package:frontend/chat/data/models/get_messages_params.dart';
import 'package:frontend/chat/data/models/mark_read_request.dart';
import 'package:frontend/chat/data/models/messages_response.dart';
import 'package:frontend/chat/data/models/send_message_request.dart';
import 'package:frontend/core/core.dart';

class ChatRepository {
  ChatRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Gets messages for a conversation with optional pagination.
  ///
  /// [conversationId] - The conversation ID
  /// [limit] - Max messages to return (default 20)
  /// [afterId] - Get messages with id > afterId (for polling new messages)
  /// [beforeId] - Get messages with id < beforeId (for loading older messages)
  Future<ApiResponse<MessagesResponse>> getMessages(
    int conversationId, {
    int? limit,
    int? afterId,
    int? beforeId,
  }) async {
    try {
      final params = GetMessagesParams(
        limit: limit,
        afterId: afterId,
        beforeId: beforeId,
      );
      final queryParams = params.toJson()
        ..removeWhere((_, v) => v == null);

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.conversationMessages(conversationId),
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => MessagesResponse.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Sends a message to a conversation.
  ///
  /// Returns the created message from the server.
  Future<ApiResponse<ChatMessage>> sendMessage(
    int conversationId,
    String content,
  ) async {
    try {
      final request = SendMessageRequest(content: content);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.conversationMessages(conversationId),
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => ChatMessage.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Marks messages in a conversation as read up to the given message ID.
  ///
  /// [conversationId] - The conversation ID
  /// [lastReadId] - Mark all messages up to and including this ID as read
  Future<ApiResponse<void>> markAsRead(
    int conversationId,
    int lastReadId,
  ) async {
    try {
      final request = MarkReadRequest(lastReadId: lastReadId);

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiConstants.conversationRead(conversationId),
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (_) {},
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
