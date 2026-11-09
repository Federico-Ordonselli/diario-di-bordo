import 'package:flutter/foundation.dart';
import '../domain/engine.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import '../domain/validation.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this.engine, this.repository)
    : state = engine.catalog.fresh();
  final Engine engine;
  final ProfileRepository repository;
  Profile state;
  bool busy = false, blocked = false;
  String? error;
  Future<void> initialize() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      final raw = await repository.load();
      state = raw == null
          ? engine.catalog.fresh()
          : ProfileValidator(engine.catalog).profile(raw);
      final next = engine.applyEvidence(state);
      if (raw == null || !identical(next, state)) await repository.save(next);
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
    Profile Function(Profile) change, {
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
        final validated = ProfileValidator(engine.catalog).profile(next);
        await repository.save(validated, beforeImport: importing);
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
