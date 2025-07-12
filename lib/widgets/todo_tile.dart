import 'package:flutter/material.dart';


class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.updateCompetedFunction,
  });

  final int? id;
  final String title;
  final String description;
  final int isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Function(bool, int) updateCompetedFunction;

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
      if (widget.id != null) {
        widget.updateCompetedFunction(value, widget.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(0, 1),
              blurRadius: 1,
              spreadRadius: 0.5,
            ),
          ],
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 20
                    ),
                  ),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryFixed,
                      fontWeight: FontWeight.w400,
                      fontSize: 16
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
                      Spacer(flex: 3,),
                      Text(
                        "完成：${widget.updatedAt.year}-${widget.updatedAt.month}-${widget.updatedAt.day} ${widget.updatedAt.hour}:${widget.updatedAt.minute}",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryFixedVariant,
                        ),
                      ),
                      Spacer(flex: 1,)
                    ],
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
