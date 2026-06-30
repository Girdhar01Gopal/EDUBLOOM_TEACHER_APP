// import 'package:eduagent/utils/constans.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
//
// class MyHeader extends StatefulWidget {
//   final String image;
//   final String textTop;
//   final String textBottom;
//   final double offset;
//   const MyHeader(
//       {Key? key,
//       required this.image,
//       required this.textTop,
//       required this.textBottom,
//       required this.offset})
//       : super(key: key);
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _MyHeaderState createState() => _MyHeaderState();
// }
//
// class _MyHeaderState extends State<MyHeader> {
//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: MyClipper(),
//       child: Container(
//         padding: const EdgeInsets.only(left: 40, top: 50, right: 20),
//         height: 300,
//         width:Get.width,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: [
//               Colors.deepPurpleAccent,
//               Colors.purple,
//               Colors.purpleAccent,
//             ],
//           ),
//           image: DecorationImage(
//             image: AssetImage("assets/images/logo.png"),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: <Widget>[
//             const SizedBox(height: 30),
//             Expanded(
//               child: Stack(
//                 children: <Widget>[
//                   Positioned(
//                     top: (widget.offset < 0) ? 0 : widget.offset,
//                     child: SvgPicture.asset(
//                       widget.image,
//                       width: 270,
//                       fit: BoxFit.fitWidth,
//                       alignment: Alignment.bottomLeft,
//                     ),
//                   ),
//                   Positioned(
//                     top: 20 - widget.offset / 2,
//                     left: 140,
//                     child: Text(
//                       "${widget.textTop} \n${widget.textBottom}",
//                       style: kHeadingTextStyle.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   Container(), // I dont know why it can't work without container
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MyClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 80);
//     path.quadraticBezierTo(
//         size.width / 2, size.height, size.width, size.height - 80);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }
