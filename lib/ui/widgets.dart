import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const gold = Color(0xFFD9B86C);
const muted = Color(0xFF9CAAC0);
String display(dynamic value) => value == null
    ? 'Da verificare'
    : value == true
    ? 'Sì'
    : value == false
    ? 'No'
    : '$value';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

class NumberEditor extends StatefulWidget {
  const NumberEditor({
    super.key,
    required this.label,
    required this.value,
    required this.onSave,
    this.max = 999999,
    this.nullable = true,
    this.stepping = false,
  });
  final String label;
  final int? value;
  final int max;
  final bool nullable;
  final bool stepping;
  final Future<void> Function(int?) onSave;
  @override
  State<NumberEditor> createState() => _NumberEditorState();
}

class _NumberEditorState extends State<NumberEditor> {
  late final text = TextEditingController(text: widget.value?.toString() ?? '');
  final focus = FocusNode();
  String? error;
  @override
  void initState() {
    super.initState();
    focus.addListener(onFocus);
  }

  void onFocus() {
    if (!focus.hasFocus) save();
  }

  @override
  void didUpdateWidget(NumberEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      text.text = widget.value?.toString() ?? '';
    }
  }

  Future<void> save() async {
    final value = text.text.isEmpty ? null : int.tryParse(text.text);
    if (text.text.isNotEmpty && value == null ||
        value == null && !widget.nullable ||
        value != null && (value < 0 || value > widget.max)) {
      setState(() => error = '0–${widget.max}');
      return;
    }
    setState(() => error = null);
    if (value != widget.value) {
      await widget.onSave(value);
      if (mounted) text.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    focus.removeListener(onFocus);
    focus.dispose();
    text.dispose();
    super.dispose();
  }

  void step(int delta) {
    if (widget.value == null) return;
    widget.onSave((widget.value! + delta).clamp(0, widget.max).toInt());
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: widget.stepping
        ? {
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => step(1),
            const SingleActivator(LogicalKeyboardKey.arrowDown): () => step(-1),
          }
        : {},
    child: TextField(
      controller: text,
      focusNode: focus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: '?',
        errorText: error,
      ),
      onSubmitted: (_) => save(),
    ),
  );
}

class RepeatButton extends StatefulWidget {
  const RepeatButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final Future<void> Function()? onPressed;
  @override
  State<RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<RepeatButton>
    with WidgetsBindingObserver {
  Timer? timer;
  bool running = false;
  bool pointerGesture = false;
  void stop() {
    timer?.cancel();
    timer = null;
  }

  Future<void> tick() async {
    if (running || widget.onPressed == null) return;
    running = true;
    try {
      await widget.onPressed!();
    } finally {
      running = false;
    }
  }

  void start() {
    stop();
    pointerGesture = true;
    tick();
    timer = Timer(const Duration(milliseconds: 350), () {
      timer = Timer.periodic(const Duration(milliseconds: 90), (_) => tick());
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) stop();
  }

  @override
  void didUpdateWidget(RepeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) stop();
  }

  @override
  void dispose() {
    stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    child: MouseRegion(
      onExit: (_) => stop(),
      child: Listener(
        onPointerDown: widget.onPressed == null ? null : (_) => start(),
        onPointerUp: (_) {
          stop();
          scheduleMicrotask(() => pointerGesture = false);
        },
        onPointerCancel: (_) {
          stop();
          pointerGesture = false;
        },
        child: IconButton(
          tooltip: widget.label,
          onPressed: widget.onPressed == null
              ? null
              : () {
                  if (!pointerGesture) tick();
                  pointerGesture = false;
                },
          icon: Icon(widget.icon),
        ),
      ),
    ),
  );
}

Widget choice(
  String label,
  String selected,
  Map<String, String> values,
  void Function(String) change,
) => ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 300),
  child: DropdownButtonFormField<String>(
    key: ValueKey('$label-$selected'),
    initialValue: values.containsKey(selected) ? selected : values.keys.first,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: values.entries
        .map(
          (e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: (v) {
      if (v != null) change(v);
    },
  ),
);

class EditionEditor extends StatefulWidget {
  const EditionEditor({super.key, required this.value, required this.onSave});
  final String value;
  final Future<void> Function(String) onSave;
  @override
  State<EditionEditor> createState() => _EditionEditorState();
}

class _EditionEditorState extends State<EditionEditor> {
  late final text = TextEditingController(text: widget.value);
  final focus = FocusNode();
  @override
  void initState() {
    super.initState();
    focus.addListener(onFocus);
  }

  void onFocus() {
    if (!focus.hasFocus) save();
  }

  Future<void> save() async {
    if (text.text != widget.value) {
      await widget.onSave(text.text);
      if (mounted) text.text = widget.value;
    }
  }

  @override
  void didUpdateWidget(EditionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) text.text = widget.value;
  }

  @override
  void dispose() {
    focus.removeListener(onFocus);
    focus.dispose();
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: text,
    focusNode: focus,
    maxLength: 100,
    decoration: const InputDecoration(labelText: 'Piattaforma / edizione'),
    onSubmitted: (_) => save(),
  );
}
