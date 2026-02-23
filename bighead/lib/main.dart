import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bighead/remote_backend.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase.instance.hydrate().whenComplete(() {
    runApp(const BigHeadApp());
  });
}

enum AppLanguage { en, fa }

class BigHeadApp extends StatefulWidget {
  const BigHeadApp({super.key});

  @override
  State<BigHeadApp> createState() => _BigHeadAppState();
}

class _BigHeadAppState extends State<BigHeadApp> {
  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.en;

  @override
  void initState() {
    super.initState();
    final darkMode =
        AppDatabase.instance.getSetting<bool>('darkMode', false) ?? false;
    final language = AppDatabase.instance.getSetting<String>('language', 'en') ?? 'en';
    _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    _language = language == 'fa' ? AppLanguage.fa : AppLanguage.en;
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    AppDatabase.instance.setSetting('darkMode', isDark);
  }

  void _setLanguage(AppLanguage language) {
    setState(() {
      _language = language;
    });
    AppDatabase.instance.setSetting('language', language == AppLanguage.fa ? 'fa' : 'en');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BigHeads',
      theme: BigHeadTheme.lightTheme,
      darkTheme: BigHeadTheme.darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        final textDirection =
            _language == AppLanguage.fa ? TextDirection.rtl : TextDirection.ltr;
        return Directionality(textDirection: textDirection, child: child!);
      },
      home: ValueListenableBuilder<AccountProfile?>(
        valueListenable: AppDatabase.instance.currentUserNotifier,
        builder: (context, auth, _) => HomeShell(
          themeMode: _themeMode,
          onThemeChanged: _toggleTheme,
          language: _language,
          onLanguageChanged: _setLanguage,
          authenticated: auth != null,
        ),
      ),
    );
  }
}

