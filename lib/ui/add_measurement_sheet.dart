// Bottom sheet to record a measurement, with the "how to measure" guide next to the input.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'alerts_page.dart';
import 'theme.dart';
 
void showAddMeasurement(BuildContext context, {String? code}) {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _AddMeasurementForm(
        initialCode: code,
        onSaved: (savedCode, value, result) {
          final indicator = indicatorByCode(savedCode);
          final name = t('ind.$savedCode.name');
          final text = t('add.saved', [name, '${indicator.format(value)} ${indicator.unit}']);
          String? alertId;
          if (result.level != AlertLevel.nominal) {
            for (final a in appState.sortedAlerts()) {
              if (a.indicator == savedCode && a.isOpen) {
                alertId = a.id;
                break;
              }
            }
          }
          final target = alertId;
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('$text - ${t(levelKey(result.level))}'),
              duration: const Duration(seconds: 6),
              action: target == null
                  ? null
                  : SnackBarAction(
                      label: t('add.view'),
                      onPressed: () => navigator.push(
                        MaterialPageRoute<void>(
                          builder: (_) => AlertDetailPage(alertId: target),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    ),
  );
}
 
class _AddMeasurementForm extends StatefulWidget {
  final String? initialCode;
  final void Function(String code, double value, AnalysisResult result) onSaved;
 
  const _AddMeasurementForm({required this.initialCode, required this.onSaved});
 
  @override
  State<_AddMeasurementForm> createState() => _AddMeasurementFormState();
}
 
class _AddMeasurementFormState extends State<_AddMeasurementForm> {
  late String _code;
  final TextEditingController _controller = TextEditingController();
  int? _score;
  String? _error;
 
  @override
  void initState() {
    super.initState();
    _code = widget.initialCode ?? kIndicators.first.code;

  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  void _select(String code) {
    setState(() {
      _code = code;
      _score = null;
      _error = null;
      _controller.clear();
    });
  }
 
  void _save() {
    final indicator = indicatorByCode(_code);
    double? value;
    if (indicator.isScore) {
      value = _score?.toDouble();
    } else {
      value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    }
    if (value == null || value < indicator.min || value > indicator.max) {
      setState(() {
        _error = t('add.invalid', [
          indicator.format(indicator.min),
          indicator.format(indicator.max),
        ]);
      });
      return;
    }
    final result = appState.record(_code, value);
    Navigator.of(context).pop();
    widget.onSaved(_code, value, result);
  }
 
  @override
  Widget build(BuildContext context) {
    final indicator = indicatorByCode(_code);
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('add.title'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final i in kIndicators)
                ChoiceChip(
                  avatar: Icon(indicatorIcon(i.code), size: 18),
                  label: Text(t('ind.${i.code}.name')),
                  selected: i.code == _code,
                  onSelected: (_) => _select(i.code),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha(22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school_outlined, size: 20, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('add.how'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(t('ind.$_code.how'), style: const TextStyle(height: 1.35)),
                    ],

                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (indicator.isScore) ...[
            Text(t('add.score.hint')),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var s = 1; s <= 5; s++)
                  ChoiceChip(
                    showCheckmark: false,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text('$s', style: const TextStyle(fontSize: 18)),
                    ),
                    selected: _score == s,
                    onSelected: (_) => setState(() {
                      _score = s;
                      _error = null;
                    }),
                  ),
              ],
            ),
          ] else
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22),
              decoration: InputDecoration(
                labelText: t('add.value'),
                suffixText: indicator.unit,
                helperText:
                    '${indicator.format(indicator.min)} - '
                    '${indicator.format(indicator.max)} ${indicator.unit}',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_error!, style: TextStyle(color: scheme.error)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(t('add.cancel')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(t('add.save')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

