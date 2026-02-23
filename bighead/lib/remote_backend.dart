import 'dart:async';
import 'dart:convert';
import 'dart:io';

class RemoteAuthResult {
  const RemoteAuthResult({
    required this.ok,
    this.error = '',
    this.token = '',
    this.userId = '',
    this.email = '',
    this.name = '',
  });

  final bool ok;
  final String error;
  final String token;
  final String userId;
  final String email;
  final String name;
}

class RemoteUser {
  const RemoteUser({
    required this.userId,
    required this.email,
    required this.name,
  });

  final String userId;
  final String email;
  final String name;
}

class RemoteIncomingMessage {
  const RemoteIncomingMessage({
    required this.fromUserId,
    required this.fromName,
    required this.text,
    required this.timestamp,
  });

  final String fromUserId;
  final String fromName;
  final String text;
  final String timestamp;
}

class RemoteApiClient {
  RemoteApiClient._();

  static final RemoteApiClient instance = RemoteApiClient._();

  String _baseUrl = '';
  String _token = '';
  String _userId = '';
  WebSocket? _socket;

  final StreamController<RemoteIncomingMessage> _messageController =
      StreamController<RemoteIncomingMessage>.broadcast();

  Stream<RemoteIncomingMessage> get messages => _messageController.stream;
  String get baseUrl => _baseUrl;
  String get token => _token;
  String get userId => _userId;

  bool get isConfigured => _baseUrl.isNotEmpty;
  bool get isAuthenticated => _token.isNotEmpty && _userId.isNotEmpty;

  void configureBaseUrl(String baseUrl) {
    _baseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  }

  void restoreSession({
    required String baseUrl,
    required String token,
    required String userId,
  }) {
    configureBaseUrl(baseUrl);
    _token = token;
    _userId = userId;
  }

  Future<void> clearSession() async {
    _token = '';
    _userId = '';
    await _socket?.close();
    _socket = null;
  }

  Future<RemoteAuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!isConfigured) {
      return const RemoteAuthResult(ok: false, error: 'SERVER_NOT_SET');
    }

    final response = await _post(
      '/auth/register',
      <String, dynamic>{
        'email': email,
        'password': password,
        'name': name,
      },
    );
    if (response == null || response['ok'] != true) {
      return RemoteAuthResult(
        ok: false,
        error: '${response?['error'] ?? 'REGISTER_FAILED'}',
      );
    }

    return RemoteAuthResult(
      ok: true,
      token: '${response['token'] ?? ''}',
      userId: '${response['userId'] ?? ''}',
      email: '${response['email'] ?? ''}',
      name: '${response['name'] ?? ''}',
    );
  }

  Future<RemoteAuthResult> login({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      return const RemoteAuthResult(ok: false, error: 'SERVER_NOT_SET');
    }

    final response = await _post(
      '/auth/login',
      <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
    if (response == null || response['ok'] != true) {
      return RemoteAuthResult(
        ok: false,
        error: '${response?['error'] ?? 'LOGIN_FAILED'}',
      );
    }

    return RemoteAuthResult(
      ok: true,
      token: '${response['token'] ?? ''}',
      userId: '${response['userId'] ?? ''}',
      email: '${response['email'] ?? ''}',
      name: '${response['name'] ?? ''}',
    );
  }

  Future<void> startSession({
    required String token,
    required String userId,
  }) async {
    _token = token;
    _userId = userId;
    await _connectWebSocket();
  }

  Future<RemoteUser?> findUserByEmail(String email) async {
    final response = await _get('/users/find?email=${Uri.encodeQueryComponent(email)}');
    if (response == null || response['ok'] != true) {
      return null;
    }
    final user = response['user'];
    if (user is! Map) {
      return null;
    }
    return RemoteUser(
      userId: '${user['userId'] ?? ''}',
      email: '${user['email'] ?? ''}',
      name: '${user['name'] ?? ''}',
    );
  }

  Future<List<RemoteUser>> listContacts() async {
    final response = await _get('/contacts');
    if (response == null || response['ok'] != true) {
      return <RemoteUser>[];
    }
    final rows = response['contacts'];
    if (rows is! List) {
      return <RemoteUser>[];
    }
    return rows
        .whereType<Map<String, dynamic>>()
        .map((m) => RemoteUser(
              userId: '${m['userId'] ?? ''}',
              email: '${m['email'] ?? ''}',
              name: '${m['name'] ?? ''}',
            ))
        .where((u) => u.userId.isNotEmpty)
        .toList();
  }

  Future<bool> addContact(String peerUserId) async {
    final response = await _post(
      '/contacts/add',
      <String, dynamic>{'peerUserId': peerUserId},
    );
    return response != null && response['ok'] == true;
  }

  Future<bool> sendMessage({
    required String peerUserId,
    required String text,
  }) async {
    final response = await _post(
      '/messages/send',
      <String, dynamic>{
        'peerUserId': peerUserId,
        'text': text,
      },
    );
    return response != null && response['ok'] == true;
  }

  Future<List<RemoteIncomingMessage>> history(String peerUserId) async {
    final response = await _get('/messages/history?peerUserId=${Uri.encodeQueryComponent(peerUserId)}');
    if (response == null || response['ok'] != true) {
      return <RemoteIncomingMessage>[];
    }
    final rows = response['messages'];
    if (rows is! List) {
      return <RemoteIncomingMessage>[];
    }
    return rows
        .whereType<Map<String, dynamic>>()
        .map((m) => RemoteIncomingMessage(
              fromUserId: '${m['fromUserId'] ?? ''}',
              fromName: '${m['fromName'] ?? ''}',
              text: '${m['text'] ?? ''}',
              timestamp: '${m['timestamp'] ?? ''}',
            ))
        .toList();
  }

  Future<void> _connectWebSocket() async {
    if (!isConfigured || !isAuthenticated) {
      return;
    }
    await _socket?.close();
    _socket = null;

    final wsUri = Uri.parse(_baseUrl.replaceFirst(RegExp(r'^http'), 'ws'))
        .replace(path: '/ws', queryParameters: <String, String>{'token': _token});

    try {
      final socket = await WebSocket.connect(wsUri.toString());
      _socket = socket;
      socket.listen(
        (dynamic raw) {
          try {
            final decoded = jsonDecode('$raw');
            if (decoded is! Map) {
              return;
            }
            if ('${decoded['type'] ?? ''}' != 'message:new') {
              return;
            }
            _messageController.add(
              RemoteIncomingMessage(
                fromUserId: '${decoded['fromUserId'] ?? ''}',
                fromName: '${decoded['fromName'] ?? ''}',
                text: '${decoded['text'] ?? ''}',
                timestamp: '${decoded['timestamp'] ?? ''}',
              ),
            );
          } catch (_) {}
        },
        onDone: () {
          _socket = null;
        },
        onError: (_) {
          _socket = null;
        },
        cancelOnError: true,
      );
    } catch (_) {
      _socket = null;
    }
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    if (!isConfigured) {
      return null;
    }
    try {
      final client = HttpClient();
      final uri = Uri.parse('$_baseUrl$path');
      final request = await client.getUrl(uri);
      if (_token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $_token');
      }
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    if (!isConfigured) {
      return null;
    }
    try {
      final client = HttpClient();
      final uri = Uri.parse('$_baseUrl$path');
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (_token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $_token');
      }
      request.write(jsonEncode(payload));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
