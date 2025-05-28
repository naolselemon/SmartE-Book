import 'package:flutter/material.dart';

class CategoriesCard extends StatelessWidget {
  const CategoriesCard({
    super.key,
    required this.text,
    required this.onCategoryClicked,
    required this.isSelected,
  });

  final String text;
  final void Function(String category) onCategoryClicked;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onCategoryClicked(text);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.inversePrimary,
        ),
        foregroundColor: WidgetStateProperty.all(
          isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side:
                isSelected
                    ? BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(text),
      ),
    );
  }
}
