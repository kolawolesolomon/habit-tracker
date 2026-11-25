import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(home: Habits()));

class Habits extends StatefulWidget {
  const Habits({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<Habits> createState() => _HabitsState();
}

class _HabitsState extends State<Habits> with WidgetsBindingObserver {
  final input = TextEditingController();
  Map<String, String> habits = {};
  SharedPreferences? prefs;
  late String displayedDate = today;
  Timer? dateCheck;

  String get today => widget.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    dateCheck = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshDate(),
    );
    load();
  }

  void refreshDate() {
    final date = today;
    if (date != displayedDate) {
      setState(() => displayedDate = date);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshDate();
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      prefs = preferences;
      habits = Map<String, String>.from(
        jsonDecode(preferences.getString('habits') ?? '{}'),
      );
    });
  }

  void save() {
    prefs?.setString('habits', jsonEncode(habits));
  }

  void addHabit() {
    final name = input.text.trim();
    if (name.isEmpty || habits.containsKey(name)) return;
    setState(() => habits[name] = '');
    input.clear();
    save();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dateCheck?.cancel();
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = displayedDate = today;
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      body: prefs == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: input,
                          decoration: const InputDecoration(
                            labelText: 'New habit',
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add habit',
                        icon: const Icon(Icons.add),
                        onPressed: addHabit,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${habits.values.where((day) => day == date).length} / ${habits.length} completed today',
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final name in habits.keys)
                        CheckboxListTile(
                          key: ValueKey(name),
                          title: Text(name),
                          value: habits[name] == date,
                          onChanged: (checked) {
                            setState(
                              () => habits[name] = checked == true ? today : '',
                            );
                            save();
                          },
                          secondary: IconButton(
                            tooltip: 'Delete habit',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() => habits.remove(name));
                              save();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
