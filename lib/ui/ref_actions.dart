import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../application/profile_providers.dart';
import '../domain/catalog.dart';
import '../domain/profile.dart';

/// Azioni con effetti esterni (archivio, file, link) usate da più pagine.
/// Gli errori finiscono nel banner del profilo, come prima dello split.
extension RefActions on WidgetRef {
  Future<bool> commit(
    Profile Function(Profile) change, {
    bool importing = false,
  }) => read(profileProvider.notifier).commit(change, importing: importing);

  void report(Object error) => read(profileProvider.notifier).showError(error);

  Future<void> openExternal(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !['https', 'http'].contains(uri.scheme) ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw const FormatException('Collegamento non disponibile.');
      }
    } catch (e) {
      report(e);
    }
  }

  Future<bool> exportBytes(List<int> bytes, String name, String mime) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$name');
        await file.writeAsBytes(bytes, flush: true);
        final result = await Share.shareXFiles([
          XFile(file.path, mimeType: mime),
        ], sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1));
        return result.status != ShareResultStatus.dismissed;
      }
      final location = await getSaveLocation(suggestedName: name);
      if (location == null) return false;
      await XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: mime,
        name: name,
      ).saveTo(location.path);
      return true;
    } catch (e) {
      report(e);
      return false;
    }
  }

  Future<bool> exportJson(Json value, String prefix) => exportBytes(
    utf8.encode(const JsonEncoder.withIndent('  ').convert(value)),
    '$prefix-${DateTime.now().toIso8601String().substring(0, 10)}.json',
    'application/json',
  );

  /// Esporta un documento incluso negli asset.
  Future<void> exportDocument(String name) async {
    try {
      final data = await rootBundle.load('assets/documents/$name');
      await exportBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        name,
        name.endsWith('.pdf') ? 'application/pdf' : 'text/markdown',
      );
    } catch (e) {
      report(e);
    }
  }
}

Future<Json?> pickJson() async {
  final file = await openFile(
    acceptedTypeGroups: [
      const XTypeGroup(
        label: 'JSON',
        extensions: ['json'],
        mimeTypes: ['application/json'],
        uniformTypeIdentifiers: ['public.json'],
      ),
    ],
  );
  if (file == null) return null;
  if (await file.length() > 10 * 1024 * 1024) {
    throw const FormatException('File troppo grande: massimo 10 MB.');
  }
  final data = jsonDecode(await file.readAsString());
  if (data is! Json) {
    throw const FormatException(
      'Il JSON deve contenere un profilo o uno snapshot.',
    );
  }
  return data;
}
