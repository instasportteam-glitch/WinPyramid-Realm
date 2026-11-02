import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'photos.dart';
import 'exercise_library.dart';

const gold = Color(0xffdfbb78), wine = Color(0xff281019);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Kingdom(await SharedPreferences.getInstance()));
}

class Kingdom extends StatelessWidget {
  final SharedPreferences prefs;
  const Kingdom(this.prefs, {super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Pyramid of Kings',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        primary: gold,
        surface: wine,
      ),
      scaffoldBackgroundColor: wine,
    ),
    home: Home(prefs),
  );
}

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  const Home(this.prefs, {super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0, q = 0;
  String name = 'Your Majesty';
  String? profilePhoto;
  List<Map<String, dynamic>> records = [];
  static const labels = ['Throne', 'Train', 'Daily', 'Stats', 'Profile'];
  static const icons = [
    Icons.workspace_premium_outlined,
    Icons.fitness_center,
    Icons.local_fire_department_outlined,
    Icons.bar_chart,
    Icons.person_outline,
  ];
  static const ranks = ['Peasant', 'Squire', 'Knight', 'Baron', 'Duke', 'King'];
  static const quotes = [
    'A crown is not kept by strength alone, but by showing up every day.',
    'Rule the small hours, and the great days will follow.',
    'The strongest kingdom begins with a promise kept to yourself.',
    'Discipline is the quiet work behind every great reign.',
  ];
  @override
  void initState() {
    super.initState();
    name = widget.prefs.getString('name') ?? name;
    profilePhoto = widget.prefs.getString('profilePhoto');
    q = DateTime.now().difference(DateTime(2026)).inDays % quotes.length;
    try {
      records = (jsonDecode(widget.prefs.getString('records') ?? '[]') as List)
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
    } catch (_) {
      records = [];
    }
  }

  int get points => records.fold(0, (n, r) => n + (r['points'] as int));
  int get tier => min(5, points ~/ 300);
  String key(DateTime d) => '${d.year}-${d.month}-${d.day}';
  int mins(DateTime d) => records
      .where((r) => key(DateTime.parse(r['date'])) == key(d))
      .fold(0, (n, r) => n + (r['minutes'] as int));
  int get streak {
    var d = DateTime.now();
    if (mins(d) == 0) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (mins(d) > 0) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  Future<void> save() async {
    await widget.prefs.setString('records', jsonEncode(records));
  }

  Widget card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: wine.withValues(alpha: .93),
      border: Border.all(color: gold.withValues(alpha: .35)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
  Widget text(String s, [double size = 16]) => Text(
    s,
    style: TextStyle(
      fontFamily: size >= 24 ? 'Georgia' : null,
      fontSize: size,
      color: size >= 24 ? gold : null,
    ),
  );
  Widget heading(String s) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: text(s, 32),
  );
  Widget button(String s, VoidCallback fn) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: fn,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xffb63836),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(18),
      ),
      child: Text(s),
    ),
  );
  Widget progress() => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text('${ranks[tier]} · $points crown points', 24),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: tier == 5 ? 1 : points % 300 / 300),
        const SizedBox(height: 12),
        text(
          tier == 5
              ? 'You have earned your crown.'
              : '${300 - points % 300} points to ${ranks[tier + 1]}',
        ),
      ],
    ),
  );
  Future<void> add([String initial = '', String? trainingType]) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutForm(initial, trainingType: trainingType),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        records.insert(0, result);
        tab = 3;
      });
      await save();
    }
  }

  Widget throne() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heading('Your throne'),
      text('Greatness\nis earned.', 42),
      const SizedBox(height: 18),
      text('$streak days of consistency'),
      const SizedBox(height: 24),
      Center(
        child: SizedBox(
          width: 350,
          height: 230,
          child: CustomPaint(painter: Pyramid(tier)),
        ),
      ),
      const SizedBox(height: 24),
      progress(),
      card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text('TODAY’S DECREE'),
            heading('30 minutes of training'),
            text('${mins(DateTime.now())} / 30 minutes completed'),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: min(1, mins(DateTime.now()) / 30)),
            const SizedBox(height: 20),
            button('Log your workout', () => add()),
          ],
        ),
      ),
    ],
  );
  Widget training() => Column(
    children: [
      heading('Train like a king'),
      progress(),
      ...trainingSections.map(
        (section) => card(
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(section.icon, color: gold),
            title: Text(section.title),
            subtitle: Text(
              '${section.subtitle} · ${section.exercises.length} exercises',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => ExerciseLibrary(section)),
              );
              if (selected != null && mounted) {
                await add(selected, section.type);
              }
            },
          ),
        ),
      ),
      button('Add your workout', () => add()),
    ],
  );
  Widget daily() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heading('Quote of the Day'),
      const SizedBox(height: 80),
      card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, color: gold, size: 48),
            const SizedBox(height: 24),
            text(quotes[q], 32),
            const SizedBox(height: 30),
            text('THE KING’S DAILY DECREE', 12),
          ],
        ),
      ),
      Wrap(
        spacing: 12,
        children: [
          OutlinedButton.icon(
            onPressed: () => setState(() => q = (q + 1) % quotes.length),
            icon: const Icon(Icons.refresh),
            label: const Text('Another thought'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: quotes[q]));
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Quote copied')));
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy quote'),
          ),
        ],
      ),
    ],
  );
  Widget metric(String v, String label) =>
      Expanded(child: Column(children: [text(v, 26), text(label, 11)]));
  Widget stats() {
    final now = DateTime.now();
    final offset = DateTime(now.year, now.month, 1).weekday - 1;
    final days = DateTime(now.year, now.month + 1, 0).day;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Your legacy'),
        card(
          Row(
            children: [
              metric('${records.length}', 'Workouts'),
              metric('$streak', 'Day streak'),
              metric('$points', 'Crown points'),
            ],
          ),
        ),
        card(
          Column(
            children: [
              text(
                '${const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1]} ${now.year}',
                24,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  'M',
                  'T',
                  'W',
                  'T',
                  'F',
                  'S',
                  'S',
                ].map((s) => Expanded(child: Center(child: Text(s)))).toList(),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offset + days,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (_, i) {
                  if (i < offset) return const SizedBox();
                  final n = i - offset + 1;
                  final done = mins(DateTime(now.year, now.month, n)) > 0;
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done ? gold : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: n == now.day
                          ? Border.all(color: gold, width: 2)
                          : null,
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(color: done ? wine : Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        heading('Workout history'),
        if (records.isEmpty)
          card(text('Your story starts with your first workout.')),
        ...records.map(
          (r) => card(
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r['name']),
                  subtitle: Text(
                    '${r['minutes']} min · ${r['intensity']}\n${r['date'].toString().substring(0, 10)}',
                  ),
                  trailing: Text(
                    '+${r['points']}',
                    style: const TextStyle(color: gold),
                  ),
                ),
                PhotoEditor(
                  key: ObjectKey(r),
                  filename: r['photo'] as String?,
                  label: 'workout photo',
                  onChanged: (photo) async {
                    final updated = records
                        .map(
                          (record) => identical(record, r)
                              ? {...record, 'photo': photo}
                              : record,
                        )
                        .toList();
                    if (!await widget.prefs.setString(
                      'records',
                      jsonEncode(updated),
                    )) {
                      throw StateError('Could not save workout photo');
                    }
                    if (mounted) setState(() => r['photo'] = photo);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget profile() => Column(
    children: [
      heading(name),
      if (profilePhoto == null)
        const Icon(Icons.workspace_premium_outlined, size: 100, color: gold),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: PhotoEditor(
          filename: profilePhoto,
          label: 'profile photo',
          onChanged: (photo) async {
            final saved = photo == null
                ? await widget.prefs.remove('profilePhoto')
                : await widget.prefs.setString('profilePhoto', photo);
            if (!saved) throw StateError('Could not save profile photo');
            if (mounted) setState(() => profilePhoto = photo);
          },
        ),
      ),
      const SizedBox(height: 24),
      progress(),
      card(
        TextFormField(
          initialValue: name,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Your name'),
          onChanged: (v) {
            name = v.trim().isEmpty ? 'Your Majesty' : v.trim();
            widget.prefs.setString('name', name);
          },
        ),
      ),
      card(
        text(
          'Every 300 points unlocks a new rank. Your workout records stay on this device.',
        ),
      ),
      OutlinedButton(
        onPressed: () async {
          final yes = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Reset progress?'),
              content: const Text(
                'All saved workouts will be removed from this device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
          if (yes == true && mounted) {
            final photos = records.map((r) => r['photo'] as String?).toList();
            setState(() => records = []);
            await save();
            for (final photo in photos) {
              await PhotoStore.instance.remove(photo);
            }
          }
        },
        child: const Text('Reset progress'),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: OverflowBox(
                maxWidth: double.infinity,
                child: Image.asset(
                  'assets/palaces.png',
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: .68)),
          ),
          SafeArea(
            child: Row(
              children: [
                if (wide)
                  NavigationRail(
                    selectedIndex: tab,
                    onDestinationSelected: (i) => setState(() => tab = i),
                    labelType: NavigationRailLabelType.all,
                    destinations: List.generate(
                      5,
                      (i) => NavigationRailDestination(
                        icon: Icon(icons[i]),
                        label: Text(labels[i]),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey(tab),
                    padding: EdgeInsets.all(wide ? 40 : 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'PYRAMID of\nK I N G S',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 20,
                                  color: gold,
                                ),
                              ),
                            ),
                            [throne, training, daily, stats, profile][tab](),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              destinations: List.generate(
                5,
                (i) => NavigationDestination(
                  icon: Icon(icons[i]),
                  label: labels[i],
                ),
              ),
            ),
    );
  }
}

class Pyramid extends CustomPainter {
  final int tier;
  Pyramid(this.tier);
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 6; i++) {
      final top = i * size.height / 6, bottom = (i + 1) * size.height / 6 - 2;
      final path = Path()
        ..moveTo(size.width / 2 - top / size.height * size.width / 2, top)
        ..lineTo(size.width / 2 + top / size.height * size.width / 2, top)
        ..lineTo(size.width / 2 + bottom / size.height * size.width / 2, bottom)
        ..lineTo(size.width / 2 - bottom / size.height * size.width / 2, bottom)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = 5 - i == tier ? gold : const Color(0xff622733),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = gold
          ..style = PaintingStyle.stroke,
      );
      final t = TextPainter(
        text: TextSpan(
          text: ['King', 'Duke', 'Baron', 'Knight', 'Squire', 'Peasant'][i],
          style: TextStyle(
            fontSize: i == 0 ? 10 : 13,
            color: 5 - i == tier ? wine : Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      t.paint(
        canvas,
        Offset((size.width - t.width) / 2, top + (i == 0 ? 22 : 12)),
      );
    }
  }

  @override
  bool shouldRepaint(Pyramid old) => tier != old.tier;
}

class WorkoutForm extends StatefulWidget {
  final String initial;
  final String? trainingType;
  const WorkoutForm(this.initial, {super.key, this.trainingType});
  @override
  State<WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<WorkoutForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name;
  double minutes = 30;
  String? photo;
  bool photoBusy = false, submitted = false;
  String intensity = 'Moderate', type = 'Strength';
  int get points =>
      (minutes *
              (intensity == 'Hard'
                  ? 2
                  : intensity == 'Moderate'
                  ? 1.5
                  : 1))
          .round();
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initial);
    type = widget.trainingType ?? type;
    if (type == 'Mobility' || widget.initial == 'Recovery & mobility') {
      minutes = 15;
      intensity = 'Light';
      type = 'Mobility';
    }
    if (type == 'Cardio' || widget.initial == 'Royal endurance') {
      minutes = 25;
      type = 'Cardio';
    }
  }

  @override
  void dispose() {
    if (!submitted) unawaited(PhotoStore.instance.remove(photo));
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New workout')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: name,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Workout name'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter a workout name'
                      : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Training type'),
                  items: ['Strength', 'Cardio', 'Mobility', 'Other']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v!),
                ),
                const SizedBox(height: 25),
                Text(
                  'Duration: ${minutes.round()} min',
                  style: const TextStyle(fontSize: 22),
                ),
                Slider(
                  value: minutes,
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: '${minutes.round()} min',
                  onChanged: (v) => setState(() => minutes = v),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: intensity,
                  decoration: const InputDecoration(labelText: 'Intensity'),
                  items: ['Light', 'Moderate', 'Hard']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => intensity = v!),
                ),
                const SizedBox(height: 24),
                PhotoEditor(
                  filename: photo,
                  label: 'workout photo',
                  onChanged: (value) async {
                    setState(() => photo = value);
                  },
                  onBusyChanged: (value) => setState(() => photoBusy = value),
                ),
                const SizedBox(height: 32),
                Text(
                  '+$points crown points',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    color: gold,
                  ),
                ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: photoBusy
                      ? null
                      : () {
                          if (form.currentState!.validate()) {
                            submitted = true;
                            Navigator.pop(context, {
                              'name': name.text.trim(),
                              if (photo != null) 'photo': photo,
                              'type': type,
                              'minutes': minutes.round(),
                              'intensity': intensity,
                              'points': points,
                              'date': DateTime.now().toIso8601String(),
                            });
                          }
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Save completed workout'),
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
