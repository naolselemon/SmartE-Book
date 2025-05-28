import "package:flutter/material.dart";

class AuthorsImages extends StatelessWidget {
  const AuthorsImages({super.key, required this.image, required this.name});

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            foregroundImage: image.isNotEmpty ? NetworkImage(image) : null,

            child: image.isEmpty ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(height: 4),
          Text(
            name.isNotEmpty ? name : 'Unknown',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
