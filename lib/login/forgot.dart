import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title : Text("Reset Password",style:TextStyle(color:Colors.white)),
          automaticallyImplyLeading: true,
          backgroundColor:  Color(0xff50008e),
        ),
        body : Column(
          children: [
            SizedBox(height: 20,),
            Center(child: Text("Forgot Password ?", style: TextStyle( color : Colors.black,fontFamily: "font1", fontSize: 30, fontWeight: FontWeight.w700))),
            SizedBox(height : 20),
            Image.network("https://assets-v2.lottiefiles.com/a/4a774176-1171-11ee-ae48-bf87d1dea7a3/votYo4X96y.gif", height : 200),
            SizedBox(height : 15),
            Center(child: Text("No Worries ! Just write your Email, and we would send you reset link", style: TextStyle( color : Colors.black,fontFamily: "font1", fontSize: 17, fontWeight: FontWeight.w400), textAlign: TextAlign.center,)),
            SizedBox(height : 5),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Your Email',  isDense: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your School email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            InkWell(
              onTap:()async{
                if(_emailController.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email Can\'t be left Empty '),
                    ),
                  );
                }else{
                  try{
                    final credential = await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sent Successful ! Check your Mail'),
                      ),
                    );
                    Navigator.pop(context);
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${e}'),
                      ),
                    );
                  }
                }
              },
              child: Center(
                child: Container(
                  height:45,width:w-40,
                  decoration:BoxDecoration(
                    borderRadius:BorderRadius.circular(7),
                    color:Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4), // Shadow color with transparency
                        spreadRadius: 5, // The extent to which the shadow spreads
                        blurRadius: 7, // The blur radius of the shadow
                        offset: Offset(0, 3), // The position of the shadow
                      ),
                    ],
                  ),
                  child: Center(child: Text("Reset Now",style: TextStyle(
                      color: Colors.white,
                      fontFamily: "RobotoS",fontWeight: FontWeight.w800
                  ),)),
                ),
              ),
            ),
          ],
        )
    );
  }
}
