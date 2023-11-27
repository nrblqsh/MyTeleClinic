import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp( MaterialApp(
    home: EditProfile(),
  ));
}


class EditProfile extends StatefulWidget {

  @override
  State<EditProfile> createState() => _EditProfileState();
}
class _EditProfileState extends State<EditProfile> {
  late String phone;
  late String patientName;
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController icNumController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override

  void initState() {
    //first thing yang akan system buat when comes to this page
    super.initState();
    _loadData(); // Call the method to load data when the widget is initialized
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String storedPhone = prefs.getString("phone") ?? "";
    String storedName = prefs.getString("patientName") ?? "";

    print(storedName);
    print(storedPhone);
    setState(() {
      phone = storedPhone;
      patientName = storedName;
    });
  }

  @override

  Widget editTitle(String label){
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: <Widget> [
          Text(
            label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 18, // Reduce the font size for the label
                fontFamily: 'Inter', fontWeight: FontWeight.w500),),
  ],
    ),
    ],
    ),
    )
    );
  }


  Widget txtField( String innerText, TextEditingController controller, IconData iconData, TextInputType inputType) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(

              hintText: innerText,
              prefixIcon: Icon(iconData),
              border: loginInputBorder(),
              enabledBorder: loginInputBorder(),
              focusedBorder: loginFocusedBorder(),
            ),
            keyboardType: inputType,
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.blue,
        ),
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
             child: GestureDetector(
               onTap: (){
                 print("circl avarat");
               },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("asset/logo.png"),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Icon(
                      Icons.edit,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            ),
            SizedBox(height: 15),
            Text(
             // patientName ?? '',
              "test",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              phone ?? '',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0,),

            editTitle('Edit Profile'),
            txtField(
                patientName ?? '', phoneController,
                Icons.person, TextInputType.phone),

            editTitle('Change Password'),

            Padding(
              padding: const EdgeInsets.only( left: 15.0, top: 10.0),
              child: Row(
                  children: <Widget> [
                    Text('General',
                      style: TextStyle(decoration: TextDecoration.none,
                          fontSize: 30.0,
                          fontFamily: 'Inter', fontWeight: FontWeight.w700),),
                  ]
              ),
            ),
          ],

        ),


      ),
    );
  }
}


OutlineInputBorder loginInputBorder(){
  return OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(color: Colors.grey, width:3,),

  );
}

/*
  when user click the specific textfield,
  the colour of the border will change
 */
OutlineInputBorder loginFocusedBorder()
{
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(
          Radius.circular(20)),
      borderSide: BorderSide(color:Color(
          hexColor('#024362')),
          width: 3)
  );
}

int hexColor(String color)
{
  String newColor = '0xff' + color;
  newColor= newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}