import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../ui/common.dart';
import '../../ui/widgets.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    title: 'Altro',
    children: [
      Panel(
        child: Column(
          children: [
            for (final s in MoreSection.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(s.icon),
                title: Text(s.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(Routes.moreSection(s)),
              ),
          ],
        ),
      ),
    ],
  );
}
