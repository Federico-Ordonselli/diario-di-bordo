import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../domain/profile.dart';
import '../../domain/validation.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  /// Backup scelto e già validato, in attesa di conferma.
  Profile? candidate;

  Future<void> choose() async {
    try {
      final raw = await pickJson();
      if (raw == null) return;
      final validated = ProfileValidator(
        ref.read(catalogProvider),
      ).profile(raw);
      if (mounted) setState(() => candidate = validated);
    } catch (e) {
      ref.report(e);
    }
  }

  Future<void> restore() async {
    final chosen = candidate!, current = ref.read(profileProvider).profile;
    if (!await ref.exportJson(current, 'kh1fm-prima-importazione')) return;
    if (!identical(current, ref.read(profileProvider).profile)) {
      ref.report('Il profilo è cambiato: ricontrolla l’anteprima.');
      return;
    }
    if (await ref.commit((_) => Profile(copyJson(chosen)), importing: true) &&
        mounted) {
      setState(() => candidate = null);
    }
  }

  Future<void> exportPrevious() async {
    try {
      final bytes = await ref.read(profileRepositoryProvider).previousBackup();
      if (bytes == null) {
        throw const FormatException('Nessun backup precedente.');
      }
      await ref.exportBytes(
        bytes,
        'kh1fm-backup-precedente.json',
        'application/json',
      );
    } catch (e) {
      ref.report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final candidate = this.candidate;
    return PageBody(
      title: 'Backup',
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Conserva i tuoi progressi'),
              text(
                'Il backup JSON include inventario, checklist, piano, cronologia, snapshot e override. Compatibile con i backup della precedente app.',
              ),
              SelectableText(
                'Archivio: ${ref.watch(profileRepositoryProvider).location}',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => ref.exportJson(state, 'kh1fm-backup'),
                    icon: const Icon(Icons.download),
                    label: const Text('Esporta backup JSON'),
                  ),
                  OutlinedButton(
                    onPressed: exportPrevious,
                    child: const Text('Esporta backup precedente'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Importa e ripristina'),
              text(
                'Scegli un backup della vecchia app oppure data/profile.json. Prima della sostituzione viene esportata e conservata una copia del profilo attuale.',
              ),
              OutlinedButton.icon(
                onPressed: choose,
                icon: const Icon(Icons.file_open),
                label: const Text('Scegli backup JSON'),
              ),
              if (candidate != null) ...[
                heading('Anteprima importazione'),
                text(
                  'Checklist: ${engine.catalog.summary(candidate)['done']} / 794\nSintesi: ${engine.distinct(candidate)} / 33\nOperazioni annullabili: ${candidate.transactions.length}\nSnapshot: ${candidate.saveSnapshots.length}',
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: restore,
                      child: const Text('Crea backup e sostituisci i dati'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => this.candidate = null),
                      child: const Text('Annulla anteprima'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        heading('Cronologia'),
        for (final t in state.transactions.reversed.take(20))
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(t.label),
            subtitle: Text(t.at),
          ),
        text(
          'La cronologia conserva fino a 100 operazioni. Le scritture fallite non aggiornano i dati visualizzati.',
          color: muted,
        ),
      ],
    );
  }
}
