import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELO ---
class Task {
  final int id;
  final String title;
  final String section;
  final String responsible;
  final bool completed;
  final String? madeBy;

  Task({
    required this.id,
    required this.title,
    required this.section,
    required this.responsible,
    required this.completed,
    this.madeBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['titulo'] ?? json['title'] ?? '',
      section: json['setor'] ?? json['section'] ?? 'Geral',
      responsible: json['responsavel'] ?? json['responsible'] ?? '',
      completed: json['concluido'] ?? json['completed'] ?? false,
      madeBy: json['made_by'] ?? json['madeBy'],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // AQUI DEFINIMOS O TEMA GLOBAL
      theme: ThemeData(
        primaryColor: const Color(0xFF006494),
        scaffoldBackgroundColor: const Color(
          0xFFF0F4F8,
        ), // Fundo levemente acinzentado
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF006494),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: LoginScreen(),
    ),
  );
}

// --- TELA DE LOGIN ESTILIZADA ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> login(BuildContext context) async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.15.18:8000/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _userController.text,
          'password': _passController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', data['access']);
        await prefs.setString('refresh', data['refresh']);
        await prefs.setString('username', _userController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodoListScreen(token: data['access']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha incorretos!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão com o servidor')),
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
            const Text(
              "Equipe de Limpeza",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006494),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => login(context),
                          child: const Text(
                            "ENTRAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  String? userName;
  bool isAdmin = false;
  final String adminName = "Indiara Sá Barreto";

  @override
  void initState() {
    super.initState();
    loadUser();
    checkUserName();
    futureTasks = fetchTasks();
  }

  Future<void> checkUserName() async {
    final prefs = await SharedPreferences.getInstance();

    String? name = prefs.getString('username');

    if (name == null || name.isEmpty) {
      Future.delayed(Duration.zero, () {
        showNameDialog();
      });
  }
}
void showNameDialog() {
  TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Quem está usando?"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Digite seu nome",
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              final prefs = await SharedPreferences.getInstance();

              await prefs.setString('username', controller.text);

              setState(() {
                userName = controller.text;
                if (userName == adminName) {
                  isAdmin = true;
                }
              });

              Navigator.pop(context);
            }
          },
          child: const Text("Salvar"),
        ),
      ],
    ),
  );
}
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    userName = prefs.getString('username');

    if (userName == adminName) {
      isAdmin = true;
    }

    setState(() {});
  }

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('http://192.168.15.18:8000/api/tasks/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Falha ao carregar tarefas');
    }
  }

  Future<void> addTask(String title, String sector, String resp) async {
    await http.post(
      Uri.parse('http://192.168.15.18:8000/api/tasks/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'titulo': title, 'setor': sector, 'responsavel': resp}),
    );
    setState(() {
      futureTasks = fetchTasks();
    });
  }

  Future<void> toggleTaskStatus(int id, bool currentStatus) async {
    await http.patch(
      Uri.parse('http://192.168.15.18:8000/api/tasks/$id/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'concluido': !currentStatus}),
    );
    setState(() {
      futureTasks = fetchTasks();
    });
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
            TextField(
              controller: t,
              decoration: const InputDecoration(labelText: "O que limpar?"),
            ),
            TextField(
              controller: s,
              decoration: const InputDecoration(labelText: "Setor"),
            ),
            TextField(
              controller: r,
              decoration: const InputDecoration(labelText: "Responsável"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              addTask(t.text, s.text, r.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist da Equipe"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureTasks = fetchTasks();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tasks = snapshot.data!;

            // 🔥 RANKING
            Map<String, int> ranking = {};

            for (var task in tasks) {
              if (task.completed && task.madeBy != null) {
                ranking[task.madeBy!] = (ranking[task.madeBy!] ?? 0) + 1;
              }
            }

            var rankingList = ranking.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // 🔥 AGRUPAMENTO
            Map<String, List<Task>> grouped = {};

            for (var task in tasks) {
              grouped.putIfAbsent(task.section, () => []).add(task);
            }

            // 🔥 UI FINAL
            return Column(
              children: [
                // 👑 RANKING (SÓ ADMIN)
                if (isAdmin)
                  Card(
                    color: Colors.amber.shade50,
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "🏆 Ranking",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...rankingList.map(
                            (e) => Text("${e.key} - ${e.value}"),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 📋 LISTA
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: grouped.entries.map((entry) {
                      // 🔥 ORDENAÇÃO
                      entry.value.sort((a, b) {
                        if (a.completed == b.completed) return 0;
                        return a.completed ? 1 : -1;
                      });

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔵 TÍTULO DO SETOR
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cleaning_services,
                                    color: Color(0xFF006494),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // 📋 TAREFAS
                              ...entry.value.map((task) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: task.completed
                                        ? Colors.green.shade50
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      // ✅ CHECKBOX
                                      Checkbox(
                                        value: task.completed,
                                        activeColor: Colors.green,
                                        onChanged: (_) async {
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          String username =
                                              prefs.getString('username') ??
                                              "Alguém";
                                          Future<void> toggleTaskStatus(
                                            int id,
                                            bool currentStatus,
                                            String madeBy,
                                          ) async {
                                            await http.patch(
                                              Uri.parse(
                                                'http://192.168.15.18:8000/api/tasks/$id/',
                                              ),
                                              headers: {
                                                'Content-Type':
                                                    'application/json; charset=UTF-8',
                                                'Authorization':
                                                    'Bearer ${widget.token}',
                                              },
                                              body: jsonEncode({
                                                'concluido': !currentStatus,
                                                'made_by':
                                                    madeBy, // 👈 AQUI É O SEGREDO
                                              }),
                                            );

                                            setState(() {
                                              futureTasks = fetchTasks();
                                            });
                                          }
                                        },
                                      ),

                                      // TEXTO
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                decoration: task.completed
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            Text(
                                              task.responsible,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),

                                            // 👇 MOSTRAR QUEM FEZ
                                            if (task.completed)
                                              Text(
                                                "Feito por: ${task.madeBy ?? ''}",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // ✏️ EDITAR
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006494),
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text("Nova tarefa"),
      ),
    );
  }
}
