import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:quick_task/screens/home_screen.dart';

class EditTaskScreen extends StatelessWidget {
  final Task task;
  final TextEditingController titleController;
  final TextEditingController dueDateController;

  EditTaskScreen({required this.task})
      : titleController = TextEditingController(text: task.title),
        dueDateController =
            TextEditingController(text: task.dueDate.toIso8601String());

  // Method to check if the task is completed
  bool get isTaskCompleted => task.status; // Use 'status' instead of 'completed'

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task.dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      dueDateController.text = pickedDate.toIso8601String();
    }
  }

  Future<bool> updateTask(
      String objectId, String title, DateTime dueDate) async {
    final parseObject = ParseObject('Task')
      ..objectId = objectId
      ..set('title', title)
      ..set('dueDate', dueDate);

    final response = await parseObject.save();
    return response.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTaskCompleted) // Display a message if the task is completed
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'This task is completed and cannot be edited.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 30),
              Text(
                'Task Title',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                style: TextStyle(fontSize: 16),
                readOnly: isTaskCompleted, // Make the title field read-only if the task is completed
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter Task Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Due Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: dueDateController,
                readOnly: isTaskCompleted, // Make the date field read-only if the task is completed
                onTap: isTaskCompleted ? null : () => _selectDate(context), // Disable date picker if the task is completed
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Select Due Date',
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isTaskCompleted
                    ? null // Disable the button if the task is completed
                    : () async {
                        final updatedTitle = titleController.text.trim();
                        final updatedDueDate =
                            DateTime.parse(dueDateController.text.trim());

                        final success = await updateTask(
                            task.objectId, updatedTitle, updatedDueDate);

                        if (success) {
                          Navigator.pop(context, true); // Go back after successful update
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update task.')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Correct parameter name
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
