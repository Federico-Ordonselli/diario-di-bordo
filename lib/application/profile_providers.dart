import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/catalog.dart';
import '../domain/engine.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import '../domain/validation.dart';

/// Catalogo caricato dagli asset prima di `runApp`: va sempre sovrascritto
/// (in `main` e nei test).
final catalogProvider = Provider<Catalog>(
  (ref) => throw UnimplementedError('catalogProvider va sovrascritto'),
);

/// Archivio del profilo: in `main` `JsonProfileRepository.open()`, nei test
/// `InMemoryProfileRepository` o un repository su cartella temporanea.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) =>
      throw UnimplementedError('profileRepositoryProvider va sovrascritto'),
);

final engineProvider = Provider<Engine>(
  (ref) => Engine(ref.watch(catalogProvider)),
);

final profileProvider = NotifierProvider<ProfileNotifier, ProfileViewState>(
  ProfileNotifier.new,
);

/// Quello che la UI mostra del profilo: i dati più lo stato dell'archivio.
@immutable
class ProfileViewState {
  const ProfileViewState({
    required this.profile,
    this.busy = false,
    this.blocked = false,
    this.error,
  });

  final Profile profile;

  /// Lettura o scrittura in corso: nuove operazioni vengono rifiutate.
  final bool busy;

  /// Archivio illeggibile: sono ammesse solo le importazioni.
  final bool blocked;
  final String? error;

  static const _keep = Object();

  ProfileViewState copyWith({
    Profile? profile,
    bool? busy,
    bool? blocked,
    Object? error = _keep,
  }) => ProfileViewState(
    profile: profile ?? this.profile,
    busy: busy ?? this.busy,
    blocked: blocked ?? this.blocked,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}

class ProfileNotifier extends Notifier<ProfileViewState> {
  Engine get _engine => ref.read(engineProvider);
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileViewState build() =>
      ProfileViewState(profile: ref.watch(catalogProvider).fresh());

  /// Carica l'archivio (o crea il profilo iniziale) e applica le evidence.
  Future<void> initialize() async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    final catalog = _engine.catalog;
    try {
      final raw = await _repository.load();
      final loaded = raw == null
          ? catalog.fresh()
          : ProfileValidator(catalog).profile(raw);
      final next = _engine.applyEvidence(loaded);
      if (raw == null || !identical(next, loaded)) {
        await _repository.save(next);
      }
      if (!ref.mounted) return;
      state = ProfileViewState(profile: next);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        busy: false,
        blocked: true,
        error:
            'Archivio non leggibile: $e. Il file originale è conservato. Ripristina un backup.',
      );
    }
  }

  /// Applica [change], valida e salva. Restituisce `false` se l'operazione è
  /// stata rifiutata o il salvataggio è fallito: in quel caso il profilo
  /// mostrato resta quello precedente.
  Future<bool> commit(
    Profile Function(Profile) change, {
    bool importing = false,
  }) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      if (state.blocked && !importing) {
        throw const FormatException(
          'Ripristina prima il profilo dalla pagina Backup.',
        );
      }
      final current = state.profile;
      final next = change(current);
      var saved = current;
      if (!identical(next, current)) {
        saved = ProfileValidator(_engine.catalog).profile(next);
        await _repository.save(saved, beforeImport: importing);
      }
      if (!ref.mounted) return true;
      state = ProfileViewState(profile: saved);
      return true;
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e.toString());
      return false;
    }
  }

  void showError(Object value) =>
      state = state.copyWith(error: value.toString());

  void dismissError() {
    if (!state.blocked) state = state.copyWith(error: null);
  }
}
