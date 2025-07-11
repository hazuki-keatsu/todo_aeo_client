import 'package:flutter/material.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String title;
  final String description;
  final int isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Checkbox(
            value: isCompleted == 1,
            onChanged: (value) {
              value = value;
            },
          ),
          Expanded(child: Column(
            children: [
              Text(title),
              Text(description),
              Row(
                children: [
                  Text("${createdAt.year}-${createdAt.month}-${createdAt.day} ${createdAt.hour}:${createdAt.minute}"),
                  Spacer(),
                  Text("${updatedAt.year}-${updatedAt.month}-${updatedAt.day} ${updatedAt.hour}:${updatedAt.minute}"),
                ],
              )
            ],
          )),
          IconButton(onPressed: () {}, icon: Icon(Icons.more))
        ],
      ),
    );
  }
}
