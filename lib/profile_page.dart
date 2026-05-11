import 'package:flutter/material.dart';
import 'add_child_page.dart';
import 'data/child_store.dart';
import 'data/auth_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firstName = TextEditingController(text: 'Gustira');
  final _lastName = TextEditingController(text: 'Haryani');
  final _birthDate = TextEditingController(text: '19/08/2005');
  final _phone = TextEditingController(text: '+62 812-6839-2568');
  final _email = TextEditingController(text: 'tireximoet19@iCloud.com');

  final Color _primary = const Color(0xFF0B8CFF);
  final Color _bg = const Color(0xFFF4F6FB);
  final Color _card = Colors.white;

  @override
  void dispose() {
    AuthStore.userNotifier.removeListener(_syncUserProfile);
    _firstName.dispose();
    _lastName.dispose();
    _birthDate.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AuthStore.userNotifier.addListener(_syncUserProfile);
    _syncUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: _card,
          title: const Text('My Profile'),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(text: 'Akun Pengguna'),
              Tab(text: 'Data Anak'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildProfileTab(), _buildChildrenTab()]),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Data Profil'),
            const SizedBox(height: 12),
            _photoRow(),
            const SizedBox(height: 16),
            _label('Nama Depan'),
            _input(_firstName, hint: 'Isi nama depan'),
            const SizedBox(height: 12),
            _label('Nama Belakang'),
            _input(_lastName, hint: 'Isi nama belakang'),
            const SizedBox(height: 12),
            _label('Tanggal Lahir'),
            _dateInput(_birthDate, (date) {
              setState(() {
                _birthDate.text = _formatDate(date);
              });
            }),
            const SizedBox(height: 12),
            _label('Telepon'),
            _input(
              _phone,
              hint: 'Isi nomor telepon',
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _label('Email'),
            _input(
              _email,
              hint: 'Isi email',
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil disimpan')),
                      );
                    },
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _confirmLogout,
                    child: const Text(
                      'Keluar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: ValueListenableBuilder<List<ChildEntry>>(
        valueListenable: ChildStore.childrenNotifier,
        builder: (_, children, __) {
          return _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Data Anak'),
                const SizedBox(height: 8),
                if (children.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Belum ada data anak. Tambahkan anak untuk memantau tumbuh kembang.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  ...children
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _childCard(entry.key, entry.value),
                        ),
                      )
                      .toList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddChildPage()),
                      );
                    },
                    label: const Text('Tambah Anak'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _photoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.person, size: 42, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload foto dengan format PNG\nMax size 2 MB',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  side: const BorderSide(color: Color(0xFF0B8CFF)),
                  foregroundColor: const Color(0xFF0B8CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ubah',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary),
        ),
      ),
    );
  }

  Widget _dateInput(
    TextEditingController controller,
    ValueChanged<DateTime> onPick,
  ) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(1990),
          lastDate: now,
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0B8CFF)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _childCard(int index, ChildEntry child) {
    return Container(
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.child_care, color: _primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        child.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddChildPage(child: child, index: index),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          ChildStore.remove(index);
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(
                      text: _formatDate(child.birthDate),
                      icon: Icons.cake_outlined,
                    ),
                    const SizedBox(width: 8),
                    _chip(text: child.gender, icon: Icons.wc),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required String text, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _genderChip(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0B8CFF).withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF0B8CFF) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF0B8CFF) : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _confirmLogout() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Anda Yakin Ingin Keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B8CFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (res == true && mounted) {
      AuthStore.logout();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keluar dari akun')));
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  void _syncUserProfile() {
    final user = AuthStore.currentUser;
    if (user == null) return;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _email.text = user.email;
    _phone.text = user.phone;
    _birthDate.text = _formatDate(user.birthDate);
  }
}
