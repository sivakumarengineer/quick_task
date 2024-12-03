import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:quick_task/screens/edit_screen.dart';

class Task {
  final String objectId;
  final String title;
  final DateTime dueDate;
  bool status;

  Task({
    required this.objectId,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromParse(ParseObject parseObject) {
    return Task(
      objectId: parseObject.objectId!,
      title: parseObject.get<String>('title') ?? '',
      dueDate: parseObject.get<DateTime>('dueDate') ?? DateTime.now(),
      status: parseObject.get<bool>('isCompleted') ?? false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen initializes
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await fetchTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<List<Task>> fetchTasks() async {
    try {
      final currentUser = await ParseUser.currentUser();
      if (currentUser == null) {
        return [];
      }

      final query = QueryBuilder(ParseObject('Task'))..orderByDescending('dueDate');
      final response = await query.query();

      if (response.success && response.results != null) {
        return (response.results as List<ParseObject>)
            .map((e) => Task.fromParse(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteTask(String objectId) async {
    final task = ParseObject('Task')..objectId = objectId;
    final response = await task.delete();
    return response.success;
  }

  Future<bool> toggleTaskStatus(String objectId, bool currentStatus) async {
    final task = ParseObject('Task')..objectId = objectId;
    task.set('isCompleted', !currentStatus);
    final response = await task.save();
    return response.success;
  }

  // Logout function
  Future<void> logout(BuildContext context) async {
  final currentUser = await ParseUser.currentUser();
  if (currentUser != null) {
    await currentUser.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully logged out'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
        actions: [
          // Logout button in the AppBar
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade200, Colors.blue.shade300],
          ),
        ),
        child: FutureBuilder<List<Task>>(
          future: fetchTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading tasks'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No tasks available', style: TextStyle(fontSize: 18, color: Colors.white)));
            } else {
              final tasks = snapshot.data!;
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(task.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Due: ${task.dueDate.toLocal()}'),
                      leading: CircleAvatar(
                        backgroundColor: task.status ? Colors.green : Colors.red,
                        child: Icon(
                          task.status ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.status,
                            onChanged: (value) async {
                              final success = await toggleTaskStatus(task.objectId, task.status);
                              if (success) {
                                setState(() {
                                  task.status = !task.status;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(task: task),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _loadTasks(); // Reload the tasks to reflect changes
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final success = await deleteTask(task.objectId);
                              if (success) {
                                setState(() {
                                  tasks.remove(task);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTask');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
