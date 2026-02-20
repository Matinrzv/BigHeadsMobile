import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BigHeadApp());
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

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setLanguage(AppLanguage language) {
    setState(() {
      _language = language;
    });
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
      home: HomeShell(
        themeMode: _themeMode,
        onThemeChanged: _toggleTheme,
        language: _language,
        onLanguageChanged: _setLanguage,
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
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

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
                  onQrTap: () {},
                  onNotifyTap: () {},
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
            color: palette.blue.withOpacity(0.06),
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
                            MaterialPageRoute(
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
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  final ValueNotifier<List<Contact>> contactsNotifier = ValueNotifier<List<Contact>>([]);
  final ValueNotifier<List<ChatItem>> chatsNotifier = ValueNotifier<List<ChatItem>>([]);
  final ValueNotifier<List<CallItem>> callsNotifier = ValueNotifier<List<CallItem>>([]);
  final ValueNotifier<List<Group>> groupsNotifier = ValueNotifier<List<Group>>([]);
  final ValueNotifier<List<String>> invitesNotifier = ValueNotifier<List<String>>([]);
  final Map<String, List<Message>> _messagesByChatId = <String, List<Message>>{};

  final ValueNotifier<Map<String, Object>> settingsTable =
      ValueNotifier<Map<String, Object>>({
    'darkMode': false,
    'language': 'en',
    'messagePreview': true,
    'sound': true,
    'vibration': true,
  });

  void addContact(Contact contact) {
    final updated = List<Contact>.from(contactsNotifier.value)..insert(0, contact);
    contactsNotifier.value = updated;
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
    return chat;
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
  }

  CallItem logCall(Contact contact, {required bool incoming}) {
    final call = CallItem(name: contact.name, time: _nowLabel(), incoming: incoming);
    final updated = List<CallItem>.from(callsNotifier.value)..insert(0, call);
    callsNotifier.value = updated;
    return call;
  }

  void addInvite(String target) {
    final sanitized = target.trim();
    if (sanitized.isEmpty) {
      return;
    }
    final updated = List<String>.from(invitesNotifier.value)..insert(0, sanitized);
    invitesNotifier.value = updated;
  }

  Group addGroup({
    required String name,
    required String description,
    required List<String> members,
  }) {
    final group = Group(name: name, members: members, description: description);
    final updated = List<Group>.from(groupsNotifier.value)..insert(0, group);
    groupsNotifier.value = updated;
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
    }
    return updatedGroup;
  }

  void blockContact(Contact contact) {
    contactsNotifier.value =
        contactsNotifier.value.where((c) => c.phone != contact.phone).toList();
    final chatId = _chatIdFromContact(contact);
    chatsNotifier.value = chatsNotifier.value.where((c) => c.id != chatId).toList();
    _messagesByChatId.remove(chatId);
  }

  String _chatIdFromContact(Contact contact) {
    return contact.phone.replaceAll(' ', '').replaceAll('+', '');
  }

  String _nowLabel() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
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
                      MaterialPageRoute(
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
                      MaterialPageRoute(
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
                      MaterialPageRoute(
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
      MaterialPageRoute(
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
                color: palette.blue.withOpacity(0.1),
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
                            MaterialPageRoute(
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
                MaterialPageRoute(
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
                MaterialPageRoute(
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
                MaterialPageRoute(
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
                MaterialPageRoute(
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
                MaterialPageRoute(
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
                color: palette.blue.withOpacity(0.1),
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
            onChanged: (value) => setState(() => messagePreview = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.sound,
            subtitle: strings.isFa ? 'پخش صدای اعلان' : 'Play notification sounds',
            value: sound,
            onChanged: (value) => setState(() => sound = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.vibration,
            subtitle: strings.isFa ? 'ویبره برای اعلان‌ها' : 'Vibrate on alerts',
            value: vibration,
            onChanged: (value) => setState(() => vibration = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.callAlerts,
            subtitle: strings.isFa ? 'هشدار برای تماس‌ها' : 'Alerts for calls',
            value: callAlerts,
            onChanged: (value) => setState(() => callAlerts = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.mentionAlerts,
            subtitle: strings.isFa
                ? 'فقط زمانی که منشن شوید'
                : 'Only when you are mentioned',
            value: mentionAlerts,
            onChanged: (value) => setState(() => mentionAlerts = value),
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
            onChanged: (value) => setState(() => quietHours = value),
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
            onChanged: (value) => setState(() => passcode = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.twoFactor,
            subtitle: strings.isFa
                ? 'افزایش امنیت ورود'
                : 'Extra login security',
            value: twoFactor,
            onChanged: (value) => setState(() => twoFactor = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.lastSeen,
            subtitle: strings.isFa
                ? 'نمایش آخرین بازدید'
                : 'Show last seen time',
            value: lastSeen,
            onChanged: (value) => setState(() => lastSeen = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.profilePhoto,
            subtitle: strings.isFa
                ? 'نمایش عکس پروفایل'
                : 'Allow profile photo visibility',
            value: profilePhoto,
            onChanged: (value) => setState(() => profilePhoto = value),
          ),
          SettingsSwitchRow(
            palette: palette,
            title: strings.readReceipts,
            subtitle: strings.isFa
                ? 'نمایش خوانده‌شدن پیام'
                : 'Show read receipts',
            value: readReceipts,
            onChanged: (value) => setState(() => readReceipts = value),
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
            onTap: () => setState(() => theme = 'system'),
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.themeLight,
            selected: theme == 'light',
            onTap: () => setState(() => theme = 'light'),
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.themeDark,
            selected: theme == 'dark',
            onTap: () => setState(() => theme = 'dark'),
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.fontSize),
          SettingsSliderRow(
            palette: palette,
            value: fontSize,
            min: 0.85,
            max: 1.15,
            onChanged: (value) => setState(() => fontSize = value),
            label: strings.isFa ? 'متن' : 'Text',
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.bubbleShape),
          SettingsOptionRow(
            palette: palette,
            label: strings.bubbleRounded,
            selected: bubble == 'rounded',
            onTap: () => setState(() => bubble = 'rounded'),
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.bubbleSquare,
            selected: bubble == 'square',
            onTap: () => setState(() => bubble = 'square'),
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.wallpaper),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'کتان روشن' : 'Light linen',
            selected: wallpaper == 'linen',
            onTap: () => setState(() => wallpaper = 'linen'),
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'آبی اداری' : 'Office blue',
            selected: wallpaper == 'office',
            onTap: () => setState(() => wallpaper = 'office'),
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'دودی تیره' : 'Slate dark',
            selected: wallpaper == 'slate',
            onTap: () => setState(() => wallpaper = 'slate'),
          ),
          const SizedBox(height: 16),
          SettingsSection(title: strings.appIcon),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'کلاسیک' : 'Classic',
            selected: appIcon == 'classic',
            onTap: () => setState(() => appIcon = 'classic'),
          ),
          SettingsOptionRow(
            palette: palette,
            label: strings.isFa ? 'مینیمال' : 'Minimal',
            selected: appIcon == 'minimal',
            onTap: () => setState(() => appIcon = 'minimal'),
          ),
          const SizedBox(height: 16),
          SettingsSwitchRow(
            palette: palette,
            title: strings.compactMode,
            subtitle: strings.isFa
                ? 'فاصله‌های کمتر در لیست‌ها'
                : 'Tighter spacing in lists',
            value: compactMode,
            onChanged: (value) => setState(() => compactMode = value),
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
                InitialAvatar(name: 'Matin R.', palette: palette, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matin R.',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: palette.ink),
                      ),
                      Text(
                        '@bighead',
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
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(
                          palette: palette,
                          strings: strings,
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
    final items = [
      _ProfileStat(label: strings.inbox, value: '128'),
      _ProfileStat(label: strings.contacts, value: '74'),
      _ProfileStat(label: strings.calls, value: '31'),
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
        color: palette.blue.withOpacity(0.12),
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

  @override
  void dispose() {
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
                    MaterialPageRoute(
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
                    MaterialPageRoute(
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

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({
    super.key,
    required this.palette,
    required this.strings,
  });

  final BigHeadPalette palette;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: strings.profileEdit,
      palette: palette,
      body: Column(
        children: [
          InitialAvatar(name: 'Matin R.', palette: palette, size: 72),
          const SizedBox(height: 16),
          _EditField(palette: palette, label: strings.username, value: '@bighead'),
          const SizedBox(height: 12),
          _EditField(palette: palette, label: strings.bio, value: strings.isFa
              ? 'مدیر محصول و طراح تجربه کاربری'
              : 'Product manager and UX lead'),
          const SizedBox(height: 12),
          _EditField(palette: palette, label: strings.email, value: 'matin@bighead.app'),
          const SizedBox(height: 12),
          _EditField(palette: palette, label: strings.phone, value: '+98 912 111 1111'),
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
                  onPressed: () => Navigator.of(context).pop(),
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

class _EditField extends StatelessWidget {
  const _EditField({
    required this.palette,
    required this.label,
    required this.value,
  });

  final BigHeadPalette palette;
  final String label;
  final String value;

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
                  label,
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
                      ?.copyWith(color: palette.ink),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: palette.muted),
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
