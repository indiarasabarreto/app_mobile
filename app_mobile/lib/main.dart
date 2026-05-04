import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TempleApp());
}

// ─── PALETA ──────────────────────────────────────────────────────────
const _purple       = Color(0xFF7B2D8B);
const _purpleLight  = Color(0xFFB06EC0);
const _purpleFaint  = Color(0xFFF3E8F7);
const _purpleBorder = Color(0xFFDDB8EA);
const _white        = Color(0xFFFFFFFF);
const _offWhite     = Color(0xFFFAF7FC);
const _darkBg       = Color(0xFF1A0A22);
const _textDark     = Color(0xFF2C1040);
const _textMid      = Color(0xFF7A5F85);
const _textLight    = Color(0xFFB8A0C4);
const _red          = Color(0xFFD32F2F);
const _redFaint     = Color(0xFFFFEBEE);
const _green        = Color(0xFF2E7D32);
const _greenFaint   = Color(0xFFE8F5E9);

// ⚠️ ALTERE PARA O IP DO SEU COMPUTADOR
const _baseUrl     = "http://192.168.1.212:8000/api/tasks/";
const _suppliesUrl = "http://192.168.1.212:8000/api/supplies/";
const _elementsUrl = "http://192.168.1.212:8000/api/elements/";

// ─── APP ─────────────────────────────────────────────────────────────
class TempleApp extends StatelessWidget {
  const TempleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Terreiro',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(seedColor: _purple),
        scaffoldBackgroundColor: _offWhite,
      ),
      home: const UserCheck(),
    );
  }
}

// ─── USER CHECK ──────────────────────────────────────────────────────
class UserCheck extends StatefulWidget {
  const UserCheck({super.key});
  @override
  State<UserCheck> createState() => _UserCheckState();
}

class _UserCheckState extends State<UserCheck> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => name != null ? const HomeScreen() : const WelcomeScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: _darkBg,
    body: Center(child: CircularProgressIndicator(color: _purpleLight)),
  );
}

