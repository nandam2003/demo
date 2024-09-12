import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  String _text = '';
  File? _image;
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  // Upload Text to Firestore
  Future<void> _uploadTextToFirebase(String text) async {
    try {
      await FirebaseFirestore.instance.collection('texts').add({'text': text});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Text uploaded successfully!'),
      ));
    } catch (e) {
      print(e);
    }
  }

  // Upload Image to Firebase Storage
  Future<void> _uploadImageToFirebase() async {
    if (_image == null) return;

    try {
      String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(_image!);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image uploaded successfully!'),
      ));
    } catch (e) {
      print(e);
    }
  }

  // Select Image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Enter text'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _text = _textController.text;
                    });
                  }
                },
                child: const Text('Validate & Display Text'),
              ),
              const SizedBox(height: 10),
              Text('Entered text: $_text',
                  style: Theme.of(context).textTheme.headlineLarge),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _uploadTextToFirebase(_textController.text);
                  }
                },
                child: const Text('Upload Text to Firebase'),
              ),
              const SizedBox(height: 20),

              // Button to pick and upload image
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              _image != null
                  ? Image.file(
                      _image!,
                      height: 150,
                    )
                  : Container(),

              ElevatedButton(
                onPressed: _uploadImageToFirebase,
                child: const Text('Upload Image to Firebase'),
              ),
            ],
          )),
    );
  }
}
