// document_chat_page.dart
// Full-screen grounded document and notebook chat with tappable citations.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/source_citation.dart';

class DocumentChatPage extends StatefulWidget {
  final String title;
  final String sourceId;
  final bool isDocument; // true=single document, false=notebook/all-notes

  /// Ask function from either AskDocumentUseCase or AskNotebookUseCase.
  final Future<GroundedResponse> Function(String question) onAsk;

  /// Called when user taps a citation — navigate to page or note.
  final void Function(SourceCitation citation)? onCitationTapped;

  const DocumentChatPage({
    super.key,
    required this.title,
    required this.sourceId,
    required this.isDocument,
    required this.onAsk,
    this.onCitationTapped,
  });

  @override
  State<DocumentChatPage> createState() => _DocumentChatPageState();
}

class _DocumentChatPageState extends State<DocumentChatPage> {
  final _messages = <_ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isLoading) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(role: _MessageRole.user, text: question));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await widget.onAsk(question);
      setState(() {
        _messages.add(_ChatMessage(
          role: _MessageRole.assistant,
          text: response.displayText,
          citations: response.orderedCitations,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: _MessageRole.assistant,
          text: 'Sorry, something went wrong. Please try again.',
          isError: true,
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.white70,
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.isDocument ? 'Document Chat' : 'Notebook Q&A',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) return _buildThinking();
                      return _MessageBubble(
                        message: _messages[i],
                        onCitationTapped: widget.onCitationTapped,
                      );
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6B5CFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 36, color: Color(0xFF6B5CFF)),
            ),
            const SizedBox(height: 20),
            Text(
              'Ask anything about ${widget.isDocument ? "this document" : "your notes"}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Every answer is grounded in your content with tappable citations.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white38,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinking() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF6B5CFF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 14, color: Color(0xFF6B5CFF)),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFF1E1E22),
              valueColor:
                  AlwaysStoppedAnimation(Color(0xFF6B5CFF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D10),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151518),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                cursorColor: const Color(0xFF6B5CFF),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ask a question…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isLoading
                    ? Colors.white12
                    : const Color(0xFF6B5CFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 18,
                color: _isLoading ? Colors.white30 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────

enum _MessageRole { user, assistant }

class _ChatMessage {
  final _MessageRole role;
  final String text;
  final List<SourceCitation> citations;
  final bool isError;

  _ChatMessage({
    required this.role,
    required this.text,
    this.citations = const [],
    this.isError = false,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final void Function(SourceCitation)? onCitationTapped;

  const _MessageBubble({
    required this.message,
    this.onCitationTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF6B5CFF).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: Color(0xFF6B5CFF)),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF6B5CFF).withOpacity(0.2)
                        : message.isError
                            ? const Color(0xFFFF6B6B).withOpacity(0.1)
                            : const Color(0xFF151518),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isUser ? 14 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 14),
                    ),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFF6B5CFF).withOpacity(0.3)
                          : Colors.white10,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: message.isError
                          ? const Color(0xFFFF6B6B)
                          : Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                if (message.citations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: message.citations.map((c) {
                      return GestureDetector(
                        onTap: () => onCitationTapped?.call(c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B5CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  const Color(0xFF6B5CFF).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.link_rounded,
                                  size: 10, color: Color(0xFF6B5CFF)),
                              const SizedBox(width: 4),
                              Text(
                                '[${c.citationKey}] ${c.sourceTitle}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B5CFF),
                                ),
                              ),
                              if (c.hasPageLocation) ...[
                                const SizedBox(width: 4),
                                Text(
                                  'p.${c.pageStart}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 38),
        ],
      ),
    );
  }
}
