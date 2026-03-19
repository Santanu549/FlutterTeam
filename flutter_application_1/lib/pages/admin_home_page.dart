import 'package:flutter/material.dart';
import 'package:cargo_flow/services/auth_service.dart';
import 'package:cargo_flow/pages/log_in.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'driver';
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  List<AppUser> _users = [];

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);
    final users = await _authService.getAllUsers();
    final myId = _authService.currentUser?.id;
    if (mounted) {
      setState(() {
        _users = users.where((u) => u.id != myId).toList();
        _isLoadingUsers = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.createUserByAdmin(
        email: email,
        password: password,
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedRole created successfully')),
        );
        _emailController.clear();
        _passwordController.clear();
        _fetchUsers(); // Refresh the list without requiring a restart
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to create user.';
        if (e.toString().contains('email-already-in-use')) {
          msg = 'Email already in use.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        // use stateful builder to keep the dropdown reactive
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val != null) _selectedRole = val;
                        });
                        // Also update parent state if we want it preserved between dialogs
                        setState(() {
                          if (val != null) _selectedRole = val;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'driver',
                          child: Text('Driver'),
                        ),
                        DropdownMenuItem(
                          value: 'executive',
                          child: Text('Executive'),
                        ),
                      ],
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _createUser();
                        },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.admin_panel_settings, size: 60, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            'Welcome, Admin!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('Logged in as: ${user?.email ?? 'N/A'}'),
          const Divider(height: 30),
          Text('All Users', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No other users found.'))
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final u = _users[index];
                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(u.email),
                              subtitle: Text('Role: ${u.role.toUpperCase()}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Create User'),
      ),
    );
  }
}
