import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ayarlar'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Okullar'),
              Tab(text: 'Kategoriler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSchoolList(),
            _buildCategoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _schoolController,
            decoration: InputDecoration(
              labelText: 'Okul Adı',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _addSchool(_schoolController.text),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ\s]')),
            ],
            onSubmitted: (value) => _addSchool(value),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('schools').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editSchool(doc.id, doc['name']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteSchool(doc.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _addCategory(_categoryController.text),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ\s]')),
            ],
            onSubmitted: (value) => _addCategory(value),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editCategory(doc.id, doc['name']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCategory(doc.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addSchool(String name) {
    if (name.isNotEmpty) {
      _firestore.collection('schools').add({'name': name});
      _schoolController.clear();
    }
  }

  void _editSchool(String id, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController editController = TextEditingController(text: currentName);
        return AlertDialog(
          title: Text('Okul Adını Düzenle'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'Yeni Okul Adı'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ\s]')),
            ],
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Kaydet'),
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  _firestore.collection('schools').doc(id).update({'name': editController.text});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSchool(String id) {
    _firestore.collection('schools').doc(id).delete();
  }

  void _addCategory(String name) {
    if (name.isNotEmpty) {
      _firestore.collection('categories').add({'name': name});
      _categoryController.clear();
    }
  }

  void _editCategory(String id, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController editController = TextEditingController(text: currentName);
        return AlertDialog(
          title: Text('Kategori Adını Düzenle'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'Yeni Kategori Adı'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ\s]')),
            ],
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Kaydet'),
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  _firestore.collection('categories').doc(id).update({'name': editController.text});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String id) {
    _firestore.collection('categories').doc(id).delete();
  }
}

