import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    const MaterialApp(
      home: PlanManagerScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;
  String priority;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = 'Medium',
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  final List<Plan> _plans = [];
  final Map<String, Plan?> assignedPlans = {};
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  void _addPlan(
    String name,
    String description,
    DateTime date,
    String priority,
  ) {
    setState(() {
      _plans.add(
        Plan(
          name: name,
          description: description,
          date: date,
          priority: priority,
        ),
      );
      _plans.sort((a, b) => b.priority.compareTo(a.priority));
    });
  }

  void _editPlan(
    int index,
    String name,
    String description,
    DateTime date,
    String priority,
  ) {
    setState(() {
      _plans[index] = Plan(
        name: name,
        description: description,
        date: date,
        priority: priority,
      );
      _plans.sort((a, b) => b.priority.compareTo(a.priority));
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      _plans[index].isCompleted = !_plans[index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      _plans.removeAt(index);
    });
  }

  void _showPlanDialog({int? index}) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedPriority = 'Medium';

    if (index != null) {
      nameController.text = _plans[index].name;
      descriptionController.text = _plans[index].description;
      selectedDate = _plans[index].date;
      selectedPriority = _plans[index].priority;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Create Plan' : 'Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButton<String>(
                value: selectedPriority,
                items:
                    ['Low', 'Medium', 'High'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              ElevatedButton(
                child: Text('Select Date: ${_dateFormat.format(selectedDate)}'),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (index == null) {
                  _addPlan(
                    nameController.text,
                    descriptionController.text,
                    selectedDate,
                    selectedPriority,
                  );
                } else {
                  _editPlan(
                    index,
                    nameController.text,
                    descriptionController.text,
                    selectedDate,
                    selectedPriority,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('PLAN MANAGER'),
        backgroundColor: Colors.orange,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return Dismissible(
                key: Key(plan.name),
                onDismissed: (_) => _deletePlan(index),
                child: ListTile(
                  title: Text(plan.name),
                  subtitle: Text(
                    '${_dateFormat.format(plan.date)} - ${plan.priority}',
                  ),
                  tileColor:
                      plan.isCompleted ? Colors.green[100] : Colors.white,
                  onLongPress: () => _showPlanDialog(index: index),
                  onTap: () => _toggleCompletion(index),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          GridView.builder(
            padding: EdgeInsets.fromLTRB(20, 400, 20, 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.5,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              String date = 'Mar ${index + 1}';
              return DragTarget<Plan>(
                onAcceptWithDetails: (details) {
                  // Changed parameter to details
                  setState(() {
                    assignedPlans[date] =
                        details.data; // Extract plan from details.data
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(0, 255, 127, 15),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4.0),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(date, style: const TextStyle(fontSize: 14)),
                        if (assignedPlans.containsKey(date))
                          Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              assignedPlans[date]!.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.orange,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showPlanDialog(),
      ),
    );
  }
}
