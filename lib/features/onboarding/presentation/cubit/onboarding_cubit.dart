import 'package:flutter_bloc/flutter_bloc.dart';

/// Menyimpan indeks halaman onboarding yang sedang tampil.
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit({this.pageCount = 3}) : super(0) {
    if (pageCount < 1) {
      throw ArgumentError.value(pageCount, 'pageCount', 'Must be at least 1.');
    }
  }

  final int pageCount;

  bool get isLastPage => state == pageCount - 1;

  void setPage(int index) {
    emit(index.clamp(0, pageCount - 1).toInt());
  }

  void nextPage() => setPage(state + 1);

  void previousPage() => setPage(state - 1);
}
