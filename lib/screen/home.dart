import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note/colors.dart';
import 'package:note/model/note_model.dart';
import 'package:note/screen/NoteView.dart';
import 'package:note/screen/createnoteview.dart';
import 'package:note/screen/login_info.dart';
import 'package:note/screen/search.dart';
import 'package:note/screen/sidebar.dart';
import 'package:note/services.dart/auth.dart';
import 'package:note/services.dart/firestore.dart';
import 'package:note/services.dart/sql.dart';
import 'package:note/services.dart/sync_services.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isLoading = true;
  late List<Note> notesList;
  late String? ImgUrl;
  bool isStaggered = true;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String note =
      "THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE THIS IS NOTE";
  String note1 = "THIS IS NOTE THIS IS NOTE THIS IS NOTE";

  @override
  void initState() {
    super.initState();
    getAllNotes();
    //LocalDataSaver.saveSyncSet(true);
  }

  void refreshNotes() async {
    await SyncService().syncNotes();
    setState(() {
      // Refresh UI after sync
    });
  }

  //creates a new note in the database
  Future createEntry(Note note) async {
    await NotesDatabse.instance.InsertEntry(note);
  }

  //fetches the image URL and notes from the local storage
  Future getAllNotes() async {
    LocalDataSaver.getImg().then((value) {
      if (this.mounted) {
        setState(() {
          ImgUrl = value;
        });
      }
    });

    this.notesList = await NotesDatabse.instance.readAllNotes();
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  //reads a single note from the database by its ID
  Future getOneNote(int id) async {
    await NotesDatabse.instance.readOneNote(id);
  }

  //updates an existing note
  Future updateOneNote(Note note) async {
    await NotesDatabse.instance.updateNote(note);
  }

  //deletes the note from the database
  Future deleteNote(Note note) async {
    await NotesDatabse.instance.delteNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateNoteView()));
              },
              backgroundColor: cardColor,
              child: Icon(
                Icons.add,
                size: 45,
              ),
            ),
            endDrawerEnableOpenDragGesture: true,
            key: _drawerKey,
            drawer: SideMenu(),
            backgroundColor: bgColor,
            body: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(Duration(seconds: 1), () {
                  /// adding elements in list after [1 seconds] delay
                  /// to mimic network call
                  ///
                  /// Remember: [setState] is necessary so that
                  /// build method will run again otherwise
                  /// list will not show all elements
                  setState(() {});
                });
              },
              child: SafeArea(
                  child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color: black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3)
                              ]),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          _drawerKey.currentState!.openDrawer();
                                        },
                                        icon: Icon(
                                          Icons.menu,
                                          color: white,
                                        )),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchView()));
                                      },
                                      child: Container(
                                          height: 55,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Search Your Notes",
                                                  style: TextStyle(
                                                      color: white
                                                          .withOpacity(0.5),
                                                      fontSize: 14),
                                                )
                                              ])),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      TextButton(
                                          style: ButtonStyle(
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      white.withOpacity(0.1)),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                              ))),
                                          onPressed: () {
                                            setState(() {
                                              isStaggered = !isStaggered;
                                            });
                                          },
                                          child: Icon(
                                            isStaggered!
                                                ? Icons.list
                                                : Icons.grid_view,
                                            //Icons.grid_view,
                                            color: white,
                                          )),
                                      SizedBox(
                                        width: 9,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          // Check if the user is already signed in
                                          final User? currentUser =
                                              await _auth.currentUser;
                                          if (currentUser != null) {
                                            // User is signed in, so sign them out
                                            await googleSignIn.signOut();
                                            await _auth.signOut();
                                            // Save login data to local storage
                                            LocalDataSaver.saveLoginData(false);
                                            // Show toast message
                                            Fluttertoast.showToast(
                                                msg: "Logged out");
                                            // Update UI
                                            setState(() {
                                              ImgUrl =
                                                  'default image url'; // Set default image url
                                            });
                                          } else {
                                            // User is not signed in, so sign them in
                                            await signInWithGoogle();
                                            // Get the user's information
                                            final User? currentUser =
                                                await _auth.currentUser;
                                            LocalDataSaver.saveLoginData(true);
                                            LocalDataSaver.saveImg(currentUser!
                                                .photoURL
                                                .toString());
                                            LocalDataSaver.saveMail(
                                                currentUser.email.toString());
                                            LocalDataSaver.saveName(currentUser
                                                .displayName
                                                .toString());
                                            LocalDataSaver.saveSyncSet(false);
                                            await FireDB().getAllStoredNotes();
                                            // Show toast message
                                            Fluttertoast.showToast(
                                                msg: "Logged in");
                                            // Update UI
                                            setState(() {
                                              ImgUrl = currentUser.photoURL
                                                  .toString(); // Set user's photo url
                                            });
                                            // Navigate to the home screen
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Home()),
                                            );
                                          }
                                        },
                                        child: CircleAvatar(
                                          onBackgroundImageError:
                                              (Object, StackTrace) {
                                            print("Ok");
                                          },
                                          radius: 16,
                                          backgroundImage:
                                              NetworkImage(ImgUrl.toString()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                      isStaggered ? NoteSectionAll() : NotesListSection()
                    ],
                  ),
                ),
              )),
            ));
  }

  //used to display in grid format
  Widget NoteSectionAll() {
    return Container(
        child: Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "ALL",
                style: TextStyle(
                    color: white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            child: StaggeredGridView.countBuilder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: notesList.length,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                crossAxisCount: 4,
                staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                itemBuilder: (context, index) => InkWell(
                      //Wraps each note to handle tap events
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NoteView(note: notesList[index])));
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: white.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(7)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notesList[index].title,
                                style: TextStyle(
                                    color: white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              notesList[index].content.length > 250
                                  ? "${notesList[index].content.substring(0, 250)}..."
                                  : notesList[index].content,
                              style: TextStyle(color: white),
                            )
                          ],
                        ),
                      ),
                    ))),
      ],
    ));
  }

  //displays notes in list format
  Widget NotesListSection() {
    return Container(
        child: Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "ALL",
                style: TextStyle(
                    color: white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: notesList.length,
              itemBuilder: (context, index) => Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: white.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(7)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notesList[index].title,
                        style: TextStyle(
                            color: white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      notesList[index].content.length > 250
                          ? "${notesList[index].content.substring(0, 250)}..."
                          : notesList[index].content,
                      style: TextStyle(color: white),
                    )
                  ],
                ),
              ),
            )),
      ],
    ));
  }
}
