import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A fully interactive inline table, Apple Notes style.
/// Renders as editable cells with add-row and add-column controls.
class InlineNoteTable extends StatefulWidget {
  final int initialRows;
  final int initialCols;
  final ValueChanged<List<List<String>>>? onDataChanged;
  final List<List<String>> initialData;
  final VoidCallback? onRemove;

  const InlineNoteTable({
    super.key,
    this.initialRows = 3,
    this.initialCols = 3,
    this.onDataChanged,
    this.initialData = const [],
    this.onRemove,
  });

  @override
  State<InlineNoteTable> createState() => _InlineNoteTableState();
}

class _InlineNoteTableState extends State<InlineNoteTable> {
  late List<List<TextEditingController>> _controllers;

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
        final controller = TextEditingController(text: value);
        controller.addListener(_emitData);
        return controller;
      }),
    );
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final ctrl in row) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  int get _rows => _controllers.length;
  int get _cols => _controllers.isNotEmpty ? _controllers.first.length : 0;

  void _emitData() {
    widget.onDataChanged?.call(
      _controllers
          .map((row) => row.map((controller) => controller.text).toList())
          .toList(),
    );
  }

  TextEditingController _newController() {
    final controller = TextEditingController();
    controller.addListener(_emitData);
    return controller;
  }

  void _addRow() {
    setState(() {
      _controllers.add(List.generate(_cols, (_) => _newController()));
    });
    _emitData();
  }

  void _addColumn() {
    setState(() {
      for (final row in _controllers) {
        row.add(_newController());
      }
    });
    _emitData();
  }

  void _removeRow(int index) {
    if (_rows <= 1) return;
    setState(() {
      for (final ctrl in _controllers[index]) {
        ctrl.dispose();
      }
      _controllers.removeAt(index);
    });
    _emitData();
  }

  void _removeCol(int index) {
    if (_cols <= 1) return;
    setState(() {
      for (final row in _controllers) {
        row[index].dispose();
        row.removeAt(index);
      }
    });
    _emitData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3A3A42), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row label
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  size: 14,
                  color: Color(0xFF8E8E93),
                ),
                const SizedBox(width: 6),
                Text(
                  "Table",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const Spacer(),
                // Remove table button
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF636366),
                  ),
                ),
              ],
            ),
          ),

          // Table grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column header row with delete buttons
                Row(
                  children: [
                    const SizedBox(width: 8),
                    ...List.generate(_cols, (c) => _buildColHeader(c)),
                    const SizedBox(width: 8),
                  ],
                ),

                // Data rows
                ...List.generate(_rows, (r) => _buildRow(r)),
              ],
            ),
          ),

          // Footer: Add Row / Add Column buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: Row(
              children: [
                _addButton(
                  icon: Icons.add_rounded,
                  label: "+ Row",
                  onTap: _addRow,
                ),
                const SizedBox(width: 8),
                _addButton(
                  icon: Icons.add_rounded,
                  label: "+ Column",
                  onTap: _addColumn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColHeader(int c) {
    return SizedBox(
      width: 110,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_cols > 1)
              GestureDetector(
                onTap: () => _removeCol(c),
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Color(0xFF636366),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int r) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 8),
          ...List.generate(_cols, (c) => _buildCell(r, c)),
          // Delete row button
          if (_rows > 1)
            GestureDetector(
              onTap: () => _removeRow(r),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 14,
                  color: Color(0xFF636366),
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final isHeader = r == 0;
    return Container(
      width: 110,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF3A3A42), width: 0.8),
      ),
      child: TextField(
        controller: _controllers[r][c],
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader ? Colors.white : const Color(0xFFD1D1D6),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          border: InputBorder.none,
          hintText: isHeader ? "Header" : "Cell",
          hintStyle: const TextStyle(color: Color(0xFF48484A), fontSize: 12),
        ),
        maxLines: null,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _addButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFFFD60A)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFD60A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
