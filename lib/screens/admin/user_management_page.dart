import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _showUserDialog({DocumentSnapshot? userDoc}) {
    showDialog(
      context: context,
      builder: (context) => UserDialog(
        userDoc: userDoc,
        onSuccess: (msg) => _showSnackbar(msg),
        onError: (msg) => _showSnackbar(msg, error: true),
      ),
    );
  }

  void _deleteUser(DocumentSnapshot userDoc) async {
    final uid = userDoc.id;
    final email = userDoc['email'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .delete();
                // Optionally delete from Firebase Auth (requires admin privileges)
                _showSnackbar('User deleted successfully');
              } catch (e) {
                _showSnackbar('Failed to delete user: $e', error: true);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersQuery = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final firstName = data['firstName'] ?? '';
            final lastName = data['lastName'] ?? '';
            // Search by name or email
            final searchTarget =
                ('$firstName $lastName ' + (data['email'] ?? '')).toLowerCase();
            // If you want to exclude admins, you can check for the field's existence first:
            if (data.containsKey('role')) {
              final role = data['role']?.toString().toLowerCase() ?? '';
              if (role == 'admin') return false;
            }
            return searchTarget.contains(_searchQuery);
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return SingleChildScrollView(
                child: PaginatedDataTable(
                  header: const Text('Users'),
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Date Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: UserDataTableSource(
                    users: users,
                    onEdit: (doc) => _showUserDialog(userDoc: doc),
                    onDelete: (doc) => _deleteUser(doc),
                  ),
                  rowsPerPage: _rowsPerPage,
                  onRowsPerPageChanged: (value) {
                    if (value != null) setState(() => _rowsPerPage = value);
                  },
                  availableRowsPerPage: const [5, 10, 20],
                  columnSpacing: isMobile ? 10 : 32,
                  showCheckboxColumn: false,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
        onPressed: () => _showUserDialog(),
      ),
    );
  }
}

class UserDataTableSource extends DataTableSource {
  final List<DocumentSnapshot> users;
  final void Function(DocumentSnapshot) onEdit;
  final void Function(DocumentSnapshot) onDelete;

  UserDataTableSource({
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final doc = users[index];
    final data = doc.data() as Map<String, dynamic>;
    final firstName = data['firstName']?.toString() ?? '';
    final lastName = data['lastName']?.toString() ?? '';
    final email = data['email']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? '';
    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : null;
    final dateStr = createdAt != null
        ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
        : '';

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('$firstName $lastName')),
        DataCell(Text(email)),
        DataCell(Text(phone)),
        DataCell(Text(dateStr)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                tooltip: 'Edit',
                onPressed: () => onEdit(doc),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () => onDelete(doc),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}

class UserDialog extends StatefulWidget {
  final DocumentSnapshot? userDoc;
  final void Function(String) onSuccess;
  final void Function(String) onError;

  const UserDialog({
    Key? key,
    this.userDoc,
    required this.onSuccess,
    required this.onError,
  }) : super(key: key);

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController,
      _lastNameController,
      _emailController,
      _passwordController;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.userDoc != null;
    _firstNameController = TextEditingController(
      text: widget.userDoc?['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userDoc?['lastName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userDoc?['email'] ?? '',
    );
    // _roleController removed
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    // _roleController removed
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEdit) {
        // Update Firestore user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userDoc!.id)
            .update({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
            });
        widget.onSuccess('User updated successfully');
      } else {
        // Create user in Firebase Auth
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        // Add user to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });
        widget.onSuccess('User added successfully');
      }
      Navigator.pop(context);
    } catch (e) {
      widget.onError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit User' : 'Add User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                enabled: !_isEdit,
              ),
              // Role field removed
              if (!_isEdit)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
