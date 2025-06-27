import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddVoiceState {
  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final String? audioPath;
  final bool isLoading;
  final bool isRecording;
  final String? errorMessage;

  AddVoiceState({
    required this.formKey,
    required this.descriptionController,
    this.audioPath,
    this.isLoading = false,
    this.isRecording = false,
    this.errorMessage,
  });

  AddVoiceState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? descriptionController,
    String? audioPath,
    bool? isLoading,
    bool? isRecording,
    String? errorMessage,
  }) {
    return AddVoiceState(
      formKey: formKey ?? this.formKey,
      descriptionController:
          descriptionController ?? this.descriptionController,
      audioPath: audioPath ?? this.audioPath,
      isLoading: isLoading ?? this.isLoading,
      isRecording: isRecording ?? this.isRecording,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AddVoiceNotifier extends StateNotifier<AddVoiceState> {
  AddVoiceNotifier()
    : super(
        AddVoiceState(
          formKey: GlobalKey<FormState>(),
          descriptionController: TextEditingController(),
        ),
      );

  final _audioRecorder = AudioRecorder();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final String path = '${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        state = state.copyWith(isRecording: true);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Ses kaydı başlatılamadı: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        state = state.copyWith(audioPath: path, isRecording: false);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Ses kaydı durdurulamadı: $e',
        isRecording: false,
      );
    }
  }

  void deleteAudio() {
    if (state.audioPath != null) {
      File(state.audioPath!).delete();
      state = state.copyWith(audioPath: null);
    }
  }

  Future<bool> saveVoiceMemory() async {
    if (state.audioPath == null) {
      state = state.copyWith(errorMessage: 'Lütfen bir ses kaydı ekleyin');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        state = state.copyWith(errorMessage: 'Kullanıcı oturum açmamış');
        return false;
      }

      final String memoryId = const Uuid().v4();
      final File audioFile = File(state.audioPath!);

      final storageRef = _storage.ref().child(
        'users/${currentUser.uid}/voices/$memoryId.m4a',
      );

      await storageRef.putFile(audioFile);
      final String audioUrl = await storageRef.getDownloadURL();

      await _firestore.collection('memories').doc(memoryId).set({
        'id': memoryId,
        'userId': currentUser.uid,
        'type': 'voice',
        'description': state.descriptionController.text,
        'audioUrl': audioUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateFormat('dd.MM.yyyy').format(DateTime.now()),
      });

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Ses kaydı kaydedilemedi: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    state.descriptionController.dispose();
    super.dispose();
  }
}

final addVoiceProvider = StateNotifierProvider<AddVoiceNotifier, AddVoiceState>(
  (ref) {
    return AddVoiceNotifier();
  },
);
