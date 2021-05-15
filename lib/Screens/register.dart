import 'dart:io';

import 'package:assign/Database/dbHelper.dart';
import 'package:assign/Models/models.dart';
import 'package:assign/Screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  DBHelper _dbHelper;
  Client client = Client();
  var formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  File _image;
  final picker = ImagePicker();
  String clientPickedImagePath;

  String productValue;
  String amountTypeValue;
  DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DBHelper.instance;
      clientPickedImagePath = null;
      productValue = null;
      amountTypeValue = null;
      _dateTime = null;
    });
  }

  void _submit() async {
    var check = formKey.currentState;

    // Validate Form
    if (nameController.text != "" &&
        phoneController.text != "" &&
        amountController.text != "" &&
        productValue != null &&
        amountTypeValue != null &&
        clientPickedImagePath != null &&
        _dateTime != null) {
      check.save();

      // Store Client Selected Profile Image in App Local Directory
      final appDir = await getApplicationDocumentsDirectory();
      final pickedImageName = path.basename(clientPickedImagePath);
      final imageExtension = pickedImageName.split(".");
      final finalImageName = "${nameController.text}.${imageExtension[1]}";
      final localImageDir = await _image.copy('${appDir.path}/$finalImageName');
      String _date = "$_dateTime".split(" ")[0];

      // fill value
      client.date = _date;
      client.profileImagePath = localImageDir.path;

      // insert to databse
      await _dbHelper.insertRegister(client);

      // Show SnakBar
      snanBar("Registration Successfull");

      // Navigate Home Page
      Navigator.push(context, MaterialPageRoute(builder: (builder) => RegOX()));
    } else {
      if (clientPickedImagePath == null) {
        snanBar("Please Upload Photo");
      } else if (nameController.text == "") {
        snanBar("Please Enter Nmae");
      } else if (phoneController.text == "") {
        snanBar("Please Enter Phone number");
      } else if (productValue == null) {
        snanBar("Product Value Required");
      } else if (amountController.text == "") {
        snanBar("Please Enter Amount");
      } else if (amountTypeValue == null) {
        snanBar("Amount Type Required");
      } else if (_dateTime == null) {
        snanBar("Please Select Date");
      }
    }
  }

  //  Open Phone Storage for choose image
  Future _getImage() async {
    PickedFile imageFile = await picker.getImage(source: ImageSource.gallery);
    final file = File(imageFile.path);

    if (imageFile != null) {
      setState(() {
        _image = file;
        clientPickedImagePath = imageFile.path;
      });
    }
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: size.height * 0.85,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 0), blurRadius: 10, color: Colors.grey)
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: _image != null
                          ? FileImage(_image)
                          : AssetImage("assets/images/noUser.png"),
                      radius: 50,
                    ),
                    TextButton.icon(
                      onPressed: _getImage,
                      icon: Icon(Icons.camera),
                      label: Text("Select Photo"),
                    ),
                    SizedBox(height: 10),
                    buildNameTextFormField(),
                    SizedBox(height: 10),
                    buildPhoneTextFormField(),
                    SizedBox(height: 10),
                    buildProductDropDown(),
                    SizedBox(height: 10),
                    buildAmountTextFormField(),
                    SizedBox(height: 10),
                    buildAmountDropDown(),
                    SizedBox(height: 10),
                    buildDatePicker(),
                    SizedBox(height: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 255, 105, 138),
                        )),
                        onPressed: _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void snanBar(String text) {
    var snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Container buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0), blurRadius: 5, color: Colors.grey[700])
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Select Date"),
            Text(_dateTime != null ? "$_dateTime".split(" ")[0] : ""),
            TextButton.icon(
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1998),
                          lastDate: DateTime(2222))
                      .then((date) {
                    setState(() {
                      _dateTime = date;
                    });
                  });
                },
                icon: Icon(Icons.date_range),
                label: Text("Select"))
          ],
        ),
      ),
    );
  }

  Container buildAmountDropDown() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0), blurRadius: 5, color: Colors.grey[700])
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Amount Type "),
            DropdownButton(
              elevation: 0,
              hint: Text("Select"),
              value: amountTypeValue,
              onChanged: (value) {
                setState(() {
                  amountTypeValue = value;
                  client.amountType = value;
                });
              },
              items: [
                DropdownMenuItem(value: "Cash", child: Text("Cash")),
                DropdownMenuItem(value: "Online", child: Text("Online")),
                DropdownMenuItem(value: "Gpay", child: Text("Gpay")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container buildProductDropDown() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0), blurRadius: 5, color: Colors.grey[700])
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Product Type "),
            DropdownButton(
              elevation: 0,
              hint: Text("Select"),
              value: productValue,
              onChanged: (value) {
                setState(() {
                  productValue = value;
                  client.productType = value;
                });
              },
              items: [
                DropdownMenuItem(value: "Product", child: Text("Product")),
                DropdownMenuItem(value: "Service", child: Text("Service"))
              ],
            )
          ],
        ),
      ),
    );
  }

  Container buildPhoneTextFormField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(offset: Offset(0, 0), blurRadius: 5, color: Colors.grey)
          ]),
      child: TextFormField(
        controller: phoneController,
        onSaved: (value) {
          setState(() {
            client.phoneNumber = int.parse(value);
          });
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: "Enter Phone Number",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Container buildNameTextFormField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(offset: Offset(0, 0), blurRadius: 5, color: Colors.grey)
          ]),
      child: TextFormField(
        controller: nameController,
        onSaved: (value) {
          setState(() {
            client.fullname = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Enter Your Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Container buildAmountTextFormField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(offset: Offset(0, 0), blurRadius: 5, color: Colors.grey)
          ]),
      child: TextFormField(
        controller: amountController,
        onSaved: (value) {
          setState(() {
            client.amount = "$value";
          });
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: "Enter Amount",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
