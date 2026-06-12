import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';  // Import Lottie package
import 'package:handi_calc/features/splash_feature/presentation/bloc/splash_bloc.dart';
import 'package:handi_calc/features/splash_feature/presentation/bloc/splash_event.dart';
import 'package:new_version_plus/new_version_plus.dart';

import '../../../calculator/presentation/screens/fraction_calculator_screen.dart';
import '../bloc/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionAndStartSplash();
    });

  }
  Future<void> _checkVersionAndStartSplash() async {
    final newVersion = NewVersionPlus(
      iOSId: '6742278209', // Add your iOS App ID here (e.g., 'id123456789')
      androidId: 'com.johncolani.fractioflow',
    );

    try {
      final status = await newVersion.getVersionStatus();
      if (status != null) {
        print("Local Version: ${status.localVersion}");
        print("Store Version: ${status.storeVersion}");
        print("Can Update: ${status.canUpdate}");

        if (status.canUpdate) {
          newVersion.showUpdateDialog(
            context: context,
            versionStatus: status,
            dialogTitle: 'Update Available',
            dialogText:
            'A new version (${status.storeVersion}) is available. Current version is ${status.localVersion}.',
            updateButtonText: 'Update Now',
            dismissButtonText: 'Later',
            allowDismissal: true,
            dismissAction: () {
              Navigator.of(context).pop(); // Dismiss dialog
              context.read<SplashBloc>().add(StartSplash()); // Start splash logic
            },
          );
        } else {
          // No update, start splash immediately
          context.read<SplashBloc>().add(StartSplash());
        }
      } else {
        print("Unable to fetch version status");
        context.read<SplashBloc>().add(StartSplash()); // Proceed anyway
      }
    } catch (e) {
      print("Error checking version: $e");
      context.read<SplashBloc>().add(StartSplash()); // Proceed on error
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => FractionCalculatorScreen()));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF191818FF),
        body: Center(
          child: SizedBox(
            width: 250.w,
            child: Lottie.asset(
              'assets/images/splash.json', // Path to your Lottie JSON
              fit: BoxFit.cover,
              repeat: true, // Loop animation
            ),
          ),
        ),
      ),
    );
  }
}
