// import 'package:aegischeck/features/auth/service/invite_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class FirebaseInviteService implements InviteService {
//   final FirebaseAuth _auth;
//   final http.Client _client;
//   final String _baseUrl;

//   FirebaseInviteService(this._auth, {http.Client? client, String? baseUrl})
//     : _client = client ?? http.Client(),
//       _baseUrl = baseUrl ?? _defaultBaseUrl();

//   static String _defaultBaseUrl() {
//     const envBaseUrl = String.fromEnvironment('INVITES_API_BASE_URL');
//     if (envBaseUrl.isNotEmpty) {
//       return envBaseUrl;
//     }

//     if (kIsWeb ||
//         defaultTargetPlatform == TargetPlatform.windows ||
//         defaultTargetPlatform == TargetPlatform.macOS ||
//         defaultTargetPlatform == TargetPlatform.linux) {
//       return 'http://localhost:4000';
//     }

//     if (defaultTargetPlatform == TargetPlatform.android) {
//       return 'http://10.0.2.2:4000';
//     }

//     return 'http://127.0.0.1:4000';
//   }

//   Future<String> _getIdToken() async {
//     return _getIdTokenWithRefresh(forceRefresh: true);
//   }

//   Future<String> _getIdTokenWithRefresh({required bool forceRefresh}) async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       throw Exception('User not authenticated. Sign in before invite actions.');
//     }

//     final token = await user.getIdToken(forceRefresh);
//     if (token == null || token.isEmpty) {
//       throw Exception(
//         'Unable to obtain Firebase ID token for authenticated user.',
//       );
//     }

//     return token;
//   }

//   Future<http.Response> _postWithAuthRetry({
//     required Uri uri,
//     required Map<String, dynamic> payload,
//   }) async {
//     final initialToken = await _getIdTokenWithRefresh(forceRefresh: true);
//     var response = await _client.post(
//       uri,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $initialToken',
//       },
//       body: jsonEncode(payload),
//     );

//     if (response.statusCode != 401) {
//       return response;
//     }

//     debugPrint(
//       '[InviteService] Received 401. Retrying with a freshly refreshed Firebase ID token.',
//     );
//     final refreshedToken = await _getIdTokenWithRefresh(forceRefresh: true);
//     response = await _client.post(
//       uri,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $refreshedToken',
//       },
//       body: jsonEncode(payload),
//     );

//     return response;
//   }

//   Map<String, dynamic> _decodeJsonBody(http.Response response) {
//     if (response.body.isEmpty) {
//       return <String, dynamic>{};
//     }

//     final decoded = jsonDecode(response.body);
//     if (decoded is Map<String, dynamic>) {
//       return decoded;
//     }

//     return <String, dynamic>{};
//   }

//   @override
//   Future<String> generateInviteCode({
//     required String orgId,
//     int? expiresInHours,
//     int? codeLength,
//   }) async {
//     try {
//       debugPrint(
//         '[InviteService.generateInviteCode] Calling POST $_baseUrl/invites/generate for orgId=$orgId',
//       );
//       final uri = Uri.parse('$_baseUrl/invites/generate');
//       final response = await _postWithAuthRetry(
//         uri: uri,
//         payload: {
//           'orgId': orgId,
//           if (expiresInHours != null) 'expiresInHours': expiresInHours,
//           if (codeLength != null) 'codeLength': codeLength,
//         },
//       );

//       final data = _decodeJsonBody(response);

//       if (response.statusCode < 200 || response.statusCode >= 300) {
//         final message = (data['message'] ?? 'Unable to generate invite code.')
//             .toString();
//         throw Exception('[$_baseUrl] $message (status ${response.statusCode})');
//       }

//       final code = (data['code'] ?? '').toString().trim();
//       if (code.isEmpty) {
//         throw Exception('Invite API returned an empty code.');
//       }

//       debugPrint(
//         '[InviteService.generateInviteCode] Received code length=${code.length}',
//       );
//       return code;
//     } catch (e, stackTrace) {
//       debugPrint('[InviteService.generateInviteCode] Unexpected error: $e');
//       debugPrint('[InviteService.generateInviteCode] Stack: $stackTrace');
//       rethrow;
//     }
//   }

//   @override
//   Future<String> joinOrganization({required String inviteCode}) async {
//     try {
//       debugPrint(
//         '[InviteService.joinOrganization] Calling POST $_baseUrl/invites/join',
//       );
//       final uri = Uri.parse('$_baseUrl/invites/join');
//       final response = await _postWithAuthRetry(
//         uri: uri,
//         payload: {'inviteCode': inviteCode},
//       );

//       final data = _decodeJsonBody(response);

//       if (response.statusCode < 200 || response.statusCode >= 300) {
//         final message = (data['message'] ?? 'Unable to join organization.')
//             .toString();
//         throw Exception('[$_baseUrl] $message (status ${response.statusCode})');
//       }

//       final organizationId = (data['orgId'] ?? '').toString().trim();
//       if (organizationId.isEmpty) {
//         throw Exception('Join API returned an empty orgId.');
//       }

//       debugPrint(
//         '[InviteService.joinOrganization] Joined orgId=$organizationId',
//       );
//       return organizationId;
//     } catch (e, stackTrace) {
//       debugPrint('[InviteService.joinOrganization] Unexpected error: $e');
//       debugPrint('[InviteService.joinOrganization] Stack: $stackTrace');
//       rethrow;
//     }
//   }

//   @override
//   Future<void> revokeInviteCode({
//     required String orgId,
//     required String inviteId,
//   }) async {
//     debugPrint(
//       '[InviteService.revokeInviteCode] Not implemented for REST backend. orgId=$orgId inviteId=$inviteId',
//     );
//     throw UnimplementedError(
//       'Revoke invite endpoint is not implemented on backend.',
//     );
//   }
// }
