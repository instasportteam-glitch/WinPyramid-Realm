import 'package:flutter/material.dart';

class Exercise {
  final String name, dose, instruction;
  const Exercise(this.name, this.dose, this.instruction);
}

class TrainingSection {
  final String title, type, subtitle;
  final IconData icon;
  final List<Exercise> exercises;
  const TrainingSection(
    this.title,
    this.type,
    this.subtitle,
    this.icon,
    this.exercises,
  );
}

const trainingSections = [
  TrainingSection('Full-body strength', 'Strength', '30 min · Moderate', Icons.fitness_center, [
    Exercise(
      'Bodyweight squat',
      '2–3 sets · 8–12 reps',
      'Stand with feet about shoulder-width apart. Sit your hips back, bend your knees, then push through your feet to stand.',
    ),
    Exercise(
      'Wall push-up',
      '2–3 sets · 8–12 reps',
      'Place your hands on a wall at shoulder height. Keep your body straight as you bend your elbows and press away.',
    ),
    Exercise(
      'Reverse lunge',
      '2 sets · 6–10 reps per side',
      'Step one foot back and lower both knees within a comfortable range. Press through the front foot to return.',
    ),
    Exercise(
      'Glute bridge',
      '2–3 sets · 10–15 reps',
      'Lie on your back with knees bent and feet flat. Squeeze your glutes to lift your hips without arching your lower back.',
    ),
    Exercise(
      'Dumbbell row',
      '2–3 sets · 8–12 reps per side',
      'Support one hand on a stable bench. Keep your back neutral and pull a light dumbbell toward your hip, then lower slowly.',
    ),
    Exercise(
      'Dumbbell floor press',
      '2–3 sets · 8–12 reps',
      'Lie on the floor holding light dumbbells above your chest. Lower until your upper arms gently touch the floor, then press up.',
    ),
    Exercise(
      'Hip hinge',
      '2–3 sets · 10 reps',
      'Keep your knees soft and push your hips back with a neutral spine. Stand tall by bringing your hips forward.',
    ),
    Exercise(
      'Standing calf raise',
      '2–3 sets · 12–15 reps',
      'Hold a stable support for balance. Lift your heels, pause briefly, and lower with control.',
    ),
    Exercise(
      'Forearm plank',
      '2–3 rounds · 15–30 sec',
      'Place elbows under shoulders. Keep your body in a straight line and breathe steadily; lower your knees to make it easier.',
    ),
    Exercise(
      'Dead bug',
      '2 sets · 6–10 reps per side',
      'Lie on your back with arms up and knees bent. Slowly extend the opposite arm and leg while keeping your lower back steady.',
    ),
    Exercise(
      'Bird dog',
      '2 sets · 6–10 reps per side',
      'Start on hands and knees. Extend one arm and the opposite leg without rotating your hips, then return slowly.',
    ),
    Exercise(
      'Side-lying leg raise',
      '2 sets · 10–12 reps per side',
      'Lie on your side with hips stacked. Lift the top leg a short distance without rolling backward, then lower slowly.',
    ),
  ]),
  TrainingSection('Royal endurance', 'Cardio', '25 min · Cardio', Icons.directions_run, [
    Exercise(
      'Brisk walk',
      '5–20 min · Comfortable pace',
      'Walk tall with relaxed shoulders and a natural arm swing. Choose a pace at which you can still speak in sentences.',
    ),
    Exercise(
      'March in place',
      '3 rounds · 45 sec',
      'Alternate lifting your knees at a comfortable height. Swing your arms and place each foot down softly.',
    ),
    Exercise(
      'Step jack',
      '3 rounds · 30–45 sec',
      'Step one foot out while raising your arms, then return and switch sides. Keep one foot on the ground.',
    ),
    Exercise(
      'Side step',
      '3 rounds · 45 sec',
      'Step sideways and bring the other foot toward it. Move both directions with soft knees and a steady rhythm.',
    ),
    Exercise(
      'Low-impact skater',
      '3 rounds · 30 sec',
      'Step diagonally back behind the opposite leg, then switch sides. Keep the motion controlled without jumping.',
    ),
    Exercise(
      'Shadow boxing',
      '3 rounds · 1 min',
      'Stand with soft knees and hands near your chin. Alternate relaxed punches without locking your elbows.',
    ),
    Exercise(
      'Standing knee drive',
      '3 rounds · 30 sec per side',
      'Lift one knee toward your waist, then lower and repeat. Use a stable support if needed and keep your torso upright.',
    ),
    Exercise(
      'Heel dig',
      '3 rounds · 45 sec',
      'Alternate tapping each heel in front of you. Keep a small bend in your supporting knee and swing your arms.',
    ),
    Exercise(
      'Low step-up',
      '2–3 rounds · 1 min',
      'Use a low, stable step. Place your whole foot on it, step up, and step down carefully. Alternate the leading leg.',
    ),
    Exercise(
      'Stationary cycling',
      '5–20 min · Easy resistance',
      'Adjust the saddle so your knee stays slightly bent at the bottom of the pedal stroke. Pedal smoothly at a comfortable pace.',
    ),
    Exercise(
      'Easy jog',
      '5 rounds · 1 min jog / 1 min walk',
      'Jog with short, relaxed steps on an even surface. Walk between intervals and reduce the pace if you cannot talk comfortably.',
    ),
    Exercise(
      'Standing cross-body reach',
      '3 rounds · 45 sec',
      'Step gently side to side while reaching the opposite arm across your body. Turn through your upper body without forcing the motion.',
    ),
  ]),
  TrainingSection('Recovery & mobility', 'Mobility', '15 min · Light', Icons.self_improvement, [
    Exercise(
      'Cat–cow',
      '1–2 sets · 6–10 slow reps',
      'On hands and knees, gently round your back and then lengthen through your chest. Move slowly with your breath.',
    ),
    Exercise(
      'Child’s pose',
      '2 rounds · 20–30 sec',
      'From hands and knees, ease your hips back toward your heels and reach forward. Use only a comfortable range.',
    ),
    Exercise(
      'Open book rotation',
      '6–8 reps per side',
      'Lie on your side with knees bent and arms forward. Open the top arm toward the other side while keeping your knees together.',
    ),
    Exercise(
      'Seated ankle circles',
      '10 circles each direction per side',
      'Sit comfortably and lift one foot. Slowly circle your ankle in both directions without moving your whole leg.',
    ),
    Exercise(
      'Wall calf stretch',
      '2 rounds · 20 sec per side',
      'Place your hands on a wall and step one foot back. Keep the back heel down and gently bend the front knee.',
    ),
    Exercise(
      'Seated hamstring stretch',
      '2 rounds · 20 sec per side',
      'Sit near the edge of a stable chair and extend one leg. Hinge forward slightly with a long back until you feel a gentle stretch.',
    ),
    Exercise(
      'Half-kneeling hip flexor stretch',
      '2 rounds · 20 sec per side',
      'Kneel on a cushion with one foot forward. Keep your trunk tall and gently shift your hips forward without arching your back.',
    ),
    Exercise(
      'Supine figure-four stretch',
      '2 rounds · 20 sec per side',
      'Lie on your back and rest one ankle over the opposite thigh. Gently bring the supporting thigh closer without pulling on your knee.',
    ),
    Exercise(
      'Doorway chest stretch',
      '2 rounds · 20 sec',
      'Place your forearms on a doorway below shoulder height. Step forward slightly until you feel a gentle stretch across your chest.',
    ),
    Exercise(
      'Shoulder rolls',
      '10 circles each direction',
      'Stand or sit tall. Slowly roll your shoulders up, back, and down, then reverse direction.',
    ),
    Exercise(
      'Wrist circles',
      '10 circles each direction',
      'Keep your forearms relaxed and make small, slow circles with both wrists. Avoid pushing into discomfort.',
    ),
    Exercise(
      'Supine knee rolls',
      '6–10 slow reps per side',
      'Lie on your back with feet flat and knees bent. Gently move both knees a short distance side to side while keeping your shoulders down.',
    ),
  ]),
];

class ExerciseLibrary extends StatelessWidget {
  final TrainingSection section;
  const ExerciseLibrary(this.section, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(section.title)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${section.exercises.length} exercises',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose an exercise to see the technique and suggested amount. Adjust to your level and stop if a movement hurts.',
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, section.title),
          child: const Text('Log a full session'),
        ),
        const SizedBox(height: 16),
        for (final exercise in section.exercises)
          Card(
            child: ExpansionTile(
              key: PageStorageKey(exercise.name),
              title: Text(exercise.name),
              subtitle: Text(exercise.dose),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.instruction),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, exercise.name),
                  icon: const Icon(Icons.add),
                  label: const Text('Log this exercise'),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
