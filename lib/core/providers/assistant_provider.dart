import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'auth_provider.dart';
import 'data_provider.dart';
import '../models/user_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

final assistantProvider = StateNotifierProvider<AssistantNotifier, List<ChatMessage>>((ref) {
  return AssistantNotifier(ref);
});

class AssistantNotifier extends StateNotifier<List<ChatMessage>> {
  AssistantNotifier(this._ref) : super([]);

  final Ref _ref;
  static const String _forcedModelName = 'gemini-2.5-flash-lite';
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
    ),
  );
  GenerativeModel? _model;
  ChatSession? _chat;
  String? _modelName;
  Future<void>? _initFuture;
  String? _lastInitError;

  Future<void> init(String apiKey) async {
    final trimmed = apiKey.trim();

    if (trimmed.isEmpty) {
      _modelName = null;
      _model = null;
      _chat = null;
      _lastInitError =
          'Missing GEMINI_API_KEY. Add it to your .env file (GEMINI_API_KEY=...) and restart the app.';
      _appendAssistantMessageIfEmpty(
        _lastInitError!,
      );
      return;
    }

    _initFuture = _doInit(trimmed);
    try {
      await _initFuture;
      _lastInitError = null;
    } catch (e) {
      debugPrint('AI Assistant init error: $e');
      _modelName = null;
      _model = null;
      _chat = null;
      _lastInitError = _friendlyError(e);
      _appendAssistantMessageIfEmpty(_lastInitError!);
    }
  }

  Future<void> _doInit(String apiKey) async {
    final modelName = _forcedModelName;
    final available = await _isModelAvailableForGenerateContent(apiKey, modelName);
    if (!available) {
      throw Exception(
        'Model $modelName is not available for this API key (v1beta) or does not support generateContent.',
      );
    }

    _modelName = modelName;
    debugPrint('Initializing AI Assistant with $modelName...');

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(
        '''
You are the CampusOne Assistant, an official AI companion for Adama Science and Technology University (ASTU) students.

Your goals:
- Help users understand how CampusOne works and where to find each feature.
- Help users plan study schedules, revision plans, and learning routines based on their classes/exams.
- When you don't know a detail or the user asks for official-only information, say so and guide them to the most relevant university office or the official ASTU website.

CampusOne features:
- Academic Workspace: courses, learning materials, assignments, submissions, and course announcements.
- Schedule: weekly class timetable (and instructor status messages).
- Exam Schedule: batch exam timetable with group allocation, block and room (if configured by admins).
- Complaints: submit issues, track status, staff/admin resolution workflow.
- Announcements & Notifications: campus notices and events.
- Campus Map: ASTU campus navigation.
- Directory: staff contacts (email/phone) and search by name/department.

ASTU (verified highlights from astu.edu.et):
- Dean of Student Services provides: cafeteria, dormitory, health services, guidance and counseling, sports/recreation/co‑curricular activities.
- Engineering and Maintenance Service: facility maintenance, water supply, sewer, electric supply/backup power, building renovation, furniture maintenance, and wastewater treatment.
- Office of Internationalization and Partnership: international collaborations, mobility, and joint programs.

Style:
- Be concise, friendly, academic.
- Ask 1–3 clarifying questions if needed.
- Prefer actionable steps and checklists.
''',
      ),
    );
    _chat = _model!.startChat();
  }

  Future<bool> _isModelAvailableForGenerateContent(String apiKey, String modelName) async {
    final response = await _dio.get(
      'https://generativelanguage.googleapis.com/v1beta/models',
      queryParameters: {'key': apiKey},
    );

    final data = response.data;
    if (data is! Map) {
      throw Exception('Unexpected models response.');
    }

    final models = (data['models'] as List?) ?? const [];
    final normalizedTarget = modelName.startsWith('models/') ? modelName.substring(7) : modelName;

    for (final m in models) {
      if (m is! Map) continue;
      final name = m['name']?.toString();
      if (name == null || name.isEmpty) continue;

      final methods = (m['supportedGenerationMethods'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[];
      if (!methods.contains('generateContent')) continue;

      final stripped = name.startsWith('models/') ? name.substring(7) : name;
      if (stripped == normalizedTarget) return true;
    }

    return false;
  }

  Future<void> sendMessage(String text) async {
    if (_initFuture != null) {
      try {
        await _initFuture;
      } catch (_) {}
    }

    if (_chat == null) {
      final errorMsg = ChatMessage(
        text: _lastInitError ??
            'AI Assistant is not initialized. Please check your GEMINI_API_KEY and restart the app.',
        isUser: false,
        time: DateTime.now(),
      );
      state = [...state, errorMsg];
      return;
    }

    final userMsg = ChatMessage(text: text, isUser: true, time: DateTime.now());
    state = [...state, userMsg];

    try {
      final response = await _chat!.sendMessage(Content.text(_buildPrompt(text)));
      final botMsg = ChatMessage(
        text: response.text ?? 'I am sorry, I could not process that request.',
        isUser: false,
        time: DateTime.now(),
      );
      state = [...state, botMsg];
    } catch (e) {
      debugPrint('AI Assistant Error: $e');
      final errorMsg = ChatMessage(
        text: _friendlyError(e),
        isUser: false,
        time: DateTime.now(),
      );
      state = [...state, errorMsg];
    }
  }

  void clearChat() {
    state = [];
    if (_model != null) {
      _chat = _model!.startChat();
    }
  }

  void _appendAssistantMessageIfEmpty(String text) {
    if (state.isNotEmpty) return;
    state = [
      ChatMessage(text: text, isUser: false, time: DateTime.now()),
    ];
  }

  String _buildPrompt(String userText) {
    final user = _ref.read(currentUserProvider).valueOrNull;
    final schedule = _ref.read(scheduleProvider).valueOrNull ?? const <ScheduleItem>[];
    final exam = _ref.read(examScheduleProvider).valueOrNull;
    final kb = _ref.read(assistantKnowledgeProvider).valueOrNull;

    final ctx = _buildUserContext(user, schedule, exam, kb);
    if (ctx.trim().isEmpty) return userText;

    return '''
Context (do not quote verbatim unless asked):
$ctx

User message:
$userText
''';
  }

  String _buildUserContext(
    UserModel? user,
    List<ScheduleItem> schedule,
    Map<String, dynamic>? exam,
    String? knowledgeBase,
  ) {
    final lines = <String>[];

    if (user != null) {
      lines.add('User: ${user.name} (${user.role.name})');
      if (user.department != null && user.department!.trim().isNotEmpty) {
        lines.add('Department: ${user.department}');
      }
      if (user.cohort != null && user.cohort!.trim().isNotEmpty) {
        lines.add('Cohort: ${user.cohort}');
      }
      if (user.yearSemester != null && user.yearSemester!.trim().isNotEmpty) {
        lines.add('Section: ${user.yearSemester}');
      }
      if (user.studentGroup != null && user.studentGroup!.trim().isNotEmpty) {
        lines.add('Group: ${user.studentGroup}');
      }
    }

    final todayIndex = DateTime.now().weekday;
    final todayClasses = schedule
        .where((s) => s.type == ScheduleType.classType && s.dayIndex == todayIndex)
        .toList();
    if (todayClasses.isNotEmpty) {
      lines.add('Today classes:');
      for (final c in todayClasses.take(6)) {
        final statusActive = c.statusMessage != null &&
            c.statusMessage!.trim().isNotEmpty &&
            (c.statusExpiresAt == null || c.statusExpiresAt!.isAfter(DateTime.now()));
        final status = statusActive ? ' (${c.statusMessage})' : '';
        lines.add('- ${c.startTime}-${c.endTime} ${c.subject} @ ${c.room} • ${c.instructor}$status');
      }
    }

    if (exam != null && user != null && user.studentGroup != null && user.studentGroup!.trim().isNotEmpty) {
      final allocations = (exam['allocations'] as List?) ?? const [];
      Map? myAllocation;
      for (final raw in allocations) {
        if (raw is Map && raw['group'] == user.studentGroup) {
          myAllocation = raw;
          break;
        }
      }

      final examDays = (exam['examDays'] as List?) ?? const [];
      final parsed = <Map<String, dynamic>>[];
      for (final raw in examDays) {
        if (raw is Map) {
          parsed.add(raw.map((k, v) => MapEntry(k.toString(), v)));
        }
      }
      parsed.sort((a, b) {
        final ad = DateTime.tryParse(a['date']?.toString() ?? '');
        final bd = DateTime.tryParse(b['date']?.toString() ?? '');
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });

      if (parsed.isNotEmpty) {
        final block = myAllocation?['block']?.toString();
        final room = myAllocation?['room']?.toString();
        if ((block != null && block.isNotEmpty) || (room != null && room.isNotEmpty)) {
          lines.add('Exam allocation: ${block ?? 'TBA'} • Room ${room ?? 'TBA'}');
        }
        lines.add('Upcoming exams:');
        for (final d in parsed.take(6)) {
          lines.add('- ${d['date'] ?? 'TBA'} ${d['subject'] ?? 'TBA'} (${d['startTime'] ?? 'TBA'}-${d['endTime'] ?? 'TBA'})');
        }
      }
    }

    final kb = knowledgeBase?.trim() ?? '';
    if (kb.isNotEmpty) {
      final trimmedKb = kb.length > 6000 ? kb.substring(0, 6000) : kb;
      lines.add('CampusOne knowledge base (admin-provided):');
      lines.add(trimmedKb);
    }

    return lines.join('\n');
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final underlying = e.error;
      if (underlying != null && underlying.toString().contains('HandshakeException')) {
        return 'SSL/TLS handshake failed while connecting to Gemini. This is usually caused by VPN/proxy/firewall, captive Wi‑Fi portal, incorrect device time, or a blocked network. Try switching networks or disabling VPN.';
      }

      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403 || status == 404) {
        return 'Gemini API key is not authorized. Use a Gemini API key from Google AI Studio and make sure the Gemini API is enabled for that project.';
      }
      return 'Unable to connect to Gemini. Please check your internet connection and try again.';
    }

    final message = e.toString();
    if (message.contains('HandshakeException') ||
        message.contains('CERTIFICATE_VERIFY_FAILED') ||
        message.contains('Connection terminated during handshake')) {
      return 'SSL/TLS handshake failed while connecting to Gemini. This is usually caused by VPN/proxy/firewall, captive Wi‑Fi portal, incorrect device time, or a blocked network. Try switching networks or disabling VPN.';
    }
    if (message.contains('exceeded your current quota') ||
        message.contains('Quota exceeded') ||
        message.contains('rate-limits') ||
        message.contains('rate limit')) {
      final retryMatch = RegExp(r'Please retry in\s+([0-9.]+)s').firstMatch(message);
      final seconds = retryMatch?.group(1);
      if (seconds != null) {
        return 'Gemini quota exceeded. Please wait about ${seconds}s and try again. If this keeps happening, enable billing / a paid plan for your Gemini API key.';
      }
      return 'Gemini quota exceeded. Please wait and try again. If this keeps happening, enable billing / a paid plan for your Gemini API key.';
    }

    final modelName = _modelName;
    if (modelName != null && modelName.isNotEmpty) {
      return 'AI Assistant error while using $modelName. Please try again.';
    }

    return 'AI Assistant is not initialized. Please check your GEMINI_API_KEY and restart the app.';
  }
}
