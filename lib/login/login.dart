import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:student_next_lights_bus/login/forgot.dart';
import 'package:student_next_lights_bus/main.dart';
import 'package:student_next_lights_bus/mainpage/navigation.dart';
import 'package:student_next_lights_bus/model/bus.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_login/twitter_login.dart';

import '../global/send.dart';

class ProfileM extends StatefulWidget {
  String str;
  ProfileM({super.key,required this.str});

  @override
  State<ProfileM> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileM> {

  bool signup=false;

  siugn()async{
    await FirebaseAuth.instance.signOut();
  }
  bool on=false;
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation:0,
      ),
      body: Stack(
        children: [
          Container(
            width: w,height: h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/main_top.png",height: 200,),
                Spacer(),
                Row(
                  children: [
                    Image.asset("assets/main_bottom.png",height: 20,),
                    Spacer(),
                    Image.asset("assets/login_bottom.png",height: 150,),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: w,height: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0,right: 14,top: 14),
                  child: Text("Login to your Profile",
                    style: TextStyle(fontWeight: FontWeight.w800,fontSize: 24),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0,right: 14),
                  child: Text("Please login to your Bus Profile",
                    style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                ),
                SizedBox(height: 13,),
                Center(child: Image.asset("assets/logo.png",width: MediaQuery.of(context).size.width-120,)),
                SizedBox(height: 13,),
                fg(email,"Type your Email","Type your Email"),
                fg(password,"Type your Password","Password"),
                SizedBox(height: 15,),
                on?Center(child: CircularProgressIndicator()):InkWell(
                  onTap:() async {
                    setState(() {
                      on=true;
                    });
                      print("NO------------------------------------------------------>");
                      try {
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email.text,
                          password: password.text,
                        );
                      }on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          setState(() {
                            on=false;
                          });
                          print('No user found for that email.');
                          Send.message(context, "No User found for this Email",false);
                        } else if (e.code == 'wrong-password') {
                          setState(() {
                            on=false;
                          });
                          print('Wrong password provided for that user.');
                          Send.message(context, "Wrong password provided for that user",false);
                        } else {
                          setState(() {
                            on=false;
                          });
                          Send.message(context, "${e}",false);
                        }
                      }finally{
                        Timer(Duration(seconds: 5), () {
                          Send.message(context, "Listening.......",true);
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => MyHomePage(title: true)));
                        });

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
                      child: Center(child: Text(signup?"Sign Up":"Login Now",style: TextStyle(
                          color: Colors.white,
                          fontFamily: "RobotoS",fontWeight: FontWeight.w800
                      ),)),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 10,),
                    TextButton(onPressed: () {
                      Send.message(context, "Ask School to create New User for Bus", false);
                    }, child: Text("New User? Sign Up here"),),
                    Spacer(),
                    TextButton(onPressed: () {
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => Forgot()));
                    }, child: Text("Forgot Password?"),),
                    SizedBox(width: 10,),
                  ],
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fg(TextEditingController ha,String str, String str2)=> Padding(
    padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 10),
    child: TextFormField(
      controller: ha,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: str,
        hintText: str2,
        isDense: true,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please type It';
        }
        return null;
      },
    ),
  );

  TextEditingController name=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController verify=TextEditingController();
  TextEditingController password=TextEditingController();

  Widget c(bool d,double w)=>Container(
    width: w/3-15,height: 10,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(9),
      color: d?Colors.blueAccent:Colors.grey.shade300,
    ),
  );
  Widget q(BuildContext context, String asset, String str,String str1) {
    double d = MediaQuery.of(context).size.width / 2 - 30;
    double h = MediaQuery.of(context).size.width / 2 - 115;
    return Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color with transparency
              spreadRadius: 5, // The extent to which the shadow spreads
              blurRadius: 7, // The blur radius of the shadow
              offset: Offset(0, 3), // The position of the shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                asset,
                semanticsLabel: 'Acme Logo',
                height: h,
              ),
              SizedBox(height: 15),
              Text(str, style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "Li")),
            ]));
  }
}