// ─── WELCOME SCREEN ───────────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameCtrl = TextEditingController();
  String _team = 'Alecrim';
  final _teams = ['Alecrim', 'Guiné', 'Arruda'];

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('user_team', _team);
    if (mounted) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _white,
                  boxShadow: [
                    BoxShadow(color: _purple.withOpacity(0.5), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _white,
                      child: const Icon(Icons.auto_awesome, color: _purple, size: 60),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Limpeza do Terreiro',
                  style: TextStyle(color: _white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              const Text('Quem está trabalhando hoje?',
                  style: TextStyle(color: _purpleLight, fontSize: 14)),
              const SizedBox(height: 40),

              // Card de login
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1040),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _purple.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Seu nome'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: _white),
                      textCapitalization: TextCapitalization.words,
                      decoration: _darkInput('Digite seu nome...'),
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('Sua equipe'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _purple.withOpacity(0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: const Color(0xFF2C1040),
                          style: const TextStyle(color: _white),
                          value: _team,
                          icon: const Icon(Icons.keyboard_arrow_down, color: _purpleLight),
                          items: _teams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _team = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: _white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 6,
                          shadowColor: _purple.withOpacity(0.6),
                        ),
                        child: const Text('Vamos trabalhar!', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: const TextStyle(color: _purpleLight, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.4));

  InputDecoration _darkInput(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _textLight),
    filled: true,
    fillColor: Colors.black.withOpacity(0.3),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _purple.withOpacity(0.4))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _purple.withOpacity(0.4))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _purpleLight, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

// ─── HOME SCREEN (3 abas) ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _userName;
  String? _userTeam;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
      _userTeam = prefs.getString('user_team');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _darkBg,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: _purpleLight,
              indicatorWeight: 3,
              labelColor: _white,
              unselectedLabelColor: _textLight,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(icon: Icon(Icons.checklist_rounded, size: 18), text: 'TAREFAS'),
                Tab(icon: Icon(Icons.warning_amber_rounded, size: 18), text: 'PENDÊNCIAS'),
                Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'FALTANDO'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            TasksTab(userName: _userName),
            PendingTab(userName: _userName),
            ShortagesTab(userName: _userName),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_darkBg, Color(0xFF3D1155)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 8),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _white,
              boxShadow: [BoxShadow(color: _purple.withOpacity(0.5), blurRadius: 14)],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.auto_awesome, color: _purple, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Limpeza do Terreiro',
                    style: TextStyle(color: _white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (_userName != null)
                  Text('Olá, $_userName 👋',
                      style: const TextStyle(color: _purpleLight, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _purpleLight.withOpacity(0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.logout, color: _purpleLight, size: 13),
                const SizedBox(width: 4),
                Text(_userTeam ?? '', style: const TextStyle(color: _white, fontSize: 11)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ABA: TAREFAS ─────────────────────────────────────────────────────
class TasksTab extends StatefulWidget {
  final String? userName;
  const TasksTab({super.key, this.userName});
  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse(_baseUrl));
      if (res.statusCode == 200) setState(() => _tasks = json.decode(res.body));
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _toggle(int id, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await http.patch(Uri.parse("$_baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"completed": val, "made_by": prefs.getString('user_name')}));
    _load();
  }

  Future<void> _markSkipped(int id) async {
    await http.patch(Uri.parse("$_baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"skipped": true, "completed": false}));
    _load();
  }

  Future<void> _addTask(String title, String section, String responsible) async {
    await http.post(Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "section": section, "responsible": responsible, "completed": false}));
    _load();
  }

  Map<String, List> get _grouped {
    final Map<String, List> g = {};
    for (var t in _tasks) {
      if (t['skipped'] == true) continue;
      final s = t['section'] ?? 'Geral';
      g.putIfAbsent(s, () => []).add(t);
    }
    return g;
  }

  int get _completedCount => _tasks.where((t) => t['completed'] == true).length;
  int get _totalCount => _tasks.where((t) => t['skipped'] != true).length;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: _purple));

    final percent = _totalCount > 0 ? _completedCount / _totalCount : 0.0;

    return RefreshIndicator(
      color: _purple,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressCard(completed: _completedCount, total: _totalCount, percent: percent),
          const SizedBox(height: 16),
          ..._grouped.keys.map((section) => _SectionCard(
            section: section,
            tasks: _grouped[section]!,
            userName: widget.userName,
            onToggle: _toggle,
            onMarkSkipped: _markSkipped,
            onAddTask: (title, responsible) => _addTask(title, section, responsible),
          )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── ABA: PENDÊNCIAS ──────────────────────────────────────────────────
class PendingTab extends StatefulWidget {
  final String? userName;
  const PendingTab({super.key, this.userName});
  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse(_baseUrl));
      if (res.statusCode == 200) {
        final all = json.decode(res.body) as List;
        setState(() => _pending = all.where((t) => t['skipped'] == true).toList());
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _restore(int id) async {
    await http.patch(Uri.parse("$_baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"skipped": false}));
    _load();
  }

  Future<void> _complete(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await http.patch(Uri.parse("$_baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"skipped": false, "completed": true, "made_by": prefs.getString('user_name')}));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: _purple));

    if (_pending.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_outline, color: _purple.withOpacity(0.3), size: 64),
          const SizedBox(height: 16),
          const Text('Nenhuma pendência! 🎉',
              style: TextStyle(color: _textMid, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tudo realizado com axé! ✨',
              style: TextStyle(color: _textLight, fontSize: 13)),
        ]),
      );
    }

    return RefreshIndicator(
      color: _purple,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _redFaint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _red.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: _red, size: 18),
              const SizedBox(width: 8),
              Text('${_pending.length} tarefa(s) não realizada(s)',
                  style: const TextStyle(color: _red, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 14),
          ..._pending.map((task) => _PendingCard(
            task: task,
            onRestore: () => _restore(task['id']),
            onComplete: () => _complete(task['id']),
          )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── ABA: FALTANDO ────────────────────────────────────────────────────
class ShortagesTab extends StatefulWidget {
  final String? userName;
  const ShortagesTab({super.key, this.userName});
  @override
  State<ShortagesTab> createState() => _ShortagesTabState();
}

class _ShortagesTabState extends State<ShortagesTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List _supplies = [];
  List _elements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sRes = await http.get(Uri.parse(_suppliesUrl));
      final eRes = await http.get(Uri.parse(_elementsUrl));
      if (sRes.statusCode == 200) setState(() => _supplies = json.decode(sRes.body));
      if (eRes.statusCode == 200) setState(() => _elements = json.decode(eRes.body));
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _addSupply(String name, String note) async {
    await http.post(Uri.parse(_suppliesUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "note": note, "resolved": false}));
    _load();
  }

  Future<void> _addElement(String name, String note) async {
    await http.post(Uri.parse(_elementsUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "note": note, "resolved": false}));
    _load();
  }

  Future<void> _resolveSupply(int id) async {
    await http.patch(Uri.parse("$_suppliesUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"resolved": true}));
    _load();
  }

  Future<void> _resolveElement(int id) async {
    await http.patch(Uri.parse("$_elementsUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"resolved": true}));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: _purple));

    final activeSupplies = _supplies.where((s) => s['resolved'] != true).toList();
    final activeElements = _elements.where((e) => e['resolved'] != true).toList();

    return RefreshIndicator(
      color: _purple,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ShortageSection(
            icon: Icons.cleaning_services_rounded,
            title: 'Produtos de Limpeza em Falta',
            color: const Color(0xFF1565C0),
            faintColor: const Color(0xFFE3F2FD),
            items: activeSupplies,
            onAdd: _addSupply,
            onResolve: _resolveSupply,
          ),
          const SizedBox(height: 16),
          _ShortageSection(
            icon: Icons.wine_bar_rounded,
            title: 'Elementos / Bebidas em Falta',
            color: const Color(0xFF6A1B9A),
            faintColor: const Color(0xFFF3E5F5),
            items: activeElements,
            onAdd: _addElement,
            onResolve: _resolveElement,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── WIDGET: PROGRESS CARD ────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int completed, total;
  final double percent;
  const _ProgressCard({required this.completed, required this.total, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_purple, _purpleLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _purple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.task_alt, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            const Text('Progresso Geral',
                style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5)),
            const Spacer(),
            Text('$completed / $total',
                style: const TextStyle(color: _white, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: _white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text('${(percent * 100).toInt()}% concluído',
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── WIDGET: SECTION CARD ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String section;
  final List tasks;
  final String? userName;
  final Function(int, bool) onToggle;
  final Function(int) onMarkSkipped;
  final Function(String, String) onAddTask;

  const _SectionCard({
    required this.section, required this.tasks, required this.userName,
    required this.onToggle, required this.onMarkSkipped, required this.onAddTask,
  });

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final respCtrl = TextEditingController(text: userName ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSheet(
        title: 'Nova Tarefa — $section',
        fields: [
          _Field(ctrl: titleCtrl, label: 'Tarefa', hint: 'Descrição da tarefa...', maxLines: 2),
          _Field(ctrl: respCtrl, label: 'Responsável', hint: 'Nome ou equipe...'),
        ],
        onConfirm: () {
          if (titleCtrl.text.trim().isNotEmpty) onAddTask(titleCtrl.text.trim(), respCtrl.text.trim());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t['completed'] == true).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purpleBorder.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _purple.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _purpleFaint,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: _purpleBorder.withOpacity(0.4))),
            ),
            child: Row(children: [
              const Icon(Icons.folder_special_rounded, color: _purple, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(section.toUpperCase(),
                  style: const TextStyle(color: _purple, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('$done/${tasks.length}',
                    style: const TextStyle(color: _purple, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          // Tarefas
          ...tasks.map((task) => _TaskTile(
            task: task,
            userName: userName,
            onToggle: (val) => onToggle(task['id'], val),
            onSkip: () => onMarkSkipped(task['id']),
          )),

          // Botão adicionar
          InkWell(
            onTap: () => _showAddDialog(context),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _purpleBorder.withOpacity(0.4))),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add, color: _purple, size: 16),
                const SizedBox(width: 6),
                const Text('Adicionar tarefa', style: TextStyle(color: _purple, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET: TASK TILE ────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final dynamic task;
  final String? userName;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSkip;

  const _TaskTile({required this.task, required this.userName, required this.onToggle, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final bool done = task['completed'] ?? false;
    final String title = task['title'] ?? '';
    final String responsible = task['responsible'] ?? '';
    final bool isMyTask = userName != null &&
        responsible.toLowerCase().contains(userName!.toLowerCase());

    return Container(
      decoration: BoxDecoration(
        color: done ? _greenFaint : (isMyTask ? _purpleFaint : _white),
        border: Border(bottom: BorderSide(color: _purpleBorder.withOpacity(0.2))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => onToggle(!done),
              child: Container(
                width: 24, height: 24,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? _green : _white,
                  border: Border.all(color: done ? _green : _purpleBorder, width: 2),
                ),
                child: done ? const Icon(Icons.check, color: _white, size: 14) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 14, color: done ? _textMid : _textDark,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: _textMid, height: 1.4,
                      )),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.people_outline, size: 11, color: _textLight),
                    const SizedBox(width: 3),
                    Flexible(child: Text(responsible,
                        style: const TextStyle(color: _textLight, fontSize: 11),
                        overflow: TextOverflow.ellipsis)),
                    if (isMyTask && !done) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _purpleFaint, borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _purpleBorder),
                        ),
                        child: const Text('você',
                            style: TextStyle(color: _purple, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            // Botão não realizado
            if (!done)
              GestureDetector(
                onTap: () => _confirmSkip(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: _redFaint, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _red.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.remove_circle_outline, color: _red, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmSkip(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Marcar como não realizada?'),
        content: const Text('A tarefa irá para a lista de Pendências.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); onSkip(); },
            style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: _white),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET: PENDING CARD ─────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final dynamic task;
  final VoidCallback onRestore;
  final VoidCallback onComplete;

  const _PendingCard({required this.task, required this.onRestore, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _red.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _redFaint, borderRadius: BorderRadius.circular(8)),
            child: Text((task['section'] ?? 'Geral').toUpperCase(),
                style: const TextStyle(color: _red, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 8),
          Text(task['title'] ?? '',
              style: const TextStyle(color: _textDark, fontSize: 14, height: 1.4)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.people_outline, size: 11, color: _textLight),
            const SizedBox(width: 3),
            Text(task['responsible'] ?? '', style: const TextStyle(color: _textLight, fontSize: 11)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.undo, size: 14),
                label: const Text('Restaurar', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _purple, side: const BorderSide(color: _purple),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Concluir', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: _white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─── WIDGET: SHORTAGE SECTION ─────────────────────────────────────────
class _ShortageSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color, faintColor;
  final List items;
  final Function(String, String) onAdd;
  final Function(int) onResolve;

  const _ShortageSection({
    required this.icon, required this.title, required this.color,
    required this.faintColor, required this.items,
    required this.onAdd, required this.onResolve,
  });

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSheet(
        title: title,
        fields: [
          _Field(ctrl: nameCtrl, label: 'Item', hint: 'Nome do item...'),
          _Field(ctrl: noteCtrl, label: 'Observação', hint: 'Observação (opcional)...'),
        ],
        onConfirm: () {
          if (nameCtrl.text.trim().isNotEmpty) onAdd(nameCtrl.text.trim(), noteCtrl.text.trim());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: faintColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.15))),
            ),
            child: Row(children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('${items.length}',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Nenhum item em falta 👍',
                  style: TextStyle(color: color.withOpacity(0.5), fontSize: 13)),
            )
          else
            ...items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color.withOpacity(0.08)))),
              child: Row(children: [
                Icon(Icons.circle, color: color.withOpacity(0.4), size: 8),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] ?? '', style: const TextStyle(color: _textDark, fontSize: 14)),
                    if ((item['note'] ?? '').isNotEmpty)
                      Text(item['note'], style: const TextStyle(color: _textLight, fontSize: 12)),
                  ],
                )),
                GestureDetector(
                  onTap: () => onResolve(item['id']),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _greenFaint, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _green.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.check, color: _green, size: 16),
                  ),
                ),
              ]),
            )),

          // Botão adicionar
          InkWell(
            onTap: () => _showAddSheet(context),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: color.withOpacity(0.15)))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add, color: color, size: 16),
                const SizedBox(width: 6),
                Text('Adicionar item', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET: ADD SHEET ────────────────────────────────────────────────
class _Field {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  _Field({required this.ctrl, required this.label, required this.hint, this.maxLines = 1});
}

class _AddSheet extends StatelessWidget {
  final String title;
  final List<_Field> fields;
  final VoidCallback onConfirm;

  const _AddSheet({required this.title, required this.fields, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _purpleBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.add_circle_outline, color: _purple),
            const SizedBox(width: 8),
            Expanded(child: Text(title,
                style: const TextStyle(color: _textDark, fontSize: 15, fontWeight: FontWeight.bold))),
            IconButton(icon: const Icon(Icons.close, color: _textLight),
                onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 14),
          ...fields.map((f) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.label,
                  style: const TextStyle(color: _purple, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.4)),
              const SizedBox(height: 6),
              TextField(
                controller: f.ctrl,
                maxLines: f.maxLines,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: f.hint,
                  hintStyle: const TextStyle(color: _textLight),
                  filled: true,
                  fillColor: _purpleFaint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _purple, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          )),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple, foregroundColor: _white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4, shadowColor: _purple.withOpacity(0.4),
              ),
              onPressed: () { onConfirm(); Navigator.pop(context); },
            ),
          ),
        ],
      ),
    );
  }
}