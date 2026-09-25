import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricare/domain/entities/entities.dart';

/// Service wrapper untuk Firebase Authentication di NutriCare
class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  FirebaseAuth get auth => _auth;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register dengan Email & Password
  Future<UserEntity> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name.trim());
        // Kirim email verifikasi otomatis
        await user.sendEmailVerification();
      }

      return UserEntity(
        id: user?.uid ?? 'uid-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: email.trim(),
        phone: phone,
        hasProfile: false,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal melakukan pendaftaran: ${e.toString()}');
    }
  }

  /// Login dengan Email & Password
  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Pengguna tidak ditemukan.');
      }

      // Reload data user untuk mendapatkan status emailVerified terbaru
      await user.reload();
      final refreshedUser = _auth.currentUser ?? user;

      return UserEntity(
        id: refreshedUser.uid,
        name: refreshedUser.displayName?.isNotEmpty == true
            ? refreshedUser.displayName!
            : email.split('@')[0],
        email: refreshedUser.email ?? email,
        hasProfile: false,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Login dengan Google OAuth (Pop-up Web & Mobile)
  Future<UserEntity> loginWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      final userCredential = await _auth.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Gagal mendapatkan data akun Google.');
      }

      return UserEntity(
        id: user.uid,
        name: user.displayName ?? 'Pengguna Google',
        email: user.email ?? '',
        hasProfile: false,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal menghubungkan dengan Google: ${e.toString()}');
    }
  }

  /// Kirim Ulang Email Verifikasi
  Future<bool> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Cek Status Verifikasi Email
  Future<bool> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return _auth.currentUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Reset Password via Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal mengirim email reset kata sandi: $e');
    }
  }

  /// Dapatkan JWT ID Token untuk otentikasi backend
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  /// Logout dari Firebase Auth
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Menerjemahkan kode error Firebase Auth ke pesan bahasa Indonesia yang ramah pengguna
  String _mapFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar di sistem NutriCare.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi yang Anda masukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan masuk atau gunakan email lain.';
      case 'invalid-email':
        return 'Format alamat email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan oleh administrator.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan tunggu beberapa saat lagi.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan di Firebase Console.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 8 karakter dengan kombinasi kuat.';
      case 'popup-closed-by-user':
        return 'Jendela masuk Google telah ditutup sebelum selesai.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.';
      default:
        return e.message ?? 'Terjadi kesalahan pada layanan autentikasi (${e.code}).';
    }
  }
}
