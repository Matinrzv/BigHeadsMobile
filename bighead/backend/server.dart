import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 8080 : 8080;
  final dataFile = File('backend/data.json');
  if (!dataFile.existsSync()) {
    dataFile.createSync(recursive: true);
    dataFile.writeAsStringSync(jsonEncode(<String, dynamic>{
      'users': <Map<String, dynamic>>[],
      'contacts': <String, List<String>>{},
      'messages': <String, List<Map<String, dynamic>>>{},
    }));
  }

  final db = _Db(dataFile);
  await db.load();

  final sessions = <String, String>{}; // token -> userId
  final sockets = <String, List<WebSocket>>{}; // userId -> sockets

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('BigHeads realtime server running on http://0.0.0.0:$port');

  await for (final req in server) {
    stdout.writeln('[REQ] ${req.method} ${req.uri.path}${req.uri.hasQuery ? '?${req.uri.query}' : ''}');
    req.response.headers.set('Access-Control-Allow-Origin', '*');
    req.response.headers.set('Access-Control-Allow-Headers', '*');
    req.response.headers.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');

    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      continue;
    }

    try {
      if (req.uri.path == '/health' && req.method == 'GET') {
        await _json(req, <String, dynamic>{'ok': true});
        continue;
      }

      if (req.uri.path == '/ws' && req.method == 'GET') {
        final token = req.uri.queryParameters['token'] ?? '';
        final userId = sessions[token] ?? '';
        if (userId.isEmpty) {
          req.response.statusCode = HttpStatus.unauthorized;
          await req.response.close();
          continue;
        }
        final ws = await WebSocketTransformer.upgrade(req);
        sockets.putIfAbsent(userId, () => <WebSocket>[]).add(ws);
        ws.listen(
          (_) {},
          onDone: () {
            sockets[userId]?.remove(ws);
          },
          onError: (_) {
            sockets[userId]?.remove(ws);
          },
          cancelOnError: true,
        );
        continue;
      }

      if (req.uri.path == '/auth/register' && req.method == 'POST') {
        final body = await _readJson(req);
        final email = '${body['email'] ?? ''}'.trim().toLowerCase();
        final password = '${body['password'] ?? ''}';
        final name = '${body['name'] ?? ''}'.trim();

        if (email.isEmpty || !email.contains('@')) {
          await _json(req, {'ok': false, 'error': 'INVALID_EMAIL'});
          continue;
        }
        if (password.length < 6) {
          await _json(req, {'ok': false, 'error': 'WEAK_PASSWORD'});
          continue;
        }
        if (db.findUserByEmail(email) != null) {
          await _json(req, {'ok': false, 'error': 'EMAIL_EXISTS'});
          continue;
        }

        final user = <String, dynamic>{
          'userId': _id('u_'),
          'email': email,
          'password': password,
          'name': name.isEmpty ? email.split('@').first : name,
        };
        db.users.add(user);
        await db.save();

        final token = _id('t_');
        sessions[token] = '${user['userId']}';
        await _json(req, {
          'ok': true,
          'token': token,
          'userId': user['userId'],
          'email': user['email'],
          'name': user['name'],
        });
        continue;
      }

      if (req.uri.path == '/auth/login' && req.method == 'POST') {
        final body = await _readJson(req);
        final email = '${body['email'] ?? ''}'.trim().toLowerCase();
        final password = '${body['password'] ?? ''}';
        final user = db.findUserByEmail(email);
        if (user == null) {
          await _json(req, {'ok': false, 'error': 'EMAIL_NOT_FOUND'});
          continue;
        }
        if ('${user['password'] ?? ''}' != password) {
          await _json(req, {'ok': false, 'error': 'WRONG_PASSWORD'});
          continue;
        }
        final token = _id('t_');
        sessions[token] = '${user['userId']}';
        await _json(req, {
          'ok': true,
          'token': token,
          'userId': user['userId'],
          'email': user['email'],
          'name': user['name'],
        });
        continue;
      }

      final userId = _authUserId(req, sessions);
      if (userId.isEmpty) {
        await _json(req, {'ok': false, 'error': 'UNAUTHORIZED'}, code: HttpStatus.unauthorized);
        continue;
      }

      if (req.uri.path == '/users/find' && req.method == 'GET') {
        final email = '${req.uri.queryParameters['email'] ?? ''}'.trim().toLowerCase();
        final user = db.findUserByEmail(email);
        if (user == null) {
          await _json(req, {'ok': false, 'error': 'NOT_FOUND'});
          continue;
        }
        await _json(req, {
          'ok': true,
          'user': {
            'userId': user['userId'],
            'email': user['email'],
            'name': user['name'],
          },
        });
        continue;
      }

      if (req.uri.path == '/contacts/add' && req.method == 'POST') {
        final body = await _readJson(req);
        final peerUserId = '${body['peerUserId'] ?? ''}'.trim();
        if (peerUserId.isEmpty || db.findUserById(peerUserId) == null) {
          await _json(req, {'ok': false, 'error': 'USER_NOT_FOUND'});
          continue;
        }

        db.contacts.putIfAbsent(userId, () => <String>[]);
        db.contacts.putIfAbsent(peerUserId, () => <String>[]);
        if (!db.contacts[userId]!.contains(peerUserId)) {
          db.contacts[userId]!.add(peerUserId);
        }
        if (!db.contacts[peerUserId]!.contains(userId)) {
          db.contacts[peerUserId]!.add(userId);
        }
        await db.save();
        await _json(req, {'ok': true});
        continue;
      }

      if (req.uri.path == '/contacts' && req.method == 'GET') {
        final peerIds = db.contacts[userId] ?? <String>[];
        final rows = peerIds
            .map(db.findUserById)
            .whereType<Map<String, dynamic>>()
            .map((u) => {
                  'userId': u['userId'],
                  'email': u['email'],
                  'name': u['name'],
                })
            .toList();
        await _json(req, {'ok': true, 'contacts': rows});
        continue;
      }

      if (req.uri.path == '/messages/send' && req.method == 'POST') {
        final body = await _readJson(req);
        final peerUserId = '${body['peerUserId'] ?? ''}'.trim();
        final text = '${body['text'] ?? ''}'.trim();
        if (peerUserId.isEmpty || text.isEmpty) {
          await _json(req, {'ok': false, 'error': 'INVALID_PAYLOAD'});
          continue;
        }
        if (db.findUserById(peerUserId) == null) {
          await _json(req, {'ok': false, 'error': 'USER_NOT_FOUND'});
          continue;
        }

        final room = _room(userId, peerUserId);
        final message = <String, dynamic>{
          'id': _id('m_'),
          'fromUserId': userId,
          'toUserId': peerUserId,
          'text': text,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        };
        db.messages.putIfAbsent(room, () => <Map<String, dynamic>>[]).add(message);
        await db.save();

        final sender = db.findUserById(userId);
        final fromName = '${sender?['name'] ?? ''}';

        final payload = jsonEncode(<String, dynamic>{
          'type': 'message:new',
          'fromUserId': userId,
          'fromName': fromName,
          'toUserId': peerUserId,
          'text': text,
          'timestamp': message['timestamp'],
        });

        for (final ws in sockets[peerUserId] ?? <WebSocket>[]) {
          ws.add(payload);
        }
        for (final ws in sockets[userId] ?? <WebSocket>[]) {
          ws.add(payload);
        }

        await _json(req, {'ok': true});
        continue;
      }

      if (req.uri.path == '/messages/history' && req.method == 'GET') {
        final peerUserId = '${req.uri.queryParameters['peerUserId'] ?? ''}'.trim();
        final room = _room(userId, peerUserId);
        final rows = db.messages[room] ?? <Map<String, dynamic>>[];
        final mapped = rows.map((m) {
          final sender = db.findUserById('${m['fromUserId'] ?? ''}');
          return <String, dynamic>{
            'fromUserId': '${m['fromUserId'] ?? ''}',
            'fromName': '${sender?['name'] ?? ''}',
            'text': '${m['text'] ?? ''}',
            'timestamp': '${m['timestamp'] ?? ''}',
          };
        }).toList();
        await _json(req, {'ok': true, 'messages': mapped});
        continue;
      }

      await _json(req, {'ok': false, 'error': 'NOT_FOUND'}, code: HttpStatus.notFound);
    } catch (e) {
      stdout.writeln('[ERR] $e');
      await _json(req, {'ok': false, 'error': 'SERVER_ERROR', 'details': '$e'}, code: 500);
    }
  }
}

