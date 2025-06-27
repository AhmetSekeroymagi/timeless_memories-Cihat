import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

// Profile State
class ProfileState {
  final bool isLoading;
  final User? user;
  final Map<String, dynamic>? userData;
  final String? error;

  ProfileState({this.isLoading = true, this.user, this.userData, this.error});

  ProfileState copyWith({
    bool? isLoading,
    User? user,
    Map<String, dynamic>? userData,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      userData: userData ?? this.userData,
      error: error ?? this.error,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileNotifier(this._auth, this._firestore) : super(ProfileState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        state = state.copyWith(
          isLoading: false,
          user: user,
          userData: userDoc.data(),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    try {
      state = state.copyWith(isLoading: true);

      final storageRef = FirebaseStorage.instance.ref();
      final profileImageRef = storageRef
          .child('profile_images')
          .child('${_auth.currentUser!.uid}.jpg');

      await profileImageRef.putFile(imageFile);
      final imageUrl = await profileImageRef.getDownloadURL();

      await _auth.currentUser!.updatePhotoURL(imageUrl);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'photoURL': imageUrl,
      });

      final updatedUser = _auth.currentUser;
      final updatedDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
        userData: updatedDoc.data(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);

      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .update(data);

      final updatedDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .get();

      state = state.copyWith(isLoading: false, userData: updatedDoc.data());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      state = ProfileState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(FirebaseAuth.instance, FirebaseFirestore.instance);
});
