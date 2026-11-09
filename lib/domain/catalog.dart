import 'dart:convert';
import 'profile.dart';

typedef Json = Map<String, dynamic>;
Json copyJson(Json value) => jsonDecode(jsonEncode(value)) as Json;
String normalize(String value) =>
    value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

class Catalog {
  Catalog(this.synthesis, this.workbook, this.evidence, this.initial) {
    for (final item in items) {
      itemsById[item['id'] as String] = item;
    }
    for (final recipe in recipes) {
      recipesById[recipe['id'] as String] = recipe;
    }
    for (final material in materials) {
      materialsById[material['id'] as String] = material;
    }
  }
  final Json synthesis, workbook, evidence, initial;
  final Map<String, Json> itemsById = {}, recipesById = {}, materialsById = {};
  List<Json> get materials => (synthesis['materials'] as List).cast<Json>();
  List<Json> get recipes => (synthesis['recipes'] as List).cast<Json>();
  List<Json> get collections => (synthesis['collections'] as List).cast<Json>();
  List<Json> get farming => (synthesis['farming'] as List).cast<Json>();
  List<String> get route15 => (synthesis['route15'] as List).cast<String>();
  List<Json> get items => (workbook['items'] as List).cast<Json>();
  List<Json> get categories => (workbook['categories'] as List).cast<Json>();
  List<Json> get guides => (workbook['guides'] as List).cast<Json>();
  Profile fresh() =>
      Profile(copyJson(initial))
        ..updatedAt = DateTime.now().toUtc().toIso8601String();

  Json lookup(String category, String title) => items.firstWhere(
    (item) =>
        item['categoryId'] == category &&
        normalize(item['title'] as String) == normalize(title),
    orElse: () => throw FormatException('Voce non mappata: $title'),
  );
  bool completed(Profile state, Json item) => item['recipeId'] != null
      ? state.everCrafted[item['recipeId']] == true
      : state.completion[item['id']] == true;
  String status(Profile state, Json item) =>
      item['recipeId'] == null &&
          state.completion.containsKey(item['id']) &&
          state.completion[item['id']] == null
      ? 'unknown'
      : completed(state, item)
      ? 'done'
      : 'todo';
  Json summary(Profile state, [String? category]) {
    final pool = items
        .where((item) => category == null || item['categoryId'] == category)
        .toList();
    final done = pool.where((item) => completed(state, item)).length;
    return {
      'done': done,
      'total': pool.length,
      'remaining': pool.length - done,
      'percent': pool.isEmpty ? 0.0 : (done / pool.length * 1000).round() / 10,
    };
  }
}
