import 'package:flutter/material.dart';
import 'package:note/colors.dart';
import 'package:note/model/note_model.dart';
import 'package:note/screen/home.dart';
import 'package:note/services.dart/sql.dart';
import 'package:uuid/uuid.dart';


class CreateNoteView extends StatefulWidget {
  const CreateNoteView({Key? key}) : super(key: key);
  @override
  State<CreateNoteView> createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends State<CreateNoteView> {
  TextEditingController title = new TextEditingController();
  TextEditingController content = new TextEditingController();
  var uuid = Uuid();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    title.dispose();
    content.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () async {
                await NotesDatabse.instance.InsertEntry(Note(
                    title: title.text,
                    uniqueID: uuid.v1(),
                    content: content.text,
                    pin: false,
                    isArchived: false,
                    createdTime: DateTime.now()));
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home()));
              },
              splashRadius: 17,
              icon: Icon(Icons.save_outlined))
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            TextField(
              cursorColor: white,
              controller: title,
              style: TextStyle(fontSize: 25, color: Colors.white),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: "Title",
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.8))),
            ),
            Container(
              height: 300,
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 50,
                maxLines: null,
                cursorColor: white,
                controller: content,
                style: TextStyle(fontSize: 17, color: Colors.white),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: "New Notes",
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.8))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
