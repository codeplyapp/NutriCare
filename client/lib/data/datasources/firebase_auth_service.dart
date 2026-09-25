import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nutricare/firebase_options.dart';
import 'package:nutricare/domain/entities/entities.dart';

/// Service wrapper untuk Firebase Authentication di NutriCare
class FirebaseAuthService {
  FirebaseAuth? _customAuth;

  FirebaseAuthService({FirebaseAuth? auth}) : _customAuth = auth;

  /// Memastikan Firebase App terinisialisasi sebelum mengakses FirebaseAuth instance
  Future<FirebaseAuth> _getAuth() async {
    if (_customAuth != null) return _customAuth!;
    
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint('Firebase.initializeApp in service: $e');
      }
    }
    return FirebaseAuth.instance;
  }

  User? get currentUser {
    try {
      if (Firebase.apps.isNotEmpty) {
        return (_customAuth ?? FirebaseAuth.instance).currentUser;
      }
    } catch (_) {}
    return null;
  }

  Stream<User?> get authStateChanges {
    try {
      if (Firebase.apps.isNotEmpty) {
        return (_customAuth ?? FirebaseAuth.instance).authStateChanges();
      }
    } catch (_) {}
    return const Stream.empty();
  }

  /// Register dengan Email & Password (Real Firebase Auth)
  Future<UserEntity> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final auth = await _getAuth();
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        try {
          await user.updateDisplayName(name.trim());
        } catch (_) {}
        try {
          await user.sendEmailVerification();
        } catch (_) {}
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
      throw Exception('Gagal melakukan pendaftaran: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Login dengan Email & Password (Real Firebase Auth)
  Future<UserEntity> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _getAuth();
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Pengguna tidak ditemukan.');
      }

      try {
        await user.reload();
      } catch (_) {}

      final refreshedUser = auth.currentUser ?? user;

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

  /// Login dengan Google OAuth Pop-up (Real Firebase Auth with Account Selector)
  Future<UserEntity> loginWithGoogle() async {
    try {
      final auth = await _getAuth();
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      // Memastikan popup selalu menampilkan pemilih akun Google
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential userCredential = await auth.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Gagal mendapatkan informasi akun Google.');
      }

      return UserEntity(
        id: user.uid,
        name: user.displayName?.isNotEmpty == true
            ? user.displayName!
            : (user.email?.split('@')[0] ?? 'Pengguna Google'),
        email: user.email ?? '',
        hasProfile: false,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal menghubungkan dengan Google: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Kirim Ulang Email Verifikasi
  Future<bool> sendVerificationEmail() async {
    try {
      final user = currentUser;
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
      final user = currentUser;
      if (user != null) {
        await user.reload();
        return currentUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Reset Password via Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      final auth = await _getAuth();
      await auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal mengirim email reset kata sandi: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Dapatkan JWT ID Token untuk otentikasi backend
  Future<String?> getIdToken() async {
    final user = currentUser;
    if (user != null) {
      try {
        return await user.getIdToken();
      } catch (_) {}
    }
    return null;
  }

  /// Logout dari Firebase Auth
  Future<void> signOut() async {
    try {
      final auth = await _getAuth();
      await auth.signOut();
    } catch (_) {}
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
        return 'Metode login Google / Email belum diaktifkan di Firebase Console (Authentication > Sign-in method).';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 8 karakter dengan kombinasi kuat.';
      case 'popup-closed-by-user':
        return 'Jendela masuk Google ditutup sebelum proses selesai.';
      case 'popup-blocked':
        return 'Jendela pop-up Google diblokir oleh browser. Harap izinkan pop-up untuk situs ini.';
      case 'unauthorized-domain':
        return 'Domain ini belum diotorisasi di Firebase Console. Harap tambahkan domain di Authentication > Settings > Authorized domains.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.';
      default:
        return e.message ?? 'Terjadi kesalahan pada layanan autentikasi (${e.code}).';
    }
  }
}
