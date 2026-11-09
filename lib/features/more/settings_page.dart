import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

const _numbers = {
  'level': 'Livello di Sora',
  'mp': 'MP massimi',
  'lucky': 'Lucky Strike attivi (0–3)',
  'munny': 'Munny attuali',
};
const _flags = [
  'Stop',
  'Aerora',
  'Aeroga',
  'Ragnarok',
  'Glide',
  'Dumbo',
  'Bambi',
  'Mushu',
  'Trio Bianco',
  'Trio Giallo',
];

/// Preparazione del farming: edizione, statistiche e sblocchi.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileProvider).profile.settings;
    final engine = ref.watch(engineProvider);
    return PageBody(
      title: 'Preparazione',
      children: [
        text(
          'Questi dati descrivono la preparazione del farming. Le abilità sconosciute non vengono considerate disponibili.',
          color: muted,
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Salvataggio e abilità'),
              EditionEditor(
                value: settings.edition,
                onSave: (v) => ref.commit(
                  (s) => engine.transact(
                    s,
                    'Piattaforma',
                    (n) => n.settings['edition'] = v,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final e in _numbers.entries)
                    SizedBox(
                      width: 250,
                      child: NumberEditor(
                        key: ValueKey('settings-${e.key}'),
                        label: e.value,
                        value: settings[e.key] as int?,
                        max: e.key == 'lucky' ? 3 : 999999,
                        onSave: (v) => ref.commit(
                          (s) => engine.transact(
                            s,
                            e.value,
                            (n) => n.settings[e.key] = v,
                          ),
                        ),
                      ),
                    ),
                  for (final key in _flags)
                    SizedBox(
                      width: 250,
                      child: choice(
                        key,
                        settings.flag(key) == null
                            ? 'unknown'
                            : '${settings.flag(key)}',
                        {
                          'unknown': 'Da verificare',
                          'true': 'Disponibile',
                          'false': 'Non disponibile',
                        },
                        (v) => ref.commit(
                          (s) => engine.transact(
                            s,
                            'Disponibilità $key',
                            (n) => n.settings.setFlag(
                              key,
                              v == 'unknown' ? null : v == 'true',
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              text(
                'Pink Agaricus: verifica MP elevati, Stop, Ragnarok e le differenze tra edizioni.',
                color: gold,
              ),
              for (final key in settings.keys) Provenance('settings.$key'),
            ],
          ),
        ),
      ],
    );
  }
}
