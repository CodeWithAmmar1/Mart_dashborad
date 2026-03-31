import 'package:dashboard/fronthend/view/martdashbord.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MART',
      home: MartDashboard(),
    );
  }
}
// https://martinventory.netlify.app/ frontend link
// https://martdashborad-production.up.railway.app/api/items backend link 
// https://railway.com/project/5e52deb7-0ce6-4ed6-aac4-2c1cb29f4ffc/service/1fb7b445-b625-447f-af22-6e32e9bb5444?environmentId=191a9cd0-bea0-41f5-b6c3-0821ea60aac4 backend link where live