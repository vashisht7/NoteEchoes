import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A quiet inline table that behaves like part of the note. Return advances
/// through cells and creates a new row when the final cell is reached.
class InlineNoteTable extends StatefulWidget {
  final int initialRows;
  final int initialCols;
  final ValueChanged<List<List<String>>>? onDataChanged;
  final List<List<String>> initialData;
  final VoidCallback? onRemove;

  const InlineNoteTable({
    super.key,
    this.initialRows = 2,
    this.initialCols = 2,
    this.onDataChanged,
    this.initialData = const [],
    this.onRemove,
  });

  @override
  State<InlineNoteTable> createState() => _InlineNoteTableState();
}

class _InlineNoteTableState extends State<InlineNoteTable> {
  late List<List<TextEditingController>> _controllers;
  late List<List<FocusNode>> _focusNodes;

  int get _rows => _controllers.length;
  int get _cols => _controllers.first.length;

  @override
  void initState() {
    super.initState();
    final rows = widget.initialData.isEmpty
        ? widget.initialRows
        : widget.initialData.length;
    final cols = widget.initialData.isEmpty
        ? widget.initialCols
        : widget.initialData
              .map((row) => row.length)
              .fold<int>(1, (a, b) => a > b ? a : b);

    _controllers = List.generate(
      rows,
      (r) => List.generate(cols, (c) {
        final value =
            r < widget.initialData.length && c < widget.initialData[r].length
            ? widget.initialData[r][c]
            : '';
        return _newController(value);
      }),
    );
    _focusNodes = List.generate(
      rows,
      (_) => List.generate(cols, (_) => FocusNode()),
    );
  }

  TextEditingController _newController([String text = '']) {
    final controller = TextEditingController(text: text);
    controller.addListener(_emitData);
    return controller;
  }

  void _emitData() {
    widget.onDataChanged?.call(
      _controllers
          .map((row) => row.map((controller) => controller.text).toList())
          .toList(),
    );
  }

  void _advanceFrom(int row, int column) {
    if (column < _cols - 1) {
      _focusNodes[row][column + 1].requestFocus();
      return;
    }
    if (row < _rows - 1) {
      _focusNodes[row + 1][0].requestFocus();
      return;
    }

    setState(() {
      _controllers.add(List.generate(_cols, (_) => _newController()));
      _focusNodes.add(List.generate(_cols, (_) => FocusNode()));
    });
    _emitData();
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.last.first.requestFocus();
    });
  }

  void _addColumn() {
    setState(() {
      for (var row = 0; row < _rows; row++) {
        _controllers[row].add(_newController());
        _focusNodes[row].add(FocusNode());
      }
    });
    _emitData();
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.last.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    for (final row in _focusNodes) {
      for (final node in row) {
        node.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    final availableWidth = MediaQuery.sizeOf(context).width - 40;
    final tableWidth = (_cols * 132.0).clamp(132.0, availableWidth);

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: tableWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(132),
                  border: TableBorder.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 0.7,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  children: List.generate(
                    _rows,
                    (r) => TableRow(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      children: List.generate(_cols, (c) => _buildCell(r, c)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -9,
              right: widget.onRemove == null ? -8 : 20,
              child: Semantics(
                label: 'Add table column',
                button: true,
                child: Tooltip(
                  message: 'Add column',
                  child: GestureDetector(
                    onTap: _addColumn,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF181819),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(Icons.add_rounded, size: 14, color: accent),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.onRemove != null)
              Positioned(
                top: -9,
                right: -8,
                child: Semantics(
                  label: 'Remove table',
                  button: true,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF181819),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(Icons.close_rounded, size: 13, color: accent),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int row, int column) {
    final isHeader = row == 0;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 42),
      child: Semantics(
        label: isHeader
            ? 'Table heading, row ${row + 1}, column ${column + 1}'
            : 'Table cell, row ${row + 1}, column ${column + 1}',
        textField: true,
        child: TextField(
          key: ValueKey('table_cell_${row}_$column'),
          controller: _controllers[row][column],
          focusNode: _focusNodes[row][column],
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.35,
            fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
            color: isHeader ? Colors.white : const Color(0xFFE2E2E4),
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _advanceFrom(row, column),
          decoration: InputDecoration(
            filled: false,
            hintText: isHeader ? 'Heading' : '',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.22),
              fontSize: 13,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }
}
