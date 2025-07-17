import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/show_dialog.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.finishingAt,
    required this.updateCompetedFunction,
  });

  final int id;
  final String title;
  final String description;
  final int isCompleted;
  final DateTime createdAt;
  final DateTime? finishingAt;
  final Function(bool, int?) updateCompetedFunction;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  late bool isCompleted;

  @override
  void initState() {
    isCompleted = widget.isCompleted == 1 ? true : false;
    super.initState();
  }

  void checkboxClick(bool value) {
    setState(() {
      isCompleted = value;
      widget.updateCompetedFunction(value, widget.id);
    });
  }

  // TODO:添加空白区域点击收起Sheet
  void _showOptionsBottomSheet(int id) {
    showBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  leading: Icon(Icons.edit),
                  title: Text('编辑'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 实现编辑对话框
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('删除', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ShowDialog.showDeleteConfirmDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(0, 4, 0, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.2),
              offset: Offset(0, 1),
              blurRadius: 1,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Material(
          color: isCompleted
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {}, // 添加空的onTap以启用涟漪效果
            onLongPress: () => _showOptionsBottomSheet(widget.id),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) => checkboxClick(value ?? false),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: isCompleted
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.description,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryFixed,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "创建：${widget.createdAt.year}-${widget.createdAt.month}-${widget.createdAt.day} ${widget.createdAt.hour}:${widget.createdAt.minute}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryFixedVariant,
                              ),
                            ),
                            Spacer(flex: 3),
                            if (widget.finishingAt != null)
                              Text(
                                "完成：${widget.finishingAt!.year}-${widget.finishingAt!.month}-${widget.finishingAt!.day} ${widget.finishingAt!.hour}:${widget.finishingAt!.minute}",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryFixedVariant,
                                ),
                              ),
                            Spacer(flex: 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
