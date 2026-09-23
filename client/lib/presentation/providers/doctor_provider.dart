import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';

class DoctorState {
  final List<DoctorEntity> doctors;
  final List<ConsultationEntity> consultations;
  final bool isLoading;
  final String? errorMessage;

  const DoctorState({
    this.doctors = const [],
    this.consultations = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DoctorState copyWith({
    List<DoctorEntity>? doctors,
    List<ConsultationEntity>? consultations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DoctorState(
      doctors: doctors ?? this.doctors,
      consultations: consultations ?? this.consultations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DoctorNotifier extends StateNotifier<DoctorState> {
  final Ref _ref;

  DoctorNotifier(this._ref) : super(const DoctorState()) {
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(repositoryProvider);
      final list = await repo.getDoctors();
      state = state.copyWith(isLoading: false, doctors: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<ConsultationEntity?> bookConsultation({
    required String doctorId,
    required DateTime scheduledAt,
    required String consultationType,
    String? notes,
  }) async {
    try {
      final repo = _ref.read(repositoryProvider);
      final res = await repo.bookConsultation(
        doctorId: doctorId,
        scheduledAt: scheduledAt,
        consultationType: consultationType,
        notes: notes,
      );
      state = state.copyWith(consultations: [res, ...state.consultations]);
      return res;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
}

final doctorProvider = StateNotifierProvider<DoctorNotifier, DoctorState>((ref) {
  return DoctorNotifier(ref);
});
