import 'package:flutter/material.dart';
import 'data/child_store.dart';

class AddChildPage extends StatefulWidget {
  final ChildEntry? child;
  final int? index;

  const AddChildPage({super.key, this.child, this.index});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  late final TextEditingController _nameController;
  late final ValueNotifier<String> _genderCtrl;
  DateTime? _pickedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _genderCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child?.name ?? '');
    _genderCtrl = ValueNotifier<String>(widget.child?.gender ?? 'Perempuan');
    _pickedDate = widget.child?.birthDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.child == null ? 'Tambah Data Anak' : 'Ubah Data Anak',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _label('Nama Anak'),
            _input(_nameController, hint: 'Isi nama anak'),
            const SizedBox(height: 10),
            _label('Tanggal Lahir Anak'),
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final res = await showDatePicker(
                  context: context,
                  initialDate: _pickedDate ?? now,
                  firstDate: DateTime(2015),
                  lastDate: now,
                );
                if (res != null) {
                  setState(() {
                    _pickedDate = res;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _pickedDate == null
                      ? 'Pilih tanggal lahir'
                      : _formatDate(_pickedDate),
                  style: TextStyle(
                    color: _pickedDate == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _label('Jenis Kelamin'),
            ValueListenableBuilder<String>(
              valueListenable: _genderCtrl,
              builder: (_, gender, __) {
                return Row(
                  children: [
                    _genderChip(
                      'Perempuan',
                      gender == 'Perempuan',
                      () => _genderCtrl.value = 'Perempuan',
                    ),
                    const SizedBox(width: 10),
                    _genderChip(
                      'Laki-laki',
                      gender == 'Laki-laki',
                      () => _genderCtrl.value = 'Laki-laki',
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B8CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveChild,
                child: Text(
                  widget.child == null ? 'Simpan Anak' : 'Simpan Perubahan',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
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

  void _saveChild() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _pickedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan tanggal lahir wajib diisi')),
      );
      return;
    }
    try {
      final entry = ChildEntry(
        name: name,
        gender: _genderCtrl.value,
        birthDate: _pickedDate!,
      );
      if (widget.index != null) {
        ChildStore.update(widget.index!, entry);
      } else {
        ChildStore.add(entry);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data anak: $e')));
    }
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
          borderSide: const BorderSide(color: Color(0xFF0B8CFF)),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }
}
