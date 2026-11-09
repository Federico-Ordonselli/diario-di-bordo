import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/catalog.dart';
import '../domain/engine.dart';
import '../domain/validation.dart';
import 'profile_store.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this.engine, this.store) : state = engine.catalog.fresh();
  final Engine engine;
  final ProfileStore store;
  Json state;
  bool busy = false, blocked = false;
  String? error;
  Future<void> initialize() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      final raw = await store.loadRaw();
      state = raw == null
          ? engine.catalog.fresh()
          : ProfileValidator(engine.catalog).validate(jsonDecode(raw));
      final next = engine.applyEvidence(state);
      if (raw == null || !identical(next, state)) await store.save(next);
      state = next;
      blocked = false;
      error = null;
    } catch (e) {
      blocked = true;
      error =
          'Archivio non leggibile: $e. Il file originale è conservato. Ripristina un backup.';
    }
    busy = false;
    notifyListeners();
  }

  Future<bool> commit(
    Json Function(Json) change, {
    bool importing = false,
  }) async {
    if (busy) return false;
    busy = true;
    notifyListeners();
    try {
      if (blocked && !importing) {
        throw const FormatException(
          'Ripristina prima il profilo dalla pagina Backup.',
        );
      }
      final next = change(state);
      if (!identical(next, state)) {
        final validated = ProfileValidator(engine.catalog).validate(next);
        await store.save(validated, beforeImport: importing);
        state = validated;
      }
      blocked = false;
      error = null;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void showError(Object value) {
    error = value.toString();
    notifyListeners();
  }

  void dismissError() {
    if (!blocked) {
      error = null;
      notifyListeners();
    }
  }
}
