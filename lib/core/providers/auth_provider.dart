import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

// ─── Firebase instances ────────────────────────────────────
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// ─── Auth state stream ────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ─── Profile setup skipped state provider (for "Add Later") ───
final profileSetupSkippedProvider = StateProvider<bool>((ref) => false);

// ─── Current user profile from Firestore ──────────────────
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) =>
              doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Auth Notifier ────────────────────────────────────────
class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  FirebaseFirestore get _db => ref.read(firestoreProvider);

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      ref.read(profileSetupSkippedProvider.notifier).state = false;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Student',
            email: user.email ?? '',
            role: UserRole.student, // Default to student
            createdAt: DateTime.now(),
          );
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
        }
        ref.read(profileSetupSkippedProvider.notifier).state = false;
      }
    });
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
    String? studentId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user!.updateDisplayName(name);
      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
        department: department,
        studentId: studentId,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
      ref.read(profileSetupSkippedProvider.notifier).state = false;
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _auth.sendPasswordResetEmail(email: email));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.signOut();
      ref.read(profileSetupSkippedProvider.notifier).state = false;
    });
  }

  void clearError() => state = const AsyncValue.data(null);
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
