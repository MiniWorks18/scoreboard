import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_dialog.dart';

class ScoreDialog extends StatefulWidget {
  final String playerName;
  final int currentScore;
  final Color playerColor;
  final VoidCallback onViewHistory;

  const ScoreDialog({
    required this.playerName,
    required this.currentScore,
    required this.playerColor,
    required this.onViewHistory,
    Key? key,
  }) : super(key: key);

  @override
  State<ScoreDialog> createState() => _ScoreDialogState();
}

class _ScoreDialogState extends State<ScoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController(text: '0');

  int? get _number => int.tryParse(_numberController.text.trim());

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_refreshPreview);
  }

  void _refreshPreview() => setState(() {});

  @override
  void dispose() {
    _numberController.removeListener(_refreshPreview);
    _numberController.dispose();
    super.dispose();
  }

  void _adjustNumber(int delta) {
    HapticFeedback.selectionClick();
    final text = ((_number ?? 0) + delta).toString();
    _numberController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    if (_number != 0) HapticFeedback.lightImpact();
    Navigator.of(context).pop(_number);
  }

  Widget _adjustmentButton(int delta) {
    final subtract = delta < 0;
    final color = subtract ? const Color(0xFFB83E55) : const Color(0xFF186B54);
    return SizedBox.square(
      dimension: 68,
      child: TextButton(
        onPressed: () => _adjustNumber(delta),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: color,
          backgroundColor: color.withOpacity(0.09),
          shape: CircleBorder(side: BorderSide(color: color.withOpacity(0.15))),
        ),
        child: Text(
          subtract ? '−${delta.abs()}' : '+$delta',
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final number = _number;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GlassDialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DAE5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 24),
              Text('Adjust score', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.playerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.playerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 302 ? 4 : 2;
                  final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: [-10, -5, 5, 10].map((delta) {
                      return SizedBox(
                        width: width,
                        child: Center(child: _adjustmentButton(delta)),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE1E7F0)),
                ),
                child: Column(
                  children: [
                    const Text('POINTS TO ADD',
                        style: TextStyle(fontSize: 11, letterSpacing: 1.8)),
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          tooltip: 'Subtract one point',
                          icon: const Icon(Icons.remove_rounded),
                          onPressed: () => _adjustNumber(-1),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _numberController,
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -2,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(signed: true),
                            textAlign: TextAlign.center,
                            onTap: () {
                              if (_numberController.text == '0') {
                                _numberController.selection = const TextSelection(
                                  baseOffset: 0,
                                  extentOffset: 1,
                                );
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            validator: (value) => int.tryParse(value?.trim() ?? '') == null
                                ? 'Enter a whole number.'
                                : null,
                            onFieldSubmitted: (_) => _apply(),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          tooltip: 'Add one point',
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () => _adjustNumber(1),
                        ),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: reduceMotion ? 0 : 180),
                      child: Text(
                        number == null
                            ? 'Type an adjustment above'
                            : '${widget.currentScore} → ${widget.currentScore + number} total',
                        key: ValueKey(number),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF526079)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                    backgroundColor: const Color(0xFF192A45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text(
                    number == null || number == 0
                        ? 'Apply score'
                        : 'Apply ${number > 0 ? '+' : '−'}${number.abs()} points',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        widget.onViewHistory();
                      },
                      style: TextButton.styleFrom(minimumSize: const Size(0, 52)),
                      icon: const Icon(Icons.history_rounded, size: 20),
                      label: const Text('History'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(minimumSize: const Size(0, 52)),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
