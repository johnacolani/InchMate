import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoOverlay extends StatefulWidget {
  const AppInfoOverlay({super.key});

  @override
  State<AppInfoOverlay> createState() => _AppInfoOverlayState();
}

class _AppInfoOverlayState extends State<AppInfoOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  static const String _appVersion = '1.1.1';
  static const String _contactEmail = 'info@4ideasapp.com';
  static const String _websiteUrl = 'https://www.4ideasapp.com/';

  Future<void> _launchEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      query: 'subject=InchMate Support',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchWebsite() async {
    await launchUrl(Uri.parse(_websiteUrl),
        mode: LaunchMode.externalApplication);
  }

  final List<_HelpItem> _helpItems = const [
    _HelpItem(
      icon: Icons.pin,
      title: 'Enter fractions',
      description:
          'Tap the fraction buttons (1/2, 1/4, 3/8, …) or type whole numbers to build a measurement.',
    ),
    _HelpItem(
      icon: Icons.calculate,
      title: 'Calculate',
      description:
          'Use +, −, ×, ÷ and parentheses, then press = to evaluate your expression.',
    ),
    _HelpItem(
      icon: Icons.content_copy,
      title: 'Copy & paste',
      description:
          'Tap the copy icon beside a result, then use the paste button in the top bar to reuse it. You can paste values like 120 7/8 or 3/4.',
    ),
    _HelpItem(
      icon: Icons.straighten,
      title: 'Read the results',
      description:
          'Use the left result for linear measurements and the right result for square footage. The foot and inch markers are shown as ’ and ".',
    ),
    _HelpItem(
      icon: Icons.backspace,
      title: 'Edit & clear',
      description:
          'Use ⌫ to delete the last entry and C to clear everything and start over.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        body: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _widthAnimation,
              builder: (context, child) {
                return Container(
                  width: size.width * _widthAnimation.value,
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.85,
                    maxHeight: size.height * 0.8,
                  ),
                  margin: EdgeInsets.only(top: 50.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191818),
                    borderRadius: BorderRadius.all(Radius.circular(20.r)),
                    border: const GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                      ),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: child,
                  ),
                );
              },
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 6.h),
          child: Column(
            children: [
              Text(
                'InchMate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'A fraction calculator for measurements',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade800, height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: _helpItems.length,
            itemBuilder: (context, index) => _HelpTile(item: _helpItems[index]),
          ),
        ),
        Divider(color: Colors.grey.shade800, height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterLink(
                    icon: Icons.mail_outline,
                    label: 'Contact Support',
                    onTap: _launchEmail,
                  ),
                  SizedBox(width: 20.w),
                  _FooterLink(
                    icon: Icons.language,
                    label: 'Website',
                    onTap: _launchWebsite,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Version $_appVersion',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _HelpTile extends StatelessWidget {
  final _HelpItem item;

  const _HelpTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(item.icon, color: Colors.white, size: 16.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10.sp,
                    height: 1.3,
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
