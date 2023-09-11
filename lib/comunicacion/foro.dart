import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ForoScreen extends StatefulWidget {
  const ForoScreen({Key? key}) : super(key: key);

  @override
  State<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends State<ForoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  



  
  
  File? _image;

  String _searchQuery = '';
  Set<DocumentReference> _userLikedPosts =
      {}; // Conjunto de publicaciones con like del usuario
  Set<DocumentReference> _userDislikedPosts =
      {}; // Conjunto de publicaciones con dislike del usuario

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    final username = userEmail.split('@')[0];
    return Scaffold(
      appBar: AppBar(
        title: Text('FOROS CAMPOY TT'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                  ),
                ),
                TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    labelText: 'Contenido',
                  ),
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    ElevatedButton(
                      child: Text('Agregar imagen'),
                      onPressed: () {
                        _pickImage();
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      child: Text('Publicar'),
                      onPressed: () {
                        _addPost();
                      },
                    ),
                  ],
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Buscar publicaciones por título',
                  ),
                ),
              ],
            ),
          ),
          _image != null
              ? GestureDetector(
                  onTap: () {
                    _showFullImage(_image!);
                  },
                  child: Container(
                    child: Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : SizedBox(
                  height: 5,
                ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('foro')
                  .where('titulo', isGreaterThanOrEqualTo: _searchQuery)
                  .where('titulo', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot post = snapshot.data!.docs[index];
                    DateTime publicationDate = post['fecha']
                        .toDate(); // Convert Firebase Timestamp to DateTime

                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(post['titulo'].toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post['contenido']),
                                Row(
                                  children: [
                                    Text('Autor: ${post['autor'] ?? username}'),
                                    SizedBox(
                                      width: 100,
                                    ),
                                    Text(
                                      '${publicationDate.day}-${publicationDate.month}-${publicationDate.year}, ${publicationDate.hour}:${publicationDate.minute}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          post['imageUrl'] != null
                              ? GestureDetector(
                                  onTap: () {
                                    _showFullImageNetwork(post['imageUrl']);
                                  },
                                  child: Image.network(
                                    post['imageUrl'],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : SizedBox.shrink(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.thumb_up),
                                      onPressed: _userLikedPosts
                                              .contains(post.reference)
                                          ? null
                                          : () {
                                              _likePost(post.reference);
                                            },
                                    ),
                                    Text('${post['likes']}'),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(Icons.thumb_down),
                                      onPressed: _userDislikedPosts
                                              .contains(post.reference)
                                          ? null
                                          : () {
                                              _dislikePost(post.reference);
                                            },
                                    ),
                                    Text('${post['dislikes']}'),
                                  ],
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: post.reference
                                      .collection('comentarios')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final commentCount =
                                          snapshot.data!.docs.length;
                                      return Text('$commentCount comentarios');
                                    }
                                    return SizedBox();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Ver comentarios'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommentsPage(post.reference),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void _addPost() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;
    String userEmail = auth.currentUser!.email ?? '';
    String username = userEmail.split('@')[0];

    String? imageUrl;
    if (_image != null) {
      // Upload image to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child(DateTime.now().toString());
      final UploadTask uploadTask = storageRef.putFile(_image!);
      final TaskSnapshot storageSnapshot = await uploadTask;
      imageUrl = await storageSnapshot.ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('foro').add({
      'titulo': _titleController.text,
      'contenido': _postController.text,
      'autor': username,
      'fecha': DateTime.now(),
      'userId': userId,
      'likes': 0,
      'dislikes': 0,
      'imageUrl': imageUrl,
    });

    _titleController.clear();
    _postController.clear();
    setState(() {
      _image = null;
    });
  }

  void _likePost(DocumentReference postRef) {
    postRef.get().then((snapshot) {
      if (snapshot.exists) {
        if (!_userLikedPosts.contains(postRef)) {
          if (_userDislikedPosts.contains(postRef)) {
            postRef.update({'dislikes': FieldValue.increment(-1)});
            _userDislikedPosts.remove(postRef);
          }
          postRef.update({'likes': FieldValue.increment(1)});
          _userLikedPosts.add(postRef);
        } else {
          postRef.update({'likes': FieldValue.increment(-1)});
          _userLikedPosts.remove(postRef);
        }
        setState(() {});
      }
    });
  }

  void _dislikePost(DocumentReference postRef) {
    postRef.get().then((snapshot) {
      if (snapshot.exists) {
        if (!_userDislikedPosts.contains(postRef)) {
          if (_userLikedPosts.contains(postRef)) {
            postRef.update({'likes': FieldValue.increment(-1)});
            _userLikedPosts.remove(postRef);
          }
          postRef.update({'dislikes': FieldValue.increment(1)});
          _userDislikedPosts.add(postRef);
        } else {
          postRef.update({'dislikes': FieldValue.increment(-1)});
          _userDislikedPosts.remove(postRef);
        }
        setState(() {});
      }
    });
  }

  void _showFullImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  void _showFullImageNetwork(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class CommentsPage extends StatelessWidget {
  final DocumentReference postRef;
  final TextEditingController _commentController = TextEditingController();

  CommentsPage(this.postRef);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios'),
      ),
      body: Column(
        children: [
           Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Nuevo comentario',
                  ),
                ),
                ElevatedButton(
                  child: Text('Comentar'),
                  onPressed: () {
                    _addComment();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: postRef
                  .collection('comentarios')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot comment = snapshot.data!.docs[index];

                    return ListTile(
                      title: Text(comment['contenido']),
                      subtitle: Text('Autor: ${comment['autor']}'),
                    );
                  },
                );
              },
            ),
          ),
         
        ],
      ),
    );
  }

  void _addComment() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;
    String userEmail = auth.currentUser!.email ?? '';
    String username = userEmail.split('@')[0];

    await postRef.collection('comentarios').add({
      'contenido': _commentController.text,
      'autor': username,
      'fecha': DateTime.now(),
      'userId': userId,
    });

    _commentController.clear();
  }
}
