
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _allowRegistration = true; // This should ideally come from Firestore 'system/config'
  bool _maintenanceMode = false;
  
  final _announcementController = TextEditingController();

  Future<void> _sendGlobalAnnouncement() async {
    if (_announcementController.text.isEmpty) return;
    
    // Logic to send notification would go here (requires Cloud Functions or loop in client/server)
    // For now, we mock it visually.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement Sent (Mock)')),
    );
    _announcementController.clear();
    Navigator.pop(context);
  }

  void _showAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Global Announcement'),
        content: TextField(
          controller: _announcementController,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'e.g., We will be down for maintenance...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _sendGlobalAnnouncement, 
            child: const Text('Send')
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'System Configuration',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('Allow New User Registrations'),
            subtitle: const Text('If disabled, new users cannot sign up.'),
            value: _allowRegistration,
            onChanged: (val) {
              setState(() => _allowRegistration = val);
              // Save to Firestore...
            },
          ),
          SwitchListTile(
            title: const Text('Maintenance Mode'),
            subtitle: const Text('Show maintenance screen to all non-admin users.'),
            value: _maintenanceMode,
            onChanged: (val) {
              setState(() => _maintenanceMode = val);
              // Save to Firestore...
            },
          ),
          
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Communication',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('Send Global Announcement'),
            subtitle: const Text('Push notification to all users'),
            onTap: _showAnnouncementDialog,
          ),
          
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () {
               ref.read(firebaseAuthNotifierProvider.notifier).logout();
               // Router will handle redirect
            },
          ),
        ],
      ),
    );
  }
}
