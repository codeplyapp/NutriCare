import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';

class NutriMateState {
  final List<ChatMessageEntity> messages;
  final bool isThinking;
  final String? errorMessage;

  const NutriMateState({
    this.messages = const [],
    this.isThinking = false,
    this.errorMessage,
  });

  NutriMateState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isThinking,
    String? errorMessage,
  }) {
    return NutriMateState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      errorMessage: errorMessage,
    );
  }
}

class NutriMateNotifier extends StateNotifier<NutriMateState> {
  final Ref _ref;

  NutriMateNotifier(this._ref)
      : super(NutriMateState(messages: [
          ChatMessageEntity(
            id: 'welcome-msg',
            sender: 'nutri_mate',
            message:
                'Halo! Saya Nutri Mate, asisten AI gizi personal Anda. Anda bisa menanyakan saran menu sehat, porsi gizi seimbang, atau tips memenuhi target hidrasi harian.',
            disclaimer:
                'Informasi ini bersifat edukatif dan bukan pengganti saran dokter spesialis gizi klinis.',
            isEscalated: false,
            sentAt: DateTime.now(),
          )
        ]));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageEntity(
      id: DateTime.now().toIso8601String(),
      sender: 'user',
      message: text.trim(),
      isEscalated: false,
      sentAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      errorMessage: null,
    );

    try {
      final repo = _ref.read(repositoryProvider);
      final reply = await repo.sendNutriMateChat(text.trim());
      state = state.copyWith(
        messages: [...state.messages, reply],
        isThinking: false,
      );
    } catch (e) {
      state = state.copyWith(
        isThinking: false,
        errorMessage: 'Gagal mendapatkan respons AI: $e',
      );
    }
  }
}

final nutriMateProvider = StateNotifierProvider<NutriMateNotifier, NutriMateState>((ref) {
  return NutriMateNotifier(ref);
});
