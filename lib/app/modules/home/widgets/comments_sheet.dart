import 'package:eprs/app/modules/home/controllers/home_controller.dart';
import 'package:eprs/app/modules/home/widgets/comment_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentsSheet extends StatelessWidget {
  final Post post;
  final HomeController controller;

  const CommentsSheet({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final commentCtrl = TextEditingController();
    final focusNode = FocusNode();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<HomeController>(
        builder: (ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${post.comments} Comments',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(post.profileImage),
              ),
              title: Text(
                post.userName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ctrl.getCommentsForPost(post.id).isEmpty
                  ? const Center(
                      child: Text(
                        'No comments yet',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ctrl.getCommentsForPost(post.id).length,
                      itemBuilder: (_, i) {
                        final comment = ctrl.getCommentsForPost(post.id)[i];
                        return CommentTile(
                          comment: comment,
                          controller: ctrl,
                          onReply: (replyText) {
                            ctrl.addReply(comment.id, replyText);
                          },
                        );
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (commentCtrl.text.trim().isNotEmpty) {
                        ctrl.addComment(post.id, commentCtrl.text.trim());
                        commentCtrl.clear();
                        focusNode.unfocus();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
