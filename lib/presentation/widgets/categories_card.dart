import "package:flutter/material.dart";

class CategoriesCard extends StatelessWidget {
  const CategoriesCard({
    super.key,
    required this.text,
    required this.onCategoryClicked,
  });

  final String text;

  final void Function(String category) onCategoryClicked;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onCategoryClicked(text);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.inversePrimary,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(text),
      ),
    );
  }
}
