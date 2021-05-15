import 'dart:io';

import 'package:assign/Database/dbHelper.dart';
import 'package:assign/Models/models.dart';
import 'package:assign/Screens/export.dart';
import 'package:assign/Screens/register.dart';

import 'package:flutter/material.dart';

class RegOX extends StatefulWidget {
  @override
  _RegOXState createState() => _RegOXState();
}

class _RegOXState extends State<RegOX> with SingleTickerProviderStateMixin {
  DBHelper _dbHelper;
  Client client = Client();
  List<Client> listOfClient = [];
  String startDateTime;
  String endDateTime;
  String fileFormat;

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animationIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double fabHeight = 56.0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DBHelper.instance;
      fileFormat = null;
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      )..addListener(() {
          setState(() {});
        });

      _animationIcon =
          Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
      _buttonColor = ColorTween(
              begin: Color.fromARGB(255, 248, 78, 107), end: Colors.green)
          .animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0, 1, curve: Curves.linear),
        ),
      );

      _translateButton = Tween<double>(begin: fabHeight, end: -14.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.0, 0.75, curve: _curve),
        ),
      );
    });
    _refresh();
  }

  _animate() {
    if (isOpened)
      _animationController.forward();
    else
      _animationController.reverse();
    isOpened = !isOpened;
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void _refresh() async {
    List<Client> _listOfClient = await _dbHelper.getAllData();
    setState(() {
      listOfClient = _listOfClient;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 105, 138),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/images/icon.png",
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _refresh,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.refresh,
              ),
            ),
          )
        ],
      ),
      body: listOfClient == null
          ? CircularProgressIndicator()
          : Container(
              height: size.height * 0.9,
              width: double.infinity,
              child: ListView.builder(
                  itemCount: listOfClient.length,
                  itemBuilder: (context, index) => Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: FileImage(
                                  File(listOfClient[index].profileImagePath)),
                            ),
                            title: Text(
                              "${listOfClient[index].fullname} - ${listOfClient[index].phoneNumber}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${listOfClient[index].date}",
                            ),
                            trailing: Container(
                              height: 100,
                              width: 70,
                              child: Text(
                                "\$${listOfClient[index].amount}",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                          )
                        ],
                      )),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Transform(
            transform: Matrix4.translationValues(
                0.0, _translateButton.value * 2.0, 0.0),
            child: buttonAdd(),
          ),
          Transform(
            transform:
                Matrix4.translationValues(0.0, _translateButton.value, 0.0),
            child: buttonExport(),
          ),
          buttonToggle()
        ],
      ),
    );
  }

  Widget buttonToggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: _animate,
        child: AnimatedIcon(
          icon: AnimatedIcons.add_event,
          progress: _animationIcon,
        ),
      ),
    );
  }

  Widget buttonAdd() {
    return Container(
      child: FloatingActionButton(
        tooltip: "Add",
        backgroundColor: Color.fromARGB(255, 255, 204, 107),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => Register()));
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget buttonExport() {
    return Container(
      child: FloatingActionButton(
        tooltip: "Export",
        backgroundColor: Color.fromARGB(255, 255, 204, 107),
        onPressed: _showDialog,
        child: Icon(Icons.logout, color: Colors.black),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Export Data"),
        content: Container(
          height: 150,
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Start Date",
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                      onPressed: () {
                        showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1998),
                                lastDate: DateTime(2222))
                            .then((date) {
                          String _date = "$date".split(" ")[0];
                          setState(() {
                            startDateTime = _date;
                          });
                        });
                      },
                      child: Text(
                        "select",
                        style: TextStyle(fontSize: 15),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "End Date",
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1998),
                              lastDate: DateTime(2222))
                          .then((date) {
                        String _date = "$date".split(" ")[0];
                        setState(() {
                          endDateTime = _date;
                        });
                      });
                    },
                    child: Text(
                      "Select",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("File Format"),
                  DropdownButton(
                    elevation: 0,
                    hint: Text("Select"),
                    value: fileFormat,
                    onChanged: (value) {
                      setState(() {
                        fileFormat = value;
                      });
                      var snackBar =
                          SnackBar(content: Text("$fileFormat selected"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    items: [
                      DropdownMenuItem(value: "csv", child: Text("csv")),
                      DropdownMenuItem(value: "xlsx", child: Text("xlsx"))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            onPressed: () {
              Export.export(
                  listOfClient, fileFormat, startDateTime, endDateTime);
              var snackBar = SnackBar(content: Text("Export Successfull"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.of(context).pop();
            },
            child: Text("Export"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          )
        ],
      ),
    );
  }
}
