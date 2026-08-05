import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inch_mate/features/splash_feature/presentation/bloc/splash_event.dart';
import 'package:inch_mate/features/splash_feature/presentation/bloc/splash_state.dart';

class SplashBloc extends Bloc <SplashEvent, SplashState> {
  SplashBloc() :super(SplashInitial()) {
    
    on<StartSplash>((event, emit) async {
      await Future.delayed(Duration(seconds: 3));
      emit(SplashCompleted());
    });
  }
}