class _Db {
  _Db(this.file);

  final File file;
  List<Map<String, dynamic>> users = <Map<String, dynamic>>[];
  Map<String, List<String>> contacts = <String, List<String>>{};
  Map<String, List<Map<String, dynamic>>> messages =
      <String, List<Map<String, dynamic>>>{};

  Future<void> load() async {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final usersRaw = decoded['users'];
    if (usersRaw is List) {
      users = usersRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final contactsRaw = decoded['contacts'];
    if (contactsRaw is Map) {
      contacts = contactsRaw.map((k, v) {
        final list = v is List ? v.map((e) => '$e').toList() : <String>[];
        return MapEntry('$k', list);
      });
    }

    final messagesRaw = decoded['messages'];
    if (messagesRaw is Map) {
      messages = messagesRaw.map((k, v) {
        final list = v is List
            ? v.whereType<Map<String, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList()
            : <Map<String, dynamic>>[];
        return MapEntry('$k', list);
      });
    }
  }

  Future<void> save() async {
    final payload = <String, dynamic>{
      'users': users,
      'contacts': contacts,
      'messages': messages,
    };
    await file.writeAsString(jsonEncode(payload));
  }

  Map<String, dynamic>? findUserByEmail(String email) {
    for (final u in users) {
      if ('${u['email'] ?? ''}'.toLowerCase() == email.toLowerCase()) {
        return u;
      }
    }
    return null;
  }

  Map<String, dynamic>? findUserById(String userId) {
    for (final u in users) {
      if ('${u['userId'] ?? ''}' == userId) {
        return u;
      }
    }
    return null;
  }
}

String _authUserId(HttpRequest req, Map<String, String> sessions) {
  final auth = req.headers.value(HttpHeaders.authorizationHeader) ?? '';
  if (!auth.startsWith('Bearer ')) {
    return '';
  }
  final token = auth.substring('Bearer '.length).trim();
  return sessions[token] ?? '';
}

String _id(String prefix) {
  final random = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final suffix = List<String>.generate(
    20,
    (_) => chars[random.nextInt(chars.length)],
  ).join();
  return '$prefix$suffix';
}

String _room(String a, String b) => (a.compareTo(b) <= 0) ? '$a:$b' : '$b:$a';

Future<Map<String, dynamic>> _readJson(HttpRequest req) async {
  final body = await utf8.decoder.bind(req).join();
  final decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  return <String, dynamic>{};
}

Future<void> _json(
  HttpRequest req,
  Map<String, dynamic> payload, {
  int code = HttpStatus.ok,
}) async {
  req.response.statusCode = code;
  req.response.headers.contentType = ContentType.json;
  req.response.write(jsonEncode(payload));
  await req.response.close();
}
