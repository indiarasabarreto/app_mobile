import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- MODELO ---
class Task {
  final int id;
  final String title;
  final String section;
  final String responsible;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.section,
    required this.responsible,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['titulo'] ?? json['title'] ?? '',
      section: json['setor'] ?? json['section'] ?? 'Geral',
      responsible: json['responsavel'] ?? json['responsible'] ?? '',
      completed: json['concluido'] ?? json['completed'] ?? false,
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // AQUI DEFINIMOS O TEMA GLOBAL
    theme: ThemeData(
      primaryColor: const Color(0xFF006494),
      scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Fundo levemente acinzentado
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF006494),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    home: LoginScreen(),
  ));
}

// --- TELA DE LOGIN ESTILIZADA ---
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api-token-auth/'),
      body: {
        'username': _userController.text,
        'password': _passController.text,
      },
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen(token: token)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha incorretos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006494), Color(0xFF0582CA)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cleaning_services, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            const Text("Equipe de Limpeza", 
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _userController,
                        decoration: const InputDecoration(labelText: 'Usuário', prefixIcon: Icon(Icons.person)),
                      ),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock)),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006494),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => login(context),
                          child: const Text("ENTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA DA LISTA ESTILIZADA ---
class TodoListScreen extends StatefulWidget {
  final String token;
  const TodoListScreen({super.key, required this.token});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchTasks();
  }

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/tasks/'),
      headers: {'Authorization': 'Token ${widget.token}'},
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Erro ao carregar servidor');
    }
  }

  Future<void> addTask(String title, String sector, String resp) async {
    await http.post(
      Uri.parse('http://127.0.0.1:8000/api/tasks/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${widget.token}',
      },
      body: jsonEncode({'titulo': title, 'setor': sector, 'responsavel': resp}),
    );
    setState(() { futureTasks = fetchTasks(); });
  }

  Future<void> toggleTaskStatus(int id, bool currentStatus) async {
    await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/tasks/$id/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${widget.token}',
      },
      body: jsonEncode({'concluido': !currentStatus}),
    );
    setState(() { futureTasks = fetchTasks(); });
  }

  void _showAddDialog() {
    TextEditingController t = TextEditingController();
    TextEditingController s = TextEditingController();
    TextEditingController r = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: t, decoration: const InputDecoration(labelText: "O que limpar?")),
            TextField(controller: s, decoration: const InputDecoration(labelText: "Setor")),
            TextField(controller: r, decoration: const InputDecoration(labelText: "Responsável")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              addTask(t.text, s.text, r.text);
              Navigator.pop(context);
            }, 
            child: const Text('Salvar')
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
          )
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final task = snapshot.data![index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    leading: CircleAvatar(
                      backgroundColor: task.completed ? Colors.green.shade100 : Colors.blue.shade100,
                      child: Icon(
                        task.completed ? Icons.check : Icons.cleaning_services,
                        color: task.completed ? Colors.green : const Color(0xFF006494),
                      ),
                    ),
                    title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${task.section} • ${task.responsible}"),
                    trailing: Checkbox(
                      value: task.completed,
                      activeColor: Colors.green,
                      onChanged: (val) => toggleTaskStatus(task.id, task.completed),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006494),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}