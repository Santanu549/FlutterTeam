import 'package:cargo_flow/pages/log_in.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:cargo_flow/services/auth_service.dart';
import 'package:cargo_flow/services/appwrite_client.dart';
import 'package:cargo_flow/services/appwrite_auth_san.dart';
import 'package:cargo_flow/services/notification_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _HomePlaceholder(),
      _TripsPlaceholder(),
      _NotificationsPage(),
      _ProfilePlaceholder(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomePlaceholder extends StatefulWidget {
  const _HomePlaceholder();

  @override
  State<_HomePlaceholder> createState() => _HomePlaceholderState();
}

class _HomePlaceholderState extends State<_HomePlaceholder> {
  bool _pinging = false;

  Future<void> _sendPing() async {
    setState(() => _pinging = true);
    try {
      await client.ping();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ping successful! Appwrite is connected.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ping failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pinging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final appwriteAuthService = AuthServiceAppwrite();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
             // await authService.signOut();
              await appwriteAuthService.logout();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Welcome, Driver!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text('Logged in as: ${user?.email ?? 'N/A'}'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pinging ? null : _sendPing,
              icon: _pinging
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: const Text('Send a ping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsPlaceholder extends StatelessWidget {
  const _TripsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text('Trips Page Placeholder', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final AuthServiceAppwrite _authServiceAppwrite = AuthServiceAppwrite();
  bool _isUpdating = false;

  Future<void> _updateStatus({
    required String rowId,
    required String status,
  }) async {
    setState(() => _isUpdating = true);
    try {
      await _notificationService.updateNotificationStatus(
        rowId: rowId,
        status: status,
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder(
        future: _authServiceAppwrite.getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userSnapshot.data;
          if (user == null) {
            return const Center(child: Text('No user found'));
          }

          return FutureBuilder<List<models.Row>>(
            future: _notificationService.getNotificationsForUser(user.$id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final notifications = snapshot.data ?? <models.Row>[];
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications found'));
              }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final theme = Theme.of(context);
                    final colorScheme = theme.colorScheme;
                    final row = notifications[index];
                    final data = row.data;
                    final status = (data['status'] ?? 'pending').toString();
                    final isPending = status == 'pending';

                    return Card(
                      margin: const EdgeInsets.all(12),
                      color: colorScheme.surfaceContainerLow,
                      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (data['title'] ?? '').toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (data['message'] ?? '').toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isPending)
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                      ),
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _updateStatus(
                                              rowId: row.$id,
                                              status: 'accepted',
                                            ),
                                    child: const Text('Accept'),
                                  ),
                                ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colorScheme.error,
                                        side: BorderSide(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _updateStatus(
                                              rowId: row.$id,
                                              status: 'rejected',
                                            ),
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'accepted'
                                      ? colorScheme.primaryContainer
                                      : colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Status: ${status.toUpperCase()}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: status == 'accepted'
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.purple),
            SizedBox(height: 16),
            Text('Profile Page Placeholder', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