class BigHeadTheme {
  static const _light = BigHeadPalette.light();
  static const _dark = BigHeadPalette.dark();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'BigHeadSans',
      scaffoldBackgroundColor: _light.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _light.blue,
        brightness: Brightness.light,
      ).copyWith(
        primary: _light.ink,
        secondary: _light.blue,
        surface: _light.card,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: 'BigHeadSerif',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          fontFamily: 'BigHeadSerif',
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'BigHeadSans',
      scaffoldBackgroundColor: _dark.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _dark.blue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: _dark.ink,
        secondary: _dark.blue,
        surface: _dark.card,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: 'BigHeadSerif',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          fontFamily: 'BigHeadSerif',
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class BigHeadPalette {
  const BigHeadPalette._({
    required this.canvas,
    required this.ink,
    required this.blue,
    required this.card,
    required this.shadow,
    required this.muted,
    required this.border,
    required this.fog,
  });

  const BigHeadPalette.light()
      : this._(
          canvas: const Color(0xFFF5F7FA),
          ink: const Color(0xFF121826),
          blue: const Color(0xFF1F5EFF),
          card: const Color(0xFFFFFFFF),
          shadow: const Color(0x1A111827),
          muted: const Color(0xFF4B5563),
          border: const Color(0xFFE5E7EB),
          fog: const Color(0xCCFFFFFF),
        );

  const BigHeadPalette.dark()
      : this._(
          canvas: const Color(0xFF0B1220),
          ink: const Color(0xFFE5E7EB),
          blue: const Color(0xFF3B82F6),
          card: const Color(0xFF111827),
          shadow: const Color(0x66111827),
          muted: const Color(0xFF9CA3AF),
          border: const Color(0xFF1F2937),
          fog: const Color(0xCC0B1220),
        );

  final Color canvas;
  final Color ink;
  final Color blue;
  final Color card;
  final Color shadow;
  final Color muted;
  final Color border;
  final Color fog;
}

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  bool get isFa => language == AppLanguage.fa;

  String get appName => isFa ? 'بیگ هدز' : 'BigHeads';
  String get tagline =>
      isFa ? 'پیام‌رسان رسمی برای تیم‌های جدی' : 'Formal messaging for focused teams';
  String get searchHint => isFa ? 'جستجو در چت‌ها و مخاطبین' : 'Search chats and contacts';
  String get inbox => isFa ? 'صندوق گفتگو' : 'Inbox';
  String get contacts => isFa ? 'مخاطبین' : 'Contacts';
  String get calls => isFa ? 'تماس‌ها' : 'Calls';
  String get settings => isFa ? 'تنظیمات' : 'Settings';
  String get profile => isFa ? 'پروفایل' : 'Profile';
  String get filters => isFa ? 'فیلترها' : 'Filters';
  String get status => isFa ? 'وضعیت' : 'Status';
  String get online => isFa ? 'آنلاین' : 'Online';
  String get offline => isFa ? 'آفلاین' : 'Offline';
  String get edit => isFa ? 'ویرایش' : 'Edit';
  String get darkMode => isFa ? 'حالت تاریک' : 'Dark Mode';
  String get languageTitle => isFa ? 'زبان' : 'Language';
  String get notifications => isFa ? 'اعلان‌ها' : 'Notifications';
  String get privacy => isFa ? 'حریم خصوصی' : 'Privacy & Security';
  String get appearance => isFa ? 'ظاهر' : 'Appearance';
  String get about => isFa ? 'درباره' : 'About';
  String get notificationsDetail => isFa ? 'تنظیمات اعلان' : 'Notification Settings';
  String get privacyDetail => isFa ? 'تنظیمات حریم خصوصی' : 'Privacy Settings';
  String get appearanceDetail => isFa ? 'تنظیمات ظاهر' : 'Appearance Settings';
  String get aboutDetail => isFa ? 'درباره بیگ هدز' : 'About BigHeads';
  String get newContact => isFa ? 'مخاطب جدید' : 'New Contact';
  String get invite => isFa ? 'دعوت' : 'Invite';
  String get groups => isFa ? 'گروه‌ها' : 'Groups';
  String get addMember => isFa ? 'افزودن عضو' : 'Add member';
  String get add => isFa ? 'افزودن' : 'Add';
  String get inviteLink => isFa ? 'لینک دعوت' : 'Invite link';
  String get shareLink => isFa ? 'اشتراک‌گذاری لینک' : 'Share link';
  String get groupDetails => isFa ? 'جزئیات گروه' : 'Group Details';
  String get members => isFa ? 'اعضا' : 'Members';
  String get description => isFa ? 'توضیحات' : 'Description';
  String get callDetails => isFa ? 'جزئیات تماس' : 'Call Details';
  String get contactDetails => isFa ? 'جزئیات مخاطب' : 'Contact Details';
  String get profileEdit => isFa ? 'ویرایش پروفایل' : 'Edit Profile';
  String get bio => isFa ? 'بیوگرافی' : 'Bio';
  String get username => isFa ? 'نام کاربری' : 'Username';
  String get phone => isFa ? 'شماره تماس' : 'Phone';
  String get email => isFa ? 'ایمیل' : 'Email';
  String get message => isFa ? 'پیام' : 'Message';
  String get voiceCall => isFa ? 'تماس صوتی' : 'Voice Call';
  String get videoCall => isFa ? 'تماس تصویری' : 'Video Call';
  String get block => isFa ? 'مسدود کردن' : 'Block';
  String get sharedMedia => isFa ? 'رسانه‌های مشترک' : 'Shared Media';
  String get activeNow => isFa ? 'فعال چند دقیقه پیش' : 'Active a few minutes ago';
  String get typeMessage =>
      isFa ? 'پیام خود را بنویسید' : 'Type your message';
  String get save => isFa ? 'ذخیره' : 'Save';
  String get cancel => isFa ? 'انصراف' : 'Cancel';
  String get languageEn => isFa ? 'English' : 'English';
  String get languageFa => isFa ? 'فارسی' : 'Persian';
  String get messagePreview => isFa ? 'پیش‌نمایش پیام' : 'Message previews';
  String get sound => isFa ? 'صدا' : 'Sound';
  String get vibration => isFa ? 'ویبره' : 'Vibration';
  String get callAlerts => isFa ? 'هشدار تماس' : 'Call alerts';
  String get mentionAlerts => isFa ? 'هشدار منشن' : 'Mention alerts';
  String get quietHours => isFa ? 'ساعت سکوت' : 'Quiet hours';
  String get quietStart => isFa ? 'شروع' : 'Start';
  String get quietEnd => isFa ? 'پایان' : 'End';
  String get passcode => isFa ? 'قفل برنامه' : 'Passcode lock';
  String get twoFactor => isFa ? 'تأیید دومرحله‌ای' : 'Two-factor authentication';
  String get lastSeen => isFa ? 'آخرین بازدید' : 'Last seen';
  String get profilePhoto => isFa ? 'عکس پروفایل' : 'Profile photo';
  String get readReceipts => isFa ? 'تیک خوانده‌شدن' : 'Read receipts';
  String get blockedUsers => isFa ? 'کاربران مسدود' : 'Blocked users';
  String get devices => isFa ? 'دستگاه‌ها' : 'Devices';
  String get theme => isFa ? 'پوسته' : 'Theme';
  String get themeSystem => isFa ? 'سیستمی' : 'System';
  String get themeLight => isFa ? 'روشن' : 'Light';
  String get themeDark => isFa ? 'تاریک' : 'Dark';
  String get fontSize => isFa ? 'اندازه فونت' : 'Font size';
  String get bubbleShape => isFa ? 'شکل حباب' : 'Bubble shape';
  String get bubbleRounded => isFa ? 'گرد' : 'Rounded';
  String get bubbleSquare => isFa ? 'مربعی' : 'Square';
  String get wallpaper => isFa ? 'پس‌زمینه چت' : 'Chat wallpaper';
  String get appIcon => isFa ? 'آیکون برنامه' : 'App icon';
  String get compactMode => isFa ? 'حالت فشرده' : 'Compact mode';
  String get version => isFa ? 'نسخه' : 'Version';
  String get build => isFa ? 'بیلد' : 'Build';
  String get terms => isFa ? 'شرایط استفاده' : 'Terms of use';
  String get privacyPolicy => isFa ? 'سیاست حریم خصوصی' : 'Privacy policy';
  String get licenses => isFa ? 'لایسنس‌ها' : 'Licenses';
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.language,
    required this.onLanguageChanged,
    required this.authenticated,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final bool authenticated;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  void _setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final palette = isDark ? const BigHeadPalette.dark() : const BigHeadPalette.light();
    final strings = AppStrings(widget.language);

    final pages = [
      InboxScreen(palette: palette, strings: strings),
      ContactsScreen(palette: palette, strings: strings),
      CallsScreen(palette: palette, strings: strings),
      SettingsScreen(
        palette: palette,
        strings: strings,
        isDark: isDark,
        onThemeChanged: widget.onThemeChanged,
        onLanguageChanged: widget.onLanguageChanged,
        language: widget.language,
      ),
      ProfileScreen(palette: palette, strings: strings),
    ];

    if (!widget.authenticated) {
      return AuthScreen(
        palette: palette,
        strings: strings,
        onLanguageChanged: widget.onLanguageChanged,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          BigHeadBackground(palette: palette),
          SafeArea(
            child: Column(
              children: [
                BigHeadTopBar(
                  palette: palette,
                  strings: strings,
                  onSearchTap: () {},
                  onQrTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MyQrScreen(
                          palette: palette,
                          strings: strings,
                        ),
                      ),
                    );
                  },
                  onNotifyTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => NotificationsCenterScreen(
                          palette: palette,
                          strings: strings,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: BigHeadBottomNav(
                palette: palette,
                currentIndex: _selectedIndex,
                onTap: _setIndex,
                strings: strings,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.palette,
    required this.strings,
    required this.onLanguageChanged,
  });

  final BigHeadPalette palette;
  final AppStrings strings;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loading = false;
  bool _emailMode = false;
  bool _registerMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serverController.text = AppDatabase.instance.serverBaseUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final s = widget.strings;
    return Scaffold(
      body: Stack(
        children: [
          BigHeadBackground(palette: p),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const BigHeadLogo(size: 42),
                          const SizedBox(width: 10),
                          Text(
                            s.appName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: p.ink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _emailMode
                            ? (s.isFa ? 'ورود یا ثبت‌نام با ایمیل' : 'Sign in or register with email')
                            : (s.isFa
                                ? 'ورود یا ثبت نام با گوگل'
                                : 'Sign in or register with Google'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: p.muted),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _serverController,
                        enabled: !loading,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: s.isFa ? 'آدرس سرور (اختیاری)' : 'Server URL (optional)',
                          hintText: 'http://192.168.1.10:8080',
                        ),
                        onChanged: (value) {
                          AppDatabase.instance.setServerBaseUrl(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      if (!_emailMode)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            onPressed: loading
                                ? null
                                : () async {
                                    setState(() => loading = true);
                                    final ok = await AppDatabase.instance.signInWithGoogle();
                                    if (mounted) {
                                      setState(() => loading = false);
                                      if (!ok) {
                                        final authError =
                                            AppDatabase.instance.consumeLastAuthError() ?? 'UNKNOWN';
                                        final errorText = _googleAuthErrorText(
                                          error: authError,
                                          isFa: s.isFa,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(errorText),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            label: Text(
                              s.isFa ? 'ورود با گوگل' : 'Continue with Google',
                            ),
                          ),
                        ),
                      if (_emailMode) ...[
                        if (_registerMode) ...[
                          TextField(
                            controller: _nameController,
                            enabled: !loading,
                            decoration: InputDecoration(
                              labelText: s.isFa ? 'نام نمایشی' : 'Display name',
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextField(
                          controller: _emailController,
                          enabled: !loading,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: s.isFa ? 'ایمیل' : 'Email',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          enabled: !loading,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: s.isFa ? 'رمز عبور' : 'Password',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () async {
                                    setState(() => loading = true);
                                    final ok = _registerMode
                                        ? await AppDatabase.instance.registerWithEmail(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            name: _nameController.text,
                                          )
                                        : await AppDatabase.instance.signInWithEmail(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                          );
                                    if (!mounted) return;
                                    setState(() => loading = false);
                                    if (!ok) {
                                      final authError =
                                          AppDatabase.instance.consumeLastAuthError() ?? 'UNKNOWN';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _emailAuthErrorText(error: authError, isFa: s.isFa),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: Text(
                              _registerMode
                                  ? (s.isFa ? 'ثبت نام' : 'Register')
                                  : (s.isFa ? 'ورود' : 'Sign in'),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: loading
                                ? null
                                : () => setState(() {
                                      _emailMode = !_emailMode;
                                      _registerMode = false;
                                    }),
                            child: Text(
                              _emailMode
                                  ? (s.isFa ? 'ورود با گوگل' : 'Use Google')
                                  : (s.isFa ? 'ورود با ایمیل' : 'Use Email'),
                            ),
                          ),
                          if (_emailMode)
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () => setState(() => _registerMode = !_registerMode),
                              child: Text(
                                _registerMode
                                    ? (s.isFa ? 'حالت ورود' : 'Switch to Sign in')
                                    : (s.isFa ? 'ایجاد حساب جدید' : 'Create account'),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => widget.onLanguageChanged(AppLanguage.en),
                            child: const Text('EN'),
                          ),
                          TextButton(
                            onPressed: () => widget.onLanguageChanged(AppLanguage.fa),
                            child: const Text('FA'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _googleAuthErrorText({
    required String error,
    required bool isFa,
  }) {
    if (error == 'CANCELED') {
      return isFa ? 'ورود توسط کاربر لغو شد.' : 'Google sign-in was canceled.';
    }
    if (error.startsWith('API_10')) {
      return isFa
          ? 'تنظیمات Google OAuth ناقص است (API_10).'
          : 'Google OAuth is not configured correctly (API_10).';
    }
    if (error.startsWith('API_')) {
      return isFa
          ? 'خطای ورود گوگل: $error'
          : 'Google sign-in failed: $error';
    }
    if (error == 'NO_EMAIL') {
      return isFa ? 'ایمیل حساب گوگل دریافت نشد.' : 'No email returned from Google account.';
    }
    return isFa ? 'ورود با گوگل انجام نشد: $error' : 'Google sign-in failed: $error';
  }

  String _emailAuthErrorText({
    required String error,
    required bool isFa,
  }) {
    switch (error) {
      case 'INVALID_EMAIL':
        return isFa ? 'ایمیل معتبر نیست.' : 'Invalid email.';
      case 'WEAK_PASSWORD':
        return isFa ? 'رمز عبور باید حداقل ۶ کاراکتر باشد.' : 'Password must be at least 6 characters.';
      case 'EMAIL_EXISTS':
        return isFa ? 'این ایمیل قبلا ثبت شده است.' : 'This email is already registered.';
      case 'EMAIL_NOT_FOUND':
        return isFa ? 'اکانتی با این ایمیل پیدا نشد.' : 'No account found with this email.';
      case 'WRONG_PASSWORD':
        return isFa ? 'رمز عبور اشتباه است.' : 'Wrong password.';
      case 'ACCOUNT_NOT_FOUND':
        return isFa ? 'اطلاعات حساب ناقص است.' : 'Account data is missing.';
      case 'SERVER_NOT_SET':
        return isFa ? 'آدرس سرور را وارد کنید.' : 'Please enter server URL.';
      case 'REGISTER_FAILED':
      case 'LOGIN_FAILED':
        return isFa ? 'ارتباط با سرور برقرار نشد.' : 'Could not reach server.';
      default:
        return isFa ? 'ورود با ایمیل انجام نشد: $error' : 'Email auth failed: $error';
    }
  }
}

class BigHeadBackground extends StatelessWidget {
  const BigHeadBackground({super.key, required this.palette});

  final BigHeadPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.canvas,
            Color.lerp(palette.canvas, palette.blue, 0.03) ?? palette.canvas,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.blue.withValues(alpha: 0.06),
          ),
        ),
      ),
    );
  }
}

class BigHeadTopBar extends StatelessWidget {
  const BigHeadTopBar({
    super.key,
    required this.palette,
    required this.strings,
    required this.onSearchTap,
    required this.onQrTap,
    required this.onNotifyTap,
  });

  final BigHeadPalette palette;
  final AppStrings strings;
  final VoidCallback onSearchTap;
  final VoidCallback onQrTap;
  final VoidCallback onNotifyTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const BigHeadLogo(size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.appName,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: palette.ink),
                ),
                Text(
                  strings.tagline,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
          BigHeadIconButton(
            icon: Icons.qr_code_scanner,
            palette: palette,
            onTap: onQrTap,
          ),
          const SizedBox(width: 8),
          BigHeadIconButton(
            icon: Icons.notifications_none_rounded,
            palette: palette,
            onTap: onNotifyTap,
          ),
        ],
      ),
    );
  }
}

class BigHeadLogo extends StatelessWidget {
  const BigHeadLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: BigHeadLogoPainter(),
    );
  }
}

class BigHeadLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final outerPaint = Paint()
      ..color = const Color(0xFF1F5EFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    final innerPaint = Paint()..color = const Color(0xFF111827);

    canvas.drawCircle(center, radius * 1.05, outerPaint);
    canvas.drawCircle(center, radius * 0.86, innerPaint);

    final monogramPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.square;

    final hLeft = center.dx - radius * 0.22;
    final hRight = center.dx + radius * 0.22;
    final hTop = center.dy - radius * 0.28;
    final hBottom = center.dy + radius * 0.28;

    canvas.drawLine(Offset(hLeft, hTop), Offset(hLeft, hBottom), monogramPaint);
    canvas.drawLine(Offset(hRight, hTop), Offset(hRight, hBottom), monogramPaint);
    canvas.drawLine(
        Offset(hLeft, center.dy), Offset(hRight, center.dy), monogramPaint);

    final bLeft = center.dx - radius * 0.02;
    final bTop = center.dy - radius * 0.28;
    final bBottom = center.dy + radius * 0.28;
    canvas.drawLine(Offset(bLeft, bTop), Offset(bLeft, bBottom), monogramPaint);

    final upperRect = Rect.fromLTWH(
      center.dx - radius * 0.02,
      center.dy - radius * 0.28,
      radius * 0.32,
      radius * 0.26,
    );
    final lowerRect = Rect.fromLTWH(
      center.dx - radius * 0.02,
      center.dy + radius * 0.02,
      radius * 0.34,
      radius * 0.26,
    );
    canvas.drawArc(upperRect, -math.pi / 2, math.pi, false, monogramPaint);
    canvas.drawArc(lowerRect, -math.pi / 2, math.pi, false, monogramPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BigHeadIconButton extends StatelessWidget {
  const BigHeadIconButton({
    super.key,
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  final IconData icon;
  final BigHeadPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.ink, size: 20),
      ),
    );
  }
}

class BigHeadSearchBar extends StatelessWidget {
  const BigHeadSearchBar({
    super.key,
    required this.hint,
    required this.palette,
    this.onTap,
  });

  final String hint;
  final BigHeadPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: palette.muted),
            const SizedBox(width: 10),
            Text(
              hint,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: palette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class BigHeadBottomNav extends StatelessWidget {
  const BigHeadBottomNav({
    super.key,
    required this.palette,
    required this.currentIndex,
    required this.onTap,
    required this.strings,
  });

  final BigHeadPalette palette;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.chat_bubble_outline, label: strings.inbox),
      _NavItem(icon: Icons.people_outline, label: strings.contacts),
      _NavItem(icon: Icons.call_outlined, label: strings.calls),
      _NavItem(icon: Icons.settings_outlined, label: strings.settings),
      _NavItem(icon: Icons.person_outline, label: strings.profile),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: palette.fog,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = index == currentIndex;
              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? palette.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon,
                          size: 18,
                          color: active ? palette.card : palette.muted),
                      if (active) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: palette.card,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;
    final chats = AppDatabase.instance.chatsNotifier.value;
    final status = AppDatabase.instance.contactsNotifier.value
        .take(8)
        .map(
          (c) => StatusItem(
            id: c.phone,
            label: c.name,
            active: c.status.toLowerCase() != 'offline',
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BigHeadSearchBar(
            hint: strings.searchHint,
            palette: palette,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        if (status.isNotEmpty)
          SizedBox(
            height: 84,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = status[index];
                return StatusChip(item: item, palette: palette, strings: strings);
              },
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: status.length,
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                strings.inbox,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: palette.ink),
              ),
              const Spacer(),
              BigHeadPill(
                label: strings.filters,
                icon: Icons.tune,
                palette: palette,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            children: List.generate(
              BigHeadFilters.values.length,
              (index) => ChoiceChip(
                label: Text(BigHeadFilters.values[index].label(strings)),
                selected: selectedFilter == index,
                onSelected: (_) {
                  setState(() {
                    selectedFilter = index;
                  });
                },
                backgroundColor: palette.card,
                selectedColor: palette.blue,
                labelStyle: TextStyle(
                  color: selectedFilter == index
                      ? palette.card
                      : palette.ink,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: chats.isEmpty
              ? Center(
                  child: Text(
                    strings.isFa
                        ? 'هنوز گفتگویی شروع نشده است.'
                        : 'No chats yet. Start from Contacts.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.muted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return AnimatedEntry(
                      index: index,
                      child: ChatTile(
                        chat: chat,
                        palette: palette,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ChatScreen(
                                chat: chat,
                                palette: palette,
                                strings: strings,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: chats.length,
                ),
        ),
      ],
    );
  }
}

class Contact {
  const Contact({
    required this.name,
    required this.role,
    required this.company,
    required this.status,
    required this.phone,
    required this.email,
    required this.location,
    required this.lastSeen,
    required this.tags,
    required this.notes,
    this.favorite = false,
    this.remoteUserId = '',
  });

  final String name;
  final String role;
  final String company;
  final String status;
  final String phone;
  final String email;
  final String location;
  final String lastSeen;
  final List<String> tags;
  final String notes;
  final bool favorite;
  final String remoteUserId;
}

class AccountProfile {
  const AccountProfile({
    required this.email,
    required this.name,
    required this.phone,
    required this.bio,
    required this.qrCode,
    this.avatarBase64,
  });

  final String email;
  final String name;
  final String phone;
  final String bio;
  final String qrCode;
  final String? avatarBase64;
}

class AppPlatformService {
  static const MethodChannel _channel = MethodChannel('bigheads/platform');

  static Future<bool> sendEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final sent = await _channel.invokeMethod<bool>(
        'sendEmailCode',
        <String, dynamic>{
          'email': email,
          'code': code,
        },
      );
      return sent ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> pickImageBase64() async {
    try {
      return await _channel.invokeMethod<String>('pickImageBase64');
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('signInWithGoogle');
      if (raw is Map) {
        return <String, String>{
          'email': '${raw['email'] ?? ''}',
          'name': '${raw['name'] ?? ''}',
          'error': '${raw['error'] ?? ''}',
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOutGoogle() async {
    try {
      await _channel.invokeMethod<void>('signOutGoogle');
    } catch (_) {}
  }
}

class AppStateStorage {
  static const MethodChannel _channel = MethodChannel('bigheads/storage');

  static Future<File?> _stateFile() async {
    try {
      final basePath = await _channel.invokeMethod<String>('getAppDataPath');
      if (basePath == null || basePath.isEmpty) {
        return null;
      }
      final dir = Directory(basePath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return File('${dir.path}/bigheads_state.json');
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> load() async {
    final file = await _stateFile();
    if (file == null || !file.existsSync()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final file = await _stateFile();
    if (file == null) {
      return;
    }
    try {
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {
      // best-effort persistence
    }
  }
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  final ValueNotifier<List<Contact>> contactsNotifier = ValueNotifier<List<Contact>>([]);
  final ValueNotifier<List<ChatItem>> chatsNotifier = ValueNotifier<List<ChatItem>>([]);
  final ValueNotifier<List<CallItem>> callsNotifier = ValueNotifier<List<CallItem>>([]);
  final ValueNotifier<List<Group>> groupsNotifier = ValueNotifier<List<Group>>([]);
  final ValueNotifier<List<String>> invitesNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<List<AccountProfile>> accountsNotifier =
      ValueNotifier<List<AccountProfile>>([]);
  final ValueNotifier<AccountProfile?> currentUserNotifier =
      ValueNotifier<AccountProfile?>(null);
  final Map<String, List<Message>> _messagesByChatId = <String, List<Message>>{};
  final Map<String, String> _emailPasswordByEmail = <String, String>{};
  final Map<String, String> _remoteContactNamesById = <String, String>{};

  final ValueNotifier<Map<String, Object>> settingsTable =
      ValueNotifier<Map<String, Object>>({
    'darkMode': false,
    'language': 'en',
    'messagePreview': true,
    'sound': true,
    'vibration': true,
    'serverBaseUrl': '',
  });

  bool _hydrated = false;
  String? _lastAuthError;
  String _remoteToken = '';
  String _remoteUserId = '';
  StreamSubscription<RemoteIncomingMessage>? _remoteSub;

  String? consumeLastAuthError() {
    final value = _lastAuthError;
    _lastAuthError = null;
    return value;
  }

  String get serverBaseUrl {
    return (settingsTable.value['serverBaseUrl'] as String? ?? '').trim();
  }

  void setServerBaseUrl(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
    settingsTable.value = {
      ...settingsTable.value,
      'serverBaseUrl': normalized,
    };
    RemoteApiClient.instance.configureBaseUrl(normalized);
    unawaited(_persist());
  }

  bool get _remoteEnabled => serverBaseUrl.isNotEmpty;

  Future<void> _initRemoteFromStoredConfig() async {
    if (!_remoteEnabled) {
      return;
    }
    RemoteApiClient.instance.configureBaseUrl(serverBaseUrl);
    if (_remoteToken.isEmpty || _remoteUserId.isEmpty) {
      return;
    }
    RemoteApiClient.instance.restoreSession(
      baseUrl: serverBaseUrl,
      token: _remoteToken,
      userId: _remoteUserId,
    );
    await RemoteApiClient.instance.startSession(
      token: _remoteToken,
      userId: _remoteUserId,
    );
    _bindRemoteMessages();
    await _syncRemoteContacts();
  }

  void _bindRemoteMessages() {
    _remoteSub?.cancel();
    _remoteSub = RemoteApiClient.instance.messages.listen((event) {
      final chatId = event.fromUserId == _remoteUserId ? '' : event.fromUserId;
      if (chatId.isEmpty) {
        return;
      }
      final chats = List<ChatItem>.from(chatsNotifier.value);
      final existingIndex = chats.indexWhere((c) => c.id == chatId);
      final displayName = _remoteContactNamesById[chatId] ?? event.fromName;
      if (existingIndex < 0) {
        chats.insert(
          0,
          ChatItem(
            id: chatId,
            name: displayName.isEmpty ? chatId : displayName,
            message: event.text,
            time: _nowLabel(),
            unread: 1,
            mood: ChatMood.primary,
          ),
        );
      } else {
        final old = chats.removeAt(existingIndex);
        chats.insert(
          0,
          ChatItem(
            id: old.id,
            name: old.name,
            message: event.text,
            time: _nowLabel(),
            unread: old.unread + 1,
            mood: old.mood,
          ),
        );
      }
      chatsNotifier.value = chats;
      final existing = List<Message>.from(_messagesByChatId[chatId] ?? <Message>[]);
      existing.add(Message(fromMe: false, text: event.text, time: _nowLabel()));
      _messagesByChatId[chatId] = existing;
      unawaited(_persist());
    });
  }

  Future<void> _syncRemoteContacts() async {
    if (!_remoteEnabled || _remoteToken.isEmpty || _remoteUserId.isEmpty) {
      return;
    }
    final remoteContacts = await RemoteApiClient.instance.listContacts();
    if (remoteContacts.isEmpty) {
      return;
    }
    final updated = List<Contact>.from(contactsNotifier.value);
    var changed = false;
    for (final rc in remoteContacts) {
      _remoteContactNamesById[rc.userId] = rc.name;
      final existing = updated.indexWhere((c) => c.remoteUserId == rc.userId);
      if (existing >= 0) {
        continue;
      }
      final byEmail = updated.indexWhere(
        (c) => c.email.trim().toLowerCase() == rc.email.toLowerCase() && c.remoteUserId.isEmpty,
      );
      if (byEmail >= 0) {
        final old = updated[byEmail];
        updated[byEmail] = Contact(
          name: old.name,
          role: old.role,
          company: old.company,
          status: old.status,
          phone: old.phone,
          email: old.email,
          location: old.location,
          lastSeen: old.lastSeen,
          tags: old.tags,
          notes: old.notes,
          favorite: old.favorite,
          remoteUserId: rc.userId,
        );
        changed = true;
      } else {
        updated.insert(
          0,
          Contact(
            name: rc.name,
            role: '',
            company: '',
            status: 'Online',
            phone: '',
            email: rc.email,
            location: '',
            lastSeen: '',
            tags: const <String>[],
            notes: '',
            remoteUserId: rc.userId,
          ),
        );
        changed = true;
      }
    }
    if (changed) {
      contactsNotifier.value = updated;
      await _persist();
    }
  }

  Future<void> hydrate() async {
    if (_hydrated) {
      return;
    }
    final state = await AppStateStorage.load();
    if (state == null) {
      _hydrated = true;
      return;
    }

    final contactsRaw = state['contacts'];
    if (contactsRaw is List) {
      contactsNotifier.value = contactsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => _contactFromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    final chatsRaw = state['chats'];
    if (chatsRaw is List) {
      chatsNotifier.value = chatsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => _chatFromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    final callsRaw = state['calls'];
    if (callsRaw is List) {
      callsNotifier.value = callsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => _callFromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    final groupsRaw = state['groups'];
    if (groupsRaw is List) {
      groupsNotifier.value = groupsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => _groupFromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    final invitesRaw = state['invites'];
    if (invitesRaw is List) {
      invitesNotifier.value = invitesRaw.map((e) => '$e').toList();
    }

    final settingsRaw = state['settings'];
    if (settingsRaw is Map) {
      settingsTable.value = {
        ...settingsTable.value,
        ...Map<String, Object>.from(settingsRaw),
      };
    }

    final messagesRaw = state['messages'];
    if (messagesRaw is Map) {
      _messagesByChatId.clear();
      messagesRaw.forEach((key, value) {
        if (value is List) {
          _messagesByChatId['$key'] = value
              .whereType<Map<String, dynamic>>()
              .map((m) => _messageFromMap(Map<String, dynamic>.from(m)))
              .toList();
        }
      });
    }

    final accountsRaw = state['accounts'];
    if (accountsRaw is List) {
      accountsNotifier.value = accountsRaw
          .whereType<Map<String, dynamic>>()
          .map((m) => _accountFromMap(Map<String, dynamic>.from(m)))
          .toList();
    }

    final authPasswordsRaw = state['authPasswords'];
    if (authPasswordsRaw is Map) {
      _emailPasswordByEmail
        ..clear()
        ..addAll(authPasswordsRaw.map((k, v) => MapEntry('$k', '$v')));
    }

    final remoteTokenRaw = state['remoteToken'];
    if (remoteTokenRaw is String) {
      _remoteToken = remoteTokenRaw;
    }
    final remoteUserIdRaw = state['remoteUserId'];
    if (remoteUserIdRaw is String) {
      _remoteUserId = remoteUserIdRaw;
    }
    final remoteNamesRaw = state['remoteContactNames'];
    if (remoteNamesRaw is Map) {
      _remoteContactNamesById
        ..clear()
        ..addAll(remoteNamesRaw.map((k, v) => MapEntry('$k', '$v')));
    }

    final currentEmail = state['currentUserEmail'];
    if (currentEmail is String && currentEmail.isNotEmpty) {
      currentUserNotifier.value = accountsNotifier.value
          .where((a) => a.email.toLowerCase() == currentEmail.toLowerCase())
          .cast<AccountProfile?>()
          .firstWhere((a) => a != null, orElse: () => null);
    }

    _hydrated = true;
    unawaited(_initRemoteFromStoredConfig());
  }

  void addContact(Contact contact) {
    final updated = List<Contact>.from(contactsNotifier.value)..insert(0, contact);
    contactsNotifier.value = updated;
    unawaited(_persist());
    if (_remoteEnabled && _remoteToken.isNotEmpty && contact.email.trim().isNotEmpty) {
      unawaited(_linkContactToRemote(contact));
    }
  }

  Future<void> _linkContactToRemote(Contact contact) async {
    final email = contact.email.trim().toLowerCase();
    if (email.isEmpty) {
      return;
    }
    final remote = await RemoteApiClient.instance.findUserByEmail(email);
    if (remote == null || remote.userId == _remoteUserId) {
      return;
    }
    final added = await RemoteApiClient.instance.addContact(remote.userId);
    if (!added) {
      return;
    }
    _remoteContactNamesById[remote.userId] = remote.name;
    final contacts = List<Contact>.from(contactsNotifier.value);
    final idx = contacts.indexWhere((c) => c.phone == contact.phone && c.email == contact.email);
    if (idx < 0) {
      return;
    }
    final old = contacts[idx];
    contacts[idx] = Contact(
      name: old.name,
      role: old.role,
      company: old.company,
      status: old.status,
      phone: old.phone,
      email: old.email,
      location: old.location,
      lastSeen: old.lastSeen,
      tags: old.tags,
      notes: old.notes,
      favorite: old.favorite,
      remoteUserId: remote.userId,
    );
    contactsNotifier.value = contacts;
    await _persist();
  }

  Future<bool> signInWithGoogle() async {
    try {
      _lastAuthError = null;
      final user = await AppPlatformService.signInWithGoogle();
      if (user == null) {
        _lastAuthError = 'UNKNOWN';
        return false;
      }
      final platformError = (user['error'] ?? '').trim();
      if (platformError.isNotEmpty) {
        _lastAuthError = platformError;
        return false;
      }
      final email = (user['email'] ?? '').trim().toLowerCase();
      if (email.isEmpty) {
        _lastAuthError = 'NO_EMAIL';
        return false;
      }
      final displayName = (user['name'] ?? '').trim();
      final existing = accountsNotifier.value
          .where((a) => a.email.toLowerCase() == email)
          .toList();
      AccountProfile account;
      if (existing.isNotEmpty) {
        final old = existing.first;
        account = AccountProfile(
          email: old.email,
          name: old.name.isEmpty ? displayName : old.name,
          phone: old.phone,
          bio: old.bio,
          qrCode: old.qrCode,
          avatarBase64: old.avatarBase64,
        );
      } else {
        account = AccountProfile(
          email: email,
          name: displayName,
          phone: '',
          bio: '',
          qrCode: _generateQrCode(email),
        );
      }
      final accounts = List<AccountProfile>.from(accountsNotifier.value);
      final idx = accounts.indexWhere((a) => a.email == account.email);
      if (idx >= 0) {
        accounts[idx] = account;
      } else {
        accounts.add(account);
      }
      accountsNotifier.value = accounts;
      currentUserNotifier.value = account;
      await _persist();
      return true;
    } catch (_) {
      _lastAuthError = 'EXCEPTION';
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _lastAuthError = null;
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      _lastAuthError = 'INVALID_EMAIL';
      return false;
    }
    if (password.trim().length < 6) {
      _lastAuthError = 'WEAK_PASSWORD';
      return false;
    }
    if (_remoteEnabled) {
      RemoteApiClient.instance.configureBaseUrl(serverBaseUrl);
      final remoteResult = await RemoteApiClient.instance.register(
        email: normalizedEmail,
        password: password,
        name: name.trim(),
      );
      if (!remoteResult.ok) {
        _lastAuthError = remoteResult.error;
        return false;
      }
      _remoteToken = remoteResult.token;
      _remoteUserId = remoteResult.userId;
      await RemoteApiClient.instance.startSession(
        token: _remoteToken,
        userId: _remoteUserId,
      );
      _bindRemoteMessages();
    } else {
      if (_emailPasswordByEmail.containsKey(normalizedEmail)) {
        _lastAuthError = 'EMAIL_EXISTS';
        return false;
      }
      _emailPasswordByEmail[normalizedEmail] = password;
    }

    final account = AccountProfile(
      email: normalizedEmail,
      name: name.trim().isEmpty ? normalizedEmail.split('@').first : name.trim(),
      phone: '',
      bio: '',
      qrCode: _generateQrCode(normalizedEmail),
    );
    final accounts = List<AccountProfile>.from(accountsNotifier.value)..add(account);
    accountsNotifier.value = accounts;
    currentUserNotifier.value = account;
    await _persist();
    if (_remoteEnabled) {
      await _syncRemoteContacts();
    }
    return true;
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _lastAuthError = null;
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      _lastAuthError = 'INVALID_EMAIL';
      return false;
    }
    if (_remoteEnabled) {
      RemoteApiClient.instance.configureBaseUrl(serverBaseUrl);
      final remoteResult = await RemoteApiClient.instance.login(
        email: normalizedEmail,
        password: password,
      );
      if (!remoteResult.ok) {
        _lastAuthError = remoteResult.error;
        return false;
      }
      _remoteToken = remoteResult.token;
      _remoteUserId = remoteResult.userId;
      await RemoteApiClient.instance.startSession(
        token: _remoteToken,
        userId: _remoteUserId,
      );
      _bindRemoteMessages();
    } else {
      final savedPassword = _emailPasswordByEmail[normalizedEmail];
      if (savedPassword == null) {
        _lastAuthError = 'EMAIL_NOT_FOUND';
        return false;
      }
      if (savedPassword != password) {
        _lastAuthError = 'WRONG_PASSWORD';
        return false;
      }
    }
    final account = accountsNotifier.value
        .where((a) => a.email.toLowerCase() == normalizedEmail)
        .cast<AccountProfile?>()
        .firstWhere((a) => a != null, orElse: () => null);
    if (account == null) {
      final newAccount = AccountProfile(
        email: normalizedEmail,
        name: normalizedEmail.split('@').first,
        phone: '',
        bio: '',
        qrCode: _generateQrCode(normalizedEmail),
      );
      accountsNotifier.value = List<AccountProfile>.from(accountsNotifier.value)..add(newAccount);
      currentUserNotifier.value = newAccount;
      await _persist();
      if (_remoteEnabled) {
        await _syncRemoteContacts();
      }
      return true;
    }
    currentUserNotifier.value = account;
    await _persist();
    if (_remoteEnabled) {
      await _syncRemoteContacts();
    }
    return true;
  }

  void logout() {
    unawaited(AppPlatformService.signOutGoogle());
    unawaited(RemoteApiClient.instance.clearSession());
    _remoteToken = '';
    _remoteUserId = '';
    _remoteSub?.cancel();
    _remoteSub = null;
    currentUserNotifier.value = null;
    contactsNotifier.value = <Contact>[];
    chatsNotifier.value = <ChatItem>[];
    callsNotifier.value = <CallItem>[];
    groupsNotifier.value = <Group>[];
    invitesNotifier.value = <String>[];
    _messagesByChatId.clear();
    unawaited(_persist());
  }

  void updateCurrentProfile({
    required String email,
    required String name,
    required String phone,
    required String bio,
    String? avatarBase64,
  }) {
    final current = currentUserNotifier.value;
    if (current == null) {
      return;
    }
    final updated = AccountProfile(
      email: email.trim().isEmpty ? current.email : email.trim().toLowerCase(),
      name: name,
      phone: phone,
      bio: bio,
      qrCode: current.qrCode,
      avatarBase64: avatarBase64 ?? current.avatarBase64,
    );
    final accounts = List<AccountProfile>.from(accountsNotifier.value);
    final idx = accounts.indexWhere((a) => a.email == current.email);
    if (idx >= 0) {
      accounts[idx] = updated;
    } else {
      accounts.add(updated);
    }
    accountsNotifier.value = accounts;
    currentUserNotifier.value = updated;
    unawaited(_persist());
  }

  AccountProfile? findAccountByQr(String code) {
    final normalized = code.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final matches =
        accountsNotifier.value.where((a) => a.qrCode == normalized).toList();
    if (matches.isEmpty) {
      return null;
    }
    return matches.first;
  }

  bool contactExists(String phone, String email) {
    return contactsNotifier.value.any(
      (c) => c.phone.trim() == phone.trim() || (email.isNotEmpty && c.email.trim() == email.trim()),
    );
  }

  ChatItem createOrGetChat(Contact contact, AppStrings strings) {
    final chatId = _chatIdFromContact(contact);
    final existing = chatsNotifier.value.where((c) => c.id == chatId).toList();
    if (existing.isNotEmpty) {
      return existing.first;
    }

    final chat = ChatItem(
      id: chatId,
      name: contact.name,
      message: strings.isFa ? 'شروع گفتگو' : 'Conversation started',
      time: _nowLabel(),
      unread: 0,
      mood: ChatMood.primary,
    );
    final updated = List<ChatItem>.from(chatsNotifier.value)..insert(0, chat);
    chatsNotifier.value = updated;
    _messagesByChatId.putIfAbsent(chatId, () => <Message>[]);
    if (_remoteEnabled && contact.remoteUserId.isNotEmpty) {
      unawaited(_pullRemoteHistory(contact.remoteUserId));
    }
    unawaited(_persist());
    return chat;
  }

  Future<void> _pullRemoteHistory(String peerUserId) async {
    final rows = await RemoteApiClient.instance.history(peerUserId);
    if (rows.isEmpty) {
      return;
    }
    final mapped = rows
        .map(
          (m) => Message(
            fromMe: m.fromUserId == _remoteUserId,
            text: m.text,
            time: _formatServerTime(m.timestamp),
          ),
        )
        .toList();
    _messagesByChatId[peerUserId] = mapped;
    unawaited(_persist());
  }

  List<Message> messagesOf(String chatId) {
    return List<Message>.from(_messagesByChatId[chatId] ?? <Message>[]);
  }

  void sendMessage(String chatId, String text, {required bool fromMe}) {
    final current = List<Message>.from(_messagesByChatId[chatId] ?? <Message>[]);
    current.add(Message(fromMe: fromMe, text: text, time: _nowLabel()));
    _messagesByChatId[chatId] = current;

    final chats = List<ChatItem>.from(chatsNotifier.value);
    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx >= 0) {
      final old = chats[idx];
      final updatedChat = ChatItem(
        id: old.id,
        name: old.name,
        message: text,
        time: _nowLabel(),
        unread: fromMe ? old.unread : old.unread + 1,
        mood: old.mood,
      );
      chats.removeAt(idx);
      chats.insert(0, updatedChat);
      chatsNotifier.value = chats;
    }
    if (_remoteEnabled && fromMe && _remoteToken.isNotEmpty) {
      unawaited(_sendRemoteForChat(chatId: chatId, text: text));
    }
    unawaited(_persist());
  }

  Future<void> _sendRemoteForChat({
    required String chatId,
    required String text,
  }) async {
    var peerUserId = chatId.trim();
    if (peerUserId.isEmpty) {
      return;
    }
    if (!peerUserId.startsWith('u_')) {
      if (peerUserId.contains('@')) {
        final remote = await RemoteApiClient.instance.findUserByEmail(peerUserId);
        if (remote != null) {
          peerUserId = remote.userId;
        }
      }
    }
    if (!peerUserId.startsWith('u_')) {
      return;
    }
    await RemoteApiClient.instance.sendMessage(peerUserId: peerUserId, text: text);
  }

  CallItem logCall(Contact contact, {required bool incoming}) {
    final call = CallItem(name: contact.name, time: _nowLabel(), incoming: incoming);
    final updated = List<CallItem>.from(callsNotifier.value)..insert(0, call);
    callsNotifier.value = updated;
    unawaited(_persist());
    return call;
  }

  void addInvite(String target) {
    final sanitized = target.trim();
    if (sanitized.isEmpty) {
      return;
    }
    final updated = List<String>.from(invitesNotifier.value)..insert(0, sanitized);
    invitesNotifier.value = updated;
    unawaited(_persist());
  }

  Group addGroup({
    required String name,
    required String description,
    required List<String> members,
  }) {
    final group = Group(name: name, members: members, description: description);
    final updated = List<Group>.from(groupsNotifier.value)..insert(0, group);
    groupsNotifier.value = updated;
    unawaited(_persist());
    return group;
  }

  Group addMemberToGroup(Group group, String member) {
    final trimmed = member.trim();
    if (trimmed.isEmpty) {
      return group;
    }
    final updatedGroup = Group(
      name: group.name,
      members: [...group.members, trimmed],
      description: group.description,
    );
    final groups = List<Group>.from(groupsNotifier.value);
    final idx = groups.indexWhere((g) => g.name == group.name && g.description == group.description);
    if (idx >= 0) {
      groups[idx] = updatedGroup;
      groupsNotifier.value = groups;
      unawaited(_persist());
    }
    return updatedGroup;
  }

  void blockContact(Contact contact) {
    contactsNotifier.value =
        contactsNotifier.value.where((c) => c.phone != contact.phone).toList();
    final chatId = _chatIdFromContact(contact);
    chatsNotifier.value = chatsNotifier.value.where((c) => c.id != chatId).toList();
    _messagesByChatId.remove(chatId);
    unawaited(_persist());
  }

  T? getSetting<T>(String key, T fallback) {
    final value = settingsTable.value[key];
    if (value is T) {
      return value;
    }
    return fallback;
  }

  void setSetting(String key, Object value) {
    settingsTable.value = {
      ...settingsTable.value,
      key: value,
    };
    unawaited(_persist());
  }

  String _chatIdFromContact(Contact contact) {
    if (contact.remoteUserId.trim().isNotEmpty) {
      return contact.remoteUserId.trim();
    }
    final normalizedEmail = contact.email.trim().toLowerCase();
    if (normalizedEmail.isNotEmpty) {
      return normalizedEmail;
    }
    final normalizedPhone = contact.phone.replaceAll(' ', '').replaceAll('+', '');
    if (normalizedPhone.isNotEmpty) {
      return normalizedPhone;
    }
    return '';
  }

  String _nowLabel() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatServerTime(String iso) {
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) {
      return _nowLabel();
    }
    final hh = parsed.hour.toString().padLeft(2, '0');
    final mm = parsed.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _persist() async {
    final payload = <String, dynamic>{
      'contacts': contactsNotifier.value.map(_contactToMap).toList(),
      'chats': chatsNotifier.value.map(_chatToMap).toList(),
      'calls': callsNotifier.value.map(_callToMap).toList(),
      'groups': groupsNotifier.value.map(_groupToMap).toList(),
      'invites': invitesNotifier.value,
      'settings': settingsTable.value,
      'messages': _messagesByChatId.map(
        (key, value) => MapEntry(key, value.map(_messageToMap).toList()),
      ),
      'accounts': accountsNotifier.value.map(_accountToMap).toList(),
      'authPasswords': _emailPasswordByEmail,
      'remoteToken': _remoteToken,
      'remoteUserId': _remoteUserId,
      'remoteContactNames': _remoteContactNamesById,
      'currentUserEmail': currentUserNotifier.value?.email ?? '',
    };
    await AppStateStorage.save(payload);
  }

  Map<String, dynamic> _contactToMap(Contact c) => {
        'name': c.name,
        'role': c.role,
        'company': c.company,
        'status': c.status,
        'phone': c.phone,
        'email': c.email,
        'location': c.location,
        'lastSeen': c.lastSeen,
        'tags': c.tags,
        'notes': c.notes,
        'favorite': c.favorite,
        'remoteUserId': c.remoteUserId,
      };

  Contact _contactFromMap(Map<String, dynamic> m) => Contact(
        name: '${m['name'] ?? ''}',
        role: '${m['role'] ?? ''}',
        company: '${m['company'] ?? ''}',
        status: '${m['status'] ?? ''}',
        phone: '${m['phone'] ?? ''}',
        email: '${m['email'] ?? ''}',
        location: '${m['location'] ?? ''}',
        lastSeen: '${m['lastSeen'] ?? ''}',
        tags: (m['tags'] is List)
            ? List<String>.from(m['tags'] as List<dynamic>)
            : <String>[],
        notes: '${m['notes'] ?? ''}',
        favorite: m['favorite'] == true,
        remoteUserId: '${m['remoteUserId'] ?? ''}',
      );

  Map<String, dynamic> _chatToMap(ChatItem c) => {
        'id': c.id,
        'name': c.name,
        'message': c.message,
        'time': c.time,
        'unread': c.unread,
      };

  ChatItem _chatFromMap(Map<String, dynamic> m) => ChatItem(
        id: '${m['id'] ?? ''}',
        name: '${m['name'] ?? ''}',
        message: '${m['message'] ?? ''}',
        time: '${m['time'] ?? ''}',
        unread: int.tryParse('${m['unread'] ?? 0}') ?? 0,
        mood: ChatMood.primary,
      );

  Map<String, dynamic> _callToMap(CallItem c) => {
        'name': c.name,
        'time': c.time,
        'incoming': c.incoming,
      };

  CallItem _callFromMap(Map<String, dynamic> m) => CallItem(
        name: '${m['name'] ?? ''}',
        time: '${m['time'] ?? ''}',
        incoming: m['incoming'] == true,
      );

  Map<String, dynamic> _groupToMap(Group g) => {
        'name': g.name,
        'description': g.description,
        'members': g.members,
      };

  Group _groupFromMap(Map<String, dynamic> m) => Group(
        name: '${m['name'] ?? ''}',
        description: '${m['description'] ?? ''}',
        members: (m['members'] is List)
            ? List<String>.from(m['members'] as List<dynamic>)
            : <String>[],
      );

  Map<String, dynamic> _messageToMap(Message m) => {
        'fromMe': m.fromMe,
        'text': m.text,
        'time': m.time,
      };

  Message _messageFromMap(Map<String, dynamic> m) => Message(
        fromMe: m['fromMe'] == true,
        text: '${m['text'] ?? ''}',
        time: '${m['time'] ?? ''}',
      );

  Map<String, dynamic> _accountToMap(AccountProfile a) => {
        'email': a.email,
        'name': a.name,
        'phone': a.phone,
        'bio': a.bio,
        'qrCode': a.qrCode,
        'avatarBase64': a.avatarBase64 ?? '',
      };

  AccountProfile _accountFromMap(Map<String, dynamic> m) => AccountProfile(
        email: '${m['email'] ?? ''}',
        name: '${m['name'] ?? ''}',
        phone: '${m['phone'] ?? ''}',
        bio: '${m['bio'] ?? ''}',
        qrCode: '${m['qrCode'] ?? ''}',
        avatarBase64: ('${m['avatarBase64'] ?? ''}').isEmpty
            ? null
            : '${m['avatarBase64']}',
      );

  String _generateQrCode(String email) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hash = email.hashCode.abs().toRadixString(16).toUpperCase();
    return 'BH-$hash-${now.toRadixString(16).toUpperCase()}';
  }
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;
    final contacts = AppDatabase.instance.contactsNotifier.value;

    final filtered = contacts.where((contact) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return contact.name.toLowerCase().contains(query) ||
          contact.role.toLowerCase().contains(query) ||
          contact.company.toLowerCase().contains(query) ||
          contact.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();

    final favorites = filtered.where((c) => c.favorite).toList();
    final regular = filtered.where((c) => !c.favorite).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.contacts,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: palette.muted),
                hintText: strings.searchHint,
                hintStyle: TextStyle(color: palette.muted),
                border: InputBorder.none,
              ),
              style: TextStyle(color: palette.ink),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  palette: palette,
                  label: strings.isFa ? 'مخاطب جدید' : 'New contact',
                  icon: Icons.person_add_alt,
                  onTap: () async {
                    final created = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => NewContactScreen(
                          palette: palette,
                          strings: strings,
                        ),
                      ),
                    );
                    if (created == true) {
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  palette: palette,
                  label: strings.isFa ? 'دعوت' : 'Invite',
                  icon: Icons.send_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => InviteScreen(
                          palette: palette,
                          strings: strings,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  palette: palette,
                  label: strings.isFa ? 'گروه‌ها' : 'Groups',
                  icon: Icons.group_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GroupsScreen(
                          palette: palette,
                          strings: strings,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                if (favorites.isNotEmpty) ...[
                  _SectionHeader(title: strings.isFa ? 'ویژه' : 'Favorites'),
                  const SizedBox(height: 8),
                  ...favorites.map((contact) => _ContactCard(
                        contact: contact,
                        palette: palette,
                        onTap: () => _openContact(context, contact, palette, strings),
                      )),
                  const SizedBox(height: 12),
                ],
                _SectionHeader(title: strings.isFa ? 'همه مخاطبین' : 'All contacts'),
                const SizedBox(height: 8),
                ...regular.map((contact) => _ContactCard(
                      contact: contact,
                      palette: palette,
                      onTap: () => _openContact(context, contact, palette, strings),
                    )),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(
                      strings.isFa ? 'موردی یافت نشد.' : 'No contacts found.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: palette.muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openContact(
    BuildContext context,
    Contact contact,
    BigHeadPalette palette,
    AppStrings strings,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactDetailScreen(
          contact: contact,
          palette: palette,
          strings: strings,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.palette,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final BigHeadPalette palette;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: palette.blue, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.ink),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.palette,
    required this.onTap,
  });

  final Contact contact;
  final BigHeadPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTileCard(
        palette: palette,
        leading: InitialAvatar(name: contact.name, palette: palette),
        title: contact.name,
        subtitle: '${contact.role} • ${contact.company}',
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              contact.lastSeen,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: palette.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                contact.status,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: palette.blue),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final calls = AppDatabase.instance.callsNotifier.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.calls,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: calls.isEmpty
                ? Center(
                    child: Text(
                      strings.isFa
                          ? 'تماسی ثبت نشده است.'
                          : 'No call history yet.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: palette.muted),
                    ),
                  )
                : ListView.separated(
                    itemCount: calls.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final call = calls[index];
                      return ListTileCard(
                        palette: palette,
                        leading: InitialAvatar(name: call.name, palette: palette),
                        title: call.name,
                        subtitle: call.time,
                        trailing: Icon(
                          call.incoming
                              ? Icons.call_received_rounded
                              : Icons.call_made_rounded,
                          color: palette.blue,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CallDetailScreen(
                                item: call,
                                palette: palette,
                                strings: strings,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CallItem {
  const CallItem({required this.name, required this.time, required this.incoming});

  final String name;
  final String time;
  final bool incoming;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.palette,
    required this.strings,
    required this.isDark,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.language,
  });

  final BigHeadPalette palette;
  final AppStrings strings;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.settings,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 12),
          SettingsTile(
            palette: palette,
            icon: Icons.dark_mode_outlined,
            title: strings.darkMode,
            subtitle: strings.isFa ? 'ظاهر تیره با آبی رسمی' : 'Blue-on-black theme',
            trailing: Switch(
              value: isDark,
              onChanged: onThemeChanged,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 12),
          SettingsTile(
            palette: palette,
            icon: Icons.language_outlined,
            title: strings.languageTitle,
            subtitle: language == AppLanguage.fa ? strings.languageFa : strings.languageEn,
            trailing: Icon(Icons.chevron_right, color: palette.muted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LanguageScreen(
                    palette: palette,
                    strings: strings,
                    language: language,
                    onChanged: onLanguageChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsTile(
            palette: palette,
            icon: Icons.notifications_outlined,
            title: strings.notifications,
            subtitle: strings.isFa ? 'ذکر نام، تماس، یادآوری' : 'Mentions, calls, reminders',
            trailing: Icon(Icons.chevron_right, color: palette.muted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NotificationsSettingsScreen(
                    palette: palette,
                    strings: strings,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsTile(
            palette: palette,
            icon: Icons.lock_outline,
            title: strings.privacy,
            subtitle: strings.isFa ? 'گذرواژه و دستگاه‌ها' : 'Passcode and devices',
            trailing: Icon(Icons.chevron_right, color: palette.muted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PrivacySettingsScreen(
                    palette: palette,
                    strings: strings,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsTile(
            palette: palette,
            icon: Icons.palette_outlined,
            title: strings.appearance,
            subtitle: strings.isFa ? 'فونت و حباب پیام' : 'Fonts and chat bubbles',
            trailing: Icon(Icons.chevron_right, color: palette.muted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AppearanceSettingsScreen(
                    palette: palette,
                    strings: strings,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SettingsTile(
            palette: palette,
            icon: Icons.info_outline,
            title: strings.about,
            subtitle: 'BigHeads 1.0.0',
            trailing: Icon(Icons.chevron_right, color: palette.muted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AboutScreen(
                    palette: palette,
                    strings: strings,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final BigHeadPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: palette.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: palette.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.muted),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({
    super.key,
    required this.palette,
    required this.strings,
    required this.language,
    required this.onChanged,
  });

  final BigHeadPalette palette;
  final AppStrings strings;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: strings.languageTitle,
      palette: palette,
      body: Column(
        children: [
          _LanguageOption(
            label: strings.languageEn,
            selected: language == AppLanguage.en,
            onTap: () {
              onChanged(AppLanguage.en);
              Navigator.of(context).pop();
            },
            palette: palette,
          ),
          const SizedBox(height: 12),
          _LanguageOption(
            label: strings.languageFa,
            selected: language == AppLanguage.fa,
            onTap: () {
              onChanged(AppLanguage.fa);
              Navigator.of(context).pop();
            },
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BigHeadPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? palette.blue : palette.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: palette.ink),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: palette.blue)
            else
              Icon(Icons.radio_button_unchecked, color: palette.muted),
          ],
        ),
      ),
    );
  }
}

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({
    super.key,
    required this.palette,
    required this.strings,
  });

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool messagePreview = true;
  bool sound = true;
  bool vibration = true;
  bool callAlerts = true;
  bool mentionAlerts = true;
  bool quietHours = false;
  TimeOfDay quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay quietEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    messagePreview = db.getSetting<bool>('messagePreview', true) ?? true;
    sound = db.getSetting<bool>('sound', true) ?? true;
    vibration = db.getSetting<bool>('vibration', true) ?? true;
    callAlerts = db.getSetting<bool>('callAlerts', true) ?? true;
    mentionAlerts = db.getSetting<bool>('mentionAlerts', true) ?? true;
    quietHours = db.getSetting<bool>('quietHours', false) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;

    return DetailScaffold(
      title: strings.notificationsDetail,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSection(title: strings.notifications),
          SettingsSwitchRow(
            palette: palette,
            title: strings.messagePreview,
            subtitle: strings.isFa
                ? 'نمایش متن پیام روی اعلان'
                : 'Show message content on alerts',
            value: messagePreview,
            onChanged: (value) {
              setState(() => messagePreview = value);
              AppDatabase.instance.setSetting('messagePreview', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.sound,
            subtitle: strings.isFa ? 'پخش صدای اعلان' : 'Play notification sounds',
            value: sound,
            onChanged: (value) {
              setState(() => sound = value);
              AppDatabase.instance.setSetting('sound', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.vibration,
            subtitle: strings.isFa ? 'ویبره برای اعلان‌ها' : 'Vibrate on alerts',
            value: vibration,
            onChanged: (value) {
              setState(() => vibration = value);
              AppDatabase.instance.setSetting('vibration', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.callAlerts,
            subtitle: strings.isFa ? 'هشدار برای تماس‌ها' : 'Alerts for calls',
            value: callAlerts,
            onChanged: (value) {
              setState(() => callAlerts = value);
              AppDatabase.instance.setSetting('callAlerts', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.mentionAlerts,
            subtitle: strings.isFa
                ? 'فقط زمانی که منشن شوید'
                : 'Only when you are mentioned',
            value: mentionAlerts,
            onChanged: (value) {
              setState(() => mentionAlerts = value);
              AppDatabase.instance.setSetting('mentionAlerts', value);
            },
          ),
          const SizedBox(height: 12),
          SettingsSection(title: strings.quietHours),
          SettingsSwitchRow(
            palette: palette,
            title: strings.quietHours,
            subtitle: strings.isFa
                ? 'بی‌صدا کردن اعلان‌ها'
                : 'Silence all alerts during hours',
            value: quietHours,
            onChanged: (value) {
              setState(() => quietHours = value);
              AppDatabase.instance.setSetting('quietHours', value);
            },
          ),
          const SizedBox(height: 8),
          SettingsInlineRow(
            palette: palette,
            label: strings.quietStart,
            value: _formatTime(context, quietStart),
            enabled: quietHours,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: quietStart,
              );
              if (picked != null) {
                setState(() => quietStart = picked);
                AppDatabase.instance.setSetting(
                  'quietStart',
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                );
              }
            },
          ),
          const SizedBox(height: 8),
          SettingsInlineRow(
            palette: palette,
            label: strings.quietEnd,
            value: _formatTime(context, quietEnd),
            enabled: quietHours,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: quietEnd,
              );
              if (picked != null) {
                setState(() => quietEnd = picked);
                AppDatabase.instance.setSetting(
                  'quietEnd',
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({
    super.key,
    required this.palette,
    required this.strings,
  });

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool passcode = true;
  bool twoFactor = true;
  bool lastSeen = true;
  bool profilePhoto = true;
  bool readReceipts = true;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    passcode = db.getSetting<bool>('passcode', true) ?? true;
    twoFactor = db.getSetting<bool>('twoFactor', true) ?? true;
    lastSeen = db.getSetting<bool>('lastSeen', true) ?? true;
    profilePhoto = db.getSetting<bool>('profilePhoto', true) ?? true;
    readReceipts = db.getSetting<bool>('readReceipts', true) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;
    final blocked = strings.isFa
        ? const ['کاربر ناشناس ۱', 'کاربر ناشناس ۲']
        : const ['Blocked User 1', 'Blocked User 2'];
    final devices = strings.isFa
        ? const ['MacBook Pro · امروز', 'iPhone 14 · دیروز']
        : const ['MacBook Pro · Today', 'iPhone 14 · Yesterday'];

    return DetailScaffold(
      title: strings.privacyDetail,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSection(title: strings.privacy),
          SettingsSwitchRow(
            palette: palette,
            title: strings.passcode,
            subtitle: strings.isFa
                ? 'قفل با رمز یا بیومتریک'
                : 'Lock with passcode or biometrics',
            value: passcode,
            onChanged: (value) {
              setState(() => passcode = value);
              AppDatabase.instance.setSetting('passcode', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.twoFactor,
            subtitle: strings.isFa
                ? 'افزایش امنیت ورود'
                : 'Extra login security',
            value: twoFactor,
            onChanged: (value) {
              setState(() => twoFactor = value);
              AppDatabase.instance.setSetting('twoFactor', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.lastSeen,
            subtitle: strings.isFa
                ? 'نمایش آخرین بازدید'
                : 'Show last seen time',
            value: lastSeen,
            onChanged: (value) {
              setState(() => lastSeen = value);
              AppDatabase.instance.setSetting('lastSeen', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.profilePhoto,
            subtitle: strings.isFa
                ? 'نمایش عکس پروفایل'
                : 'Allow profile photo visibility',
            value: profilePhoto,
            onChanged: (value) {
              setState(() => profilePhoto = value);
              AppDatabase.instance.setSetting('profilePhoto', value);
            },
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.readReceipts,
            subtitle: strings.isFa
                ? 'نمایش خوانده‌شدن پیام'
                : 'Show read receipts',
            value: readReceipts,
            onChanged: (value) {
              setState(() => readReceipts = value);
              AppDatabase.instance.setSetting('readReceipts', value);
            },
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.blockedUsers),
          Column(
            children: blocked
                .map(
                  (name) => SettingsInlineRow(
                    palette: palette,
                    label: name,
                    value: strings.isFa ? 'رفع مسدود' : 'Unblock',
                    onTap: () {},
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.devices),
          Column(
            children: devices
                .map(
                  (name) => SettingsInlineRow(
                    palette: palette,
                    label: name,
                    value: strings.isFa ? 'خروج' : 'Sign out',
                    onTap: () {},
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({
    super.key,
    required this.palette,
    required this.strings,
  });

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String theme = 'system';
  double fontSize = 1.0;
  String bubble = 'rounded';
  String wallpaper = 'linen';
  String appIcon = 'classic';
  bool compactMode = false;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    theme = db.getSetting<String>('appearanceTheme', 'system') ?? 'system';
    fontSize = (db.getSetting<num>('fontSize', 1.0) ?? 1.0).toDouble();
    bubble = db.getSetting<String>('bubble', 'rounded') ?? 'rounded';
    wallpaper = db.getSetting<String>('wallpaper', 'linen') ?? 'linen';
    appIcon = db.getSetting<String>('appIcon', 'classic') ?? 'classic';
    compactMode = db.getSetting<bool>('compactMode', false) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;

    return DetailScaffold(
      title: strings.appearanceDetail,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSection(title: strings.theme),
          SettingsOptionRow(
            palette: palette,
            label: strings.themeSystem,
            selected: theme == 'system',
            onTap: () {
              setState(() => theme = 'system');
              AppDatabase.instance.setSetting('appearanceTheme', 'system');
            },
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.themeLight,
            selected: theme == 'light',
            onTap: () {
              setState(() => theme = 'light');
              AppDatabase.instance.setSetting('appearanceTheme', 'light');
            },
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.themeDark,
            selected: theme == 'dark',
            onTap: () {
              setState(() => theme = 'dark');
              AppDatabase.instance.setSetting('appearanceTheme', 'dark');
            },
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.fontSize),
          SettingsSliderRow(
            palette: palette,
            value: fontSize,
            min: 0.85,
            max: 1.15,
            onChanged: (value) {
              setState(() => fontSize = value);
              AppDatabase.instance.setSetting('fontSize', value);
            },
            label: strings.isFa ? 'متن' : 'Text',
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.bubbleShape),
          SettingsOptionRow(
            palette: palette,
            label: strings.bubbleRounded,
            selected: bubble == 'rounded',
            onTap: () {
              setState(() => bubble = 'rounded');
              AppDatabase.instance.setSetting('bubble', 'rounded');
            },
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.bubbleSquare,
            selected: bubble == 'square',
            onTap: () {
              setState(() => bubble = 'square');
              AppDatabase.instance.setSetting('bubble', 'square');
            },
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.wallpaper),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'کتان روشن' : 'Light linen',
            selected: wallpaper == 'linen',
            onTap: () {
              setState(() => wallpaper = 'linen');
              AppDatabase.instance.setSetting('wallpaper', 'linen');
            },
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'آبی اداری' : 'Office blue',
            selected: wallpaper == 'office',
            onTap: () {
              setState(() => wallpaper = 'office');
              AppDatabase.instance.setSetting('wallpaper', 'office');
            },
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'دودی تیره' : 'Slate dark',
            selected: wallpaper == 'slate',
            onTap: () {
              setState(() => wallpaper = 'slate');
              AppDatabase.instance.setSetting('wallpaper', 'slate');
            },
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.appIcon),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'کلاسیک' : 'Classic',
            selected: appIcon == 'classic',
            onTap: () {
              setState(() => appIcon = 'classic');
              AppDatabase.instance.setSetting('appIcon', 'classic');
            },
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'مینیمال' : 'Minimal',
            selected: appIcon == 'minimal',
            onTap: () {
              setState(() => appIcon = 'minimal');
              AppDatabase.instance.setSetting('appIcon', 'minimal');
            },
          ),
          const SizedBox(height: 16),
          SettingsSwitchRow(
            palette: palette,
            title: strings.compactMode,
            subtitle: strings.isFa
                ? 'فاصله‌های کمتر در لیست‌ها'
                : 'Tighter spacing in lists',
            value: compactMode,
            onChanged: (value) {
              setState(() => compactMode = value);
              AppDatabase.instance.setSetting('compactMode', value);
            },
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: strings.aboutDetail,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: const BigHeadLogo(size: 72)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'BigHeads',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: palette.ink),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              strings.isFa
                  ? 'پیام‌رسان رسمی برای تیم‌های حرفه‌ای'
                  : 'A formal messenger for professional teams',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
          ),
          const SizedBox(height: 16),
          DetailInfoCard(
            palette: palette,
            title: strings.version,
            value: '1.0.0',
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.build,
            value: '1001',
          ),
          const SizedBox(height: 12),
          SettingsInlineRow(
            palette: palette,
            label: strings.terms,
            value: strings.isFa ? 'مشاهده' : 'View',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          SettingsInlineRow(
            palette: palette,
            label: strings.privacyPolicy,
            value: strings.isFa ? 'مشاهده' : 'View',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          SettingsInlineRow(
            palette: palette,
            label: strings.licenses,
            value: strings.isFa ? 'مشاهده' : 'View',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final BigHeadPalette palette;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: palette.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class SettingsInlineRow extends StatelessWidget {
  const SettingsInlineRow({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    this.onTap,
    this.enabled = true,
  });

  final BigHeadPalette palette;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: enabled ? palette.ink : palette.muted),
              ),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: palette.muted, size: 18),
          ],
        ),
      ),
    );
  }
}

class SettingsOptionRow extends StatelessWidget {
  const SettingsOptionRow({
    super.key,
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final BigHeadPalette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? palette.blue : palette.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: palette.ink),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: palette.blue)
            else
              Icon(Icons.radio_button_unchecked, color: palette.muted),
          ],
        ),
      ),
    );
  }
}

class SettingsSliderRow extends StatelessWidget {
  const SettingsSliderRow({
    super.key,
    required this.palette,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
  });

  final BigHeadPalette palette;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.muted),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 6,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final account = AppDatabase.instance.currentUserNotifier.value;
    if (account == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Center(
          child: Text(
            strings.isFa ? 'حسابی فعال نیست.' : 'No active account.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.muted),
          ),
        ),
      );
    }
    final displayName = account.name.isEmpty
        ? account.email.split('@').first
        : account.name;
    final sub = account.phone.isEmpty ? account.email : account.phone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.profile,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                AccountAvatar(
                  account: account,
                  palette: palette,
                  fallbackName: displayName,
                  size: 56,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: palette.ink),
                      ),
                      Text(
                        sub,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: palette.muted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileEditScreen(
                          palette: palette,
                          strings: strings,
                          account: account,
                        ),
                      ),
                    );
                  },
                  child: Text(strings.edit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ProfileStatRow(palette: palette, strings: strings),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              account.bio.isEmpty
                  ? (strings.isFa ? 'بدون بیوگرافی' : 'No bio yet.')
                  : account.bio,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => AppDatabase.instance.logout(),
              icon: const Icon(Icons.logout),
              label: Text(strings.isFa ? 'خروج از حساب' : 'Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatRow extends StatelessWidget {
  const _ProfileStatRow({required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;
    final items = [
      _ProfileStat(label: strings.inbox, value: '${db.chatsNotifier.value.length}'),
      _ProfileStat(label: strings.contacts, value: '${db.contactsNotifier.value.length}'),
      _ProfileStat(label: strings.calls, value: '${db.callsNotifier.value.length}'),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                Text(
                  item.value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: palette.ink),
                ),
                Text(
                  item.label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProfileStat {
  _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;
}

class StatusItem {
  const StatusItem({required this.id, required this.label, required this.active});

  final String id;
  final String label;
  final bool active;
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.item,
    required this.palette,
    required this.strings,
  });

  final StatusItem item;
  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            InitialAvatar(name: item.label, palette: palette, size: 52),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.active ? palette.blue : palette.muted,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.card, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          item.label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: palette.ink),
        ),
      ],
    );
  }
}

class BigHeadPill extends StatelessWidget {
  const BigHeadPill({
    super.key,
    required this.label,
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final BigHeadPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: palette.ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.ink, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

enum BigHeadFilters { all, unread, groups, archive }

extension BigHeadFiltersLabel on BigHeadFilters {
  String label(AppStrings strings) {
    switch (this) {
      case BigHeadFilters.all:
        return strings.isFa ? 'همه' : 'All';
      case BigHeadFilters.unread:
        return strings.isFa ? 'خوانده‌نشده' : 'Unread';
      case BigHeadFilters.groups:
        return strings.isFa ? 'گروه‌ها' : 'Groups';
      case BigHeadFilters.archive:
        return strings.isFa ? 'آرشیو' : 'Archive';
    }
  }
}

enum ChatMood { primary }

class ChatItem {
  const ChatItem({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.mood,
  });

  final String id;
  final String name;
  final String message;
  final String time;
  final int unread;
  final ChatMood mood;
}

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.chat,
    required this.palette,
    required this.onTap,
  });

  final ChatItem chat;
  final BigHeadPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            InitialAvatar(name: chat.name, palette: palette, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: palette.ink),
                        ),
                      ),
                      Text(
                        chat.time,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: palette.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chat.message,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (chat.unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chat.unread.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.card),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedEntry extends StatelessWidget {
  const AnimatedEntry({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    super.key,
    required this.name,
    required this.palette,
    this.size = 48,
  });

  final String name;
  final BigHeadPalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: palette.blue, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _initials(String input) {
    final parts = input.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final first = parts.first.substring(0, 1).toUpperCase();
    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }
}

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.account,
    required this.palette,
    required this.fallbackName,
    this.size = 56,
  });

  final AccountProfile account;
  final BigHeadPalette palette;
  final String fallbackName;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (account.avatarBase64 != null && account.avatarBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(account.avatarBase64!);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
            image: DecorationImage(
              image: MemoryImage(Uint8List.fromList(bytes)),
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (_) {}
    }
    return InitialAvatar(name: fallbackName, palette: palette, size: size);
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chat,
    required this.palette,
    required this.strings,
  });

  final ChatItem chat;
  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  StreamSubscription<RemoteIncomingMessage>? _remoteMessageSub;

  @override
  void initState() {
    super.initState();
    _remoteMessageSub = RemoteApiClient.instance.messages.listen((event) {
      if (!mounted) {
        return;
      }
      if (event.fromUserId == widget.chat.id) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _remoteMessageSub?.cancel();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = AppDatabase.instance.messagesOf(widget.chat.id);
    final palette = widget.palette;
    final strings = widget.strings;

    return Scaffold(
      body: Stack(
        children: [
          BigHeadBackground(palette: widget.palette),
          SafeArea(
            child: Column(
              children: [
                DetailTopBar(
                  title: widget.chat.name,
                  subtitle: strings.activeNow,
                  palette: widget.palette,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            strings.isFa
                                ? 'هنوز پیامی ارسال نشده است.'
                                : 'No messages yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: palette.muted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: messages.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return MessageBubble(message: message, palette: palette);
                          },
                        ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: palette.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              hintText: strings.typeMessage,
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: palette.muted),
                            ),
                            style: TextStyle(color: palette.ink),
                          ),
                        ),
                        InkWell(
                          onTap: _sendMessage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: palette.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              color: palette.card,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    AppDatabase.instance.sendMessage(widget.chat.id, text, fromMe: true);
    messageController.clear();
    setState(() {});
  }
}

class DetailTopBar extends StatelessWidget {
  const DetailTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final BigHeadPalette palette;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          BigHeadIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            palette: palette,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: palette.ink),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
          BigHeadIconButton(
            icon: Icons.call_outlined,
            palette: palette,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          BigHeadIconButton(
            icon: Icons.more_horiz,
            palette: palette,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class Message {
  const Message({required this.fromMe, required this.text, required this.time});

  final bool fromMe;
  final String text;
  final String time;
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.palette});

  final Message message;
  final BigHeadPalette palette;

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.fromMe ? palette.blue : palette.card;
    final textColor = message.fromMe ? palette.card : palette.ink;
    final border = message.fromMe
        ? null
        : Border.all(color: palette.border);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(14),
            border: border,
          ),
          child: Text(
            message.text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: textColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message.time,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: palette.muted),
        ),
      ],
    );
  }
}

class ListTileCard extends StatelessWidget {
  const ListTileCard({
    super.key,
    required this.palette,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final BigHeadPalette palette;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: palette.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.muted),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.palette,
    required this.strings,
  });

  final Contact contact;
  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    void showMessage(String text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    return DetailScaffold(
      title: strings.contactDetails,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: InitialAvatar(
              name: contact.name,
              palette: palette,
              size: 72,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              contact.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: palette.ink),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${contact.role} • ${contact.company}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
          ),
          const SizedBox(height: 16),
          DetailActionRow(
            palette: palette,
            actions: [
              DetailAction(
                label: strings.message,
                icon: Icons.chat_bubble_outline,
                onTap: () {
                  final chat = AppDatabase.instance.createOrGetChat(contact, strings);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(
                        chat: chat,
                        palette: palette,
                        strings: strings,
                      ),
                    ),
                  );
                },
              ),
              DetailAction(
                label: strings.voiceCall,
                icon: Icons.call_outlined,
                onTap: () {
                  AppDatabase.instance.logCall(contact, incoming: false);
                  showMessage(strings.isFa
                      ? 'تماس صوتی ثبت شد.'
                      : 'Voice call logged.');
                },
              ),
              DetailAction(
                label: strings.videoCall,
                icon: Icons.videocam_outlined,
                onTap: () {
                  AppDatabase.instance.logCall(contact, incoming: false);
                  showMessage(strings.isFa
                      ? 'تماس تصویری ثبت شد.'
                      : 'Video call logged.');
                },
              ),
              DetailAction(
                label: strings.email,
                icon: Icons.mail_outline,
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: contact.email));
                  showMessage(strings.isFa
                      ? 'ایمیل کپی شد.'
                      : 'Email copied to clipboard.');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          DetailInfoCard(
            palette: palette,
            title: strings.phone,
            value: contact.phone,
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.email,
            value: contact.email,
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.isFa ? 'محل' : 'Location',
            value: contact.location,
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.isFa ? 'آخرین فعالیت' : 'Last active',
            value: contact.lastSeen,
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.sharedMedia,
            value: strings.isFa ? '۱۸ فایل' : '18 files',
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.block,
            value: strings.isFa ? 'مسدودسازی' : 'Block user',
            emphasis: true,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showMessage(strings.isFa
                    ? 'مخاطب مسدود شد.'
                    : 'Contact blocked.');
                AppDatabase.instance.blockContact(contact);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.block),
              label: Text(strings.block),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.isFa ? 'برچسب‌ها' : 'Tags',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contact.tags
                .map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: palette.ink),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            strings.isFa ? 'یادداشت داخلی' : 'Internal note',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              contact.notes,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class NewContactScreen extends StatefulWidget {
  const NewContactScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final name = TextEditingController();
  final role = TextEditingController();
  final company = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final location = TextEditingController();
  final tags = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    role.dispose();
    company.dispose();
    phone.dispose();
    email.dispose();
    location.dispose();
    tags.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;

    return DetailScaffold(
      title: strings.newContact,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'نام کامل' : 'Full name',
            controller: name,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'سمت' : 'Role',
            controller: role,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'شرکت' : 'Company',
            controller: company,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.phone,
            controller: phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.email,
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'موقعیت' : 'Location',
            controller: location,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'برچسب‌ها (با کاما)' : 'Tags (comma separated)',
            controller: tags,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'یادداشت' : 'Notes',
            controller: notes,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveContact,
                  child: Text(strings.add),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveContact() {
    final strings = widget.strings;
    final safeName = name.text.trim();
    final safeRole = role.text.trim();
    final safeCompany = company.text.trim();
    final safePhone = phone.text.trim();

    if (safeName.isEmpty || safePhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isFa
                ? 'نام و شماره تماس اجباری است.'
                : 'Name and phone are required.',
          ),
        ),
      );
      return;
    }

    if (AppDatabase.instance.contactExists(safePhone, email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isFa
                ? 'این مخاطب از قبل وجود دارد.'
                : 'This contact already exists.',
          ),
        ),
      );
      return;
    }

    final parsedTags = tags.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final newContact = Contact(
      name: safeName,
      role: safeRole.isEmpty ? (strings.isFa ? 'بدون سمت' : 'No role') : safeRole,
      company: safeCompany.isEmpty
          ? (strings.isFa ? 'بدون شرکت' : 'No company')
          : safeCompany,
      status: strings.isFa ? 'جدید' : 'New',
      phone: safePhone,
      email: email.text.trim(),
      location: location.text.trim().isEmpty
          ? (strings.isFa ? 'نامشخص' : 'Unknown')
          : location.text.trim(),
      lastSeen: strings.isFa ? 'همین الان' : 'Just now',
      tags: parsedTags.isEmpty
          ? [strings.isFa ? 'مخاطب' : 'Contact']
          : parsedTags,
      notes: notes.text.trim(),
    );

    AppDatabase.instance.addContact(newContact);
    Navigator.of(context).pop(true);
  }
}

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final targetController = TextEditingController();

  @override
  void dispose() {
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;
    final invites = AppDatabase.instance.invitesNotifier.value;
    const inviteLink = 'https://bigheads.app/invite/AX92B';

    return DetailScaffold(
      title: strings.invite,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.isFa
                ? 'با ارسال لینک زیر همکاران را دعوت کنید.'
                : 'Invite teammates with the link below.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.muted),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    inviteLink,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.ink),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: inviteLink));
                    AppDatabase.instance.addInvite(inviteLink);
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.isFa
                              ? 'لینک دعوت کپی شد.'
                              : 'Invite link copied.'),
                        ),
                      );
                    }
                  },
                  child: Text(strings.shareLink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.isFa ? 'شماره یا ایمیل' : 'Phone or email',
            controller: targetController,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final target = targetController.text.trim();
                if (target.isEmpty) {
                  return;
                }
                AppDatabase.instance.addInvite(target);
                targetController.clear();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      strings.isFa ? 'دعوت ارسال شد.' : 'Invitation sent.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send_outlined),
              label: Text(strings.invite),
            ),
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.isFa ? 'دعوت‌های اخیر' : 'Recent invites'),
          if (invites.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strings.isFa ? 'دعوتی ثبت نشده است.' : 'No invites yet.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: palette.muted),
              ),
            ),
          ...invites.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SettingsInlineRow(
                palette: palette,
                label: entry,
                value: strings.isFa ? 'ارسال مجدد' : 'Resend',
                onTap: () {
                  AppDatabase.instance.addInvite(entry);
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Group {
  const Group({
    required this.name,
    required this.members,
    required this.description,
  });

  final String name;
  final List<String> members;
  final String description;
}

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key, required this.palette, required this.strings});

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final membersController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;
    final groups = AppDatabase.instance.groupsNotifier.value;

    return DetailScaffold(
      title: strings.groups,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.isFa ? 'گروه‌های کاری' : 'Work groups',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: palette.ink),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreateGroupDialog(context),
                icon: const Icon(Icons.add),
                label: Text(strings.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (groups.isEmpty)
            Text(
              strings.isFa
                  ? 'هنوز گروهی ساخته نشده است.'
                  : 'No groups created yet.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            ),
          ...groups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTileCard(
                palette: palette,
                leading: InitialAvatar(name: group.name, palette: palette),
                title: group.name,
                subtitle: '${group.members.length} ${strings.members}',
                trailing: Icon(Icons.chevron_right, color: palette.muted),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GroupDetailScreen(
                        group: group,
                        palette: palette,
                        strings: strings,
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final palette = widget.palette;
    final strings = widget.strings;
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(strings.groups),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _FormFieldCard(
                  palette: palette,
                  label: strings.isFa ? 'نام گروه' : 'Group name',
                  controller: nameController,
                ),
                const SizedBox(height: 8),
                _FormFieldCard(
                  palette: palette,
                  label: strings.description,
                  controller: descController,
                ),
                const SizedBox(height: 8),
                _FormFieldCard(
                  palette: palette,
                  label: strings.isFa ? 'اعضا (با کاما)' : 'Members (comma separated)',
                  controller: membersController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                final members = membersController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                AppDatabase.instance.addGroup(
                  name: name,
                  description: descController.text.trim().isEmpty
                      ? (strings.isFa ? 'بدون توضیح' : 'No description')
                      : descController.text.trim(),
                  members: members,
                );
                nameController.clear();
                descController.clear();
                membersController.clear();
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text(strings.add),
            ),
          ],
        );
      },
    );
  }
}

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.palette,
    required this.strings,
  });

  final Group group;
  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Group group;
  final memberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    group = widget.group;
  }

  @override
  void dispose() {
    memberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: widget.strings.groupDetails,
      palette: widget.palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: InitialAvatar(name: group.name, palette: widget.palette, size: 72)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              group.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: widget.palette.ink),
            ),
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: widget.palette,
            title: widget.strings.description,
            value: group.description,
          ),
          const SizedBox(height: 12),
          SettingsSection(title: widget.strings.members),
          ...group.members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SettingsInlineRow(
                palette: widget.palette,
                label: member,
                value: widget.strings.isFa ? 'کپی' : 'Copy',
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: member));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.strings.isFa
                            ? 'نام عضو کپی شد.'
                            : 'Member name copied.'),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          SettingsInlineRow(
            palette: widget.palette,
            label: widget.strings.addMember,
            value: widget.strings.add,
            onTap: _addMember,
          ),
        ],
      ),
    );
  }

  Future<void> _addMember() async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(widget.strings.addMember),
          content: _FormFieldCard(
            palette: widget.palette,
            label: widget.strings.isFa ? 'نام عضو' : 'Member name',
            controller: memberController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.strings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final member = memberController.text.trim();
                if (member.isEmpty) {
                  return;
                }
                final updated = AppDatabase.instance.addMemberToGroup(group, member);
                memberController.clear();
                Navigator.of(context).pop();
                setState(() {
                  group = updated;
                });
              },
              child: Text(widget.strings.add),
            ),
          ],
        );
      },
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({
    required this.palette,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final BigHeadPalette palette;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.muted),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(border: InputBorder.none),
            style: TextStyle(color: palette.ink),
          ),
        ],
      ),
    );
  }
}

class CallDetailScreen extends StatelessWidget {
  const CallDetailScreen({
    super.key,
    required this.item,
    required this.palette,
    required this.strings,
  });

  final CallItem item;
  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: strings.callDetails,
      palette: palette,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: InitialAvatar(name: item.name, palette: palette, size: 72)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              item.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: palette.ink),
            ),
          ),
          const SizedBox(height: 16),
          DetailInfoCard(
            palette: palette,
            title: strings.isFa ? 'زمان تماس' : 'Call time',
            value: item.time,
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.isFa ? 'نوع تماس' : 'Call type',
            value: item.incoming
                ? (strings.isFa ? 'ورودی' : 'Incoming')
                : (strings.isFa ? 'خروجی' : 'Outgoing'),
          ),
          const SizedBox(height: 12),
          DetailInfoCard(
            palette: palette,
            title: strings.isFa ? 'مدت تماس' : 'Duration',
            value: strings.isFa ? '۰۴:۳۲ دقیقه' : '04:32 min',
          ),
          const SizedBox(height: 16),
          DetailActionRow(
            palette: palette,
            actions: [
              DetailAction(
                label: strings.voiceCall,
                icon: Icons.call_outlined,
                onTap: () {},
              ),
              DetailAction(
                label: strings.message,
                icon: Icons.chat_bubble_outline,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    super.key,
    required this.palette,
    required this.strings,
    required this.account,
  });

  final BigHeadPalette palette;
  final AppStrings strings;
  final AccountProfile account;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController name;
  late final TextEditingController bio;
  late final TextEditingController phone;
  late final TextEditingController email;
  String? avatarBase64;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.account.name);
    bio = TextEditingController(text: widget.account.bio);
    phone = TextEditingController(text: widget.account.phone);
    email = TextEditingController(text: widget.account.email);
    avatarBase64 = widget.account.avatarBase64;
  }

  @override
  void dispose() {
    name.dispose();
    bio.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final strings = widget.strings;
    final preview = AccountProfile(
      email: email.text,
      name: name.text,
      phone: phone.text,
      bio: bio.text,
      qrCode: widget.account.qrCode,
      avatarBase64: avatarBase64,
    );

    return DetailScaffold(
      title: strings.profileEdit,
      palette: palette,
      body: Column(
        children: [
          AccountAvatar(
            account: preview,
            palette: palette,
            fallbackName: name.text.isEmpty ? email.text : name.text,
            size: 72,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final picked = await AppPlatformService.pickImageBase64();
              if (picked != null && picked.isNotEmpty) {
                setState(() => avatarBase64 = picked);
              }
            },
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(strings.isFa ? 'انتخاب عکس' : 'Pick photo'),
          ),
          const SizedBox(height: 16),
          _FormFieldCard(
            palette: palette,
            label: strings.username,
            controller: name,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.bio,
            controller: bio,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.email,
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _FormFieldCard(
            palette: palette,
            label: strings.phone,
            controller: phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AppDatabase.instance.updateCurrentProfile(
                      email: email.text.trim(),
                      name: name.text.trim(),
                      phone: phone.text.trim(),
                      bio: bio.text.trim(),
                      avatarBase64: avatarBase64,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(strings.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    required this.palette,
    required this.body,
  });

  final String title;
  final BigHeadPalette palette;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BigHeadBackground(palette: palette),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      BigHeadIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        palette: palette,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: palette.ink),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsCenterScreen extends StatelessWidget {
  const NotificationsCenterScreen({
    super.key,
    required this.palette,
    required this.strings,
  });

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final notifications = AppDatabase.instance.callsNotifier.value
        .take(10)
        .map((c) => '${c.name} • ${c.time}')
        .toList();
    return DetailScaffold(
      title: strings.notifications,
      palette: palette,
      body: notifications.isEmpty
          ? Text(
              strings.isFa ? 'اعلانی وجود ندارد.' : 'No notifications.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.muted),
            )
          : Column(
              children: notifications
                  .map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SettingsInlineRow(
                        palette: palette,
                        label: n,
                        value: strings.isFa ? 'مشاهده' : 'Open',
                        onTap: () {},
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({
    super.key,
    required this.palette,
    required this.strings,
  });

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  final scanController = TextEditingController();

  @override
  void dispose() {
    scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppDatabase.instance.currentUserNotifier.value;
    final p = widget.palette;
    final s = widget.strings;
    if (user == null) {
      return DetailScaffold(
        title: 'QR',
        palette: p,
        body: Text(
          s.isFa ? 'کاربر فعال نیست.' : 'No active user.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return DetailScaffold(
      title: 'QR',
      palette: p,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _PseudoQrCard(code: user.qrCode, palette: p)),
          const SizedBox(height: 10),
          Center(
            child: SelectableText(
              user.qrCode,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: p.muted),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: user.qrCode));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.isFa ? 'کد QR کپی شد.' : 'QR code copied.',
                      ),
                    ),
                  );
                }
              },
              child: Text(s.isFa ? 'کپی کد' : 'Copy code'),
            ),
          ),
          const SizedBox(height: 14),
          _FormFieldCard(
            palette: p,
            label: s.isFa ? 'کد طرف مقابل را وارد کنید' : 'Enter other user QR code',
            controller: scanController,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final found = AppDatabase.instance.findAccountByQr(scanController.text);
                if (found == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.isFa ? 'کاربری با این کد یافت نشد.' : 'No user found for this code.',
                      ),
                    ),
                  );
                  return;
                }
                if (found.email == user.email) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.isFa ? 'این کد متعلق به خود شماست.' : 'This is your own code.',
                      ),
                    ),
                  );
                  return;
                }
                final name = found.name.isEmpty ? found.email.split('@').first : found.name;
                final contact = Contact(
                  name: name,
                  role: s.isFa ? 'کاربر بیگ هدز' : 'BigHeads user',
                  company: 'BigHeads',
                  status: s.online,
                  phone: found.phone,
                  email: found.email,
                  location: '',
                  lastSeen: s.isFa ? 'اکنون' : 'Now',
                  tags: const ['QR'],
                  notes: '',
                );
                if (!AppDatabase.instance.contactExists(contact.phone, contact.email)) {
                  AppDatabase.instance.addContact(contact);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.isFa ? 'مخاطب اضافه شد.' : 'Contact added.',
                    ),
                  ),
                );
              },
              child: Text(s.isFa ? 'افزودن مخاطب با QR' : 'Add contact by QR'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PseudoQrCard extends StatelessWidget {
  const _PseudoQrCard({required this.code, required this.palette});

  final String code;
  final BigHeadPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: CustomPaint(
        painter: _PseudoQrPainter(code, palette),
      ),
    );
  }
}

class _PseudoQrPainter extends CustomPainter {
  _PseudoQrPainter(this.code, this.palette);
  final String code;
  final BigHeadPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final bytes = utf8.encode(code);
    const n = 21;
    final cell = size.width / n;
    final paint = Paint()..color = palette.ink;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final idx = (x + y * n) % bytes.length;
        final bit = ((bytes[idx] + x * 7 + y * 13) % 2) == 0;
        if (bit) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell - 0.6, cell - 0.6),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PseudoQrPainter oldDelegate) {
    return oldDelegate.code != code;
  }
}

class DetailActionRow extends StatelessWidget {
  const DetailActionRow({required this.palette, required this.actions});

  final BigHeadPalette palette;
  final List<DetailAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  children: [
                    Icon(action.icon, color: palette.blue),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: palette.ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DetailAction {
  DetailAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class DetailInfoCard extends StatelessWidget {
  const DetailInfoCard({
    super.key,
    required this.palette,
    required this.title,
    required this.value,
    this.emphasis = false,
  });

  final BigHeadPalette palette;
  final String title;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: emphasis ? Colors.redAccent : palette.ink),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: palette.muted),
        ],
      ),
    );
  }
}
