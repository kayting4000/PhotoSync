import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/subject.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchSubjects();
    });
  }

  void _showAddDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    int units = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Subject Code'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                ),
                const SizedBox(height: 16),
                DropdownButton<int>(
                  value: units,
                  isExpanded: true,
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1} Unit${index > 0 ? 's' : ''}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => units = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final subject = Subject(
                  code: codeController.text,
                  name: nameController.text,
                  units: units,
                );

                final success =
                    await context.read<SubjectProvider>().addSubject(subject);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject added successfully')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      body: Consumer<SubjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a subject to get started'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) {
              final subject = provider.subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(subject.code[0].toUpperCase()),
                  ),
                  title: Text(subject.name),
                  subtitle: Text('${subject.code} • ${subject.units} unit(s)'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () {
                          context
                              .read<SubjectProvider>()
                              .deleteSubject(subject.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
