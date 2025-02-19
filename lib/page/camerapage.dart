// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:project/provider/coins_provider.dart';
// import 'package:project/utils/showtoast.dart';
// import 'package:project/utils/widgettoimage.dart';
// import 'package:provider/provider.dart';

// class CamearaPage extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   final Uint8List image;

//   const CamearaPage({super.key, required this.cameras, required this.image});

//   @override
//   State<CamearaPage> createState() => _CamearaPageState();
// }

// class _CamearaPageState extends State<CamearaPage> {
//   late CameraController controller;
//   late Future<void> _initializeControllerFuture;
//   Offset _imagePosition = const Offset(0, 0);

//   Future<void> initialCamera() async {
//     controller =
//         CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
//     _initializeControllerFuture = controller.initialize();
//   }

//   @override
//   void initState() {
//     super.initState();
//     initialCamera();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _imagePosition = Offset(
//             (MediaQuery.of(context).size.width -
//                     MediaQuery.of(context).size.width * 0.4) /
//                 2,
//             0);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   void _takePicture() async {
//     int coins = Provider.of<CoinModel>(context, listen: false).coins;
//     if (coins < 2) {
//       ShowToast.show(
//           'Not enough coins', Colors.red, Colors.white, ToastGravity.BOTTOM);
//       return;
//     }

//     final image = await WidgetToImage.takeScreenshot(Stack(
//       children: [
//         SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height * 0.75,
//           child: CameraPreview(controller),
//         ),
//         Positioned(
//           left: _imagePosition.dx,
//           top: _imagePosition.dy,
//           child: Image.memory(
//             widget.image,
//             fit: BoxFit.contain,
//             width: MediaQuery.of(context).size.width * 0.4,
//             height: MediaQuery.of(context).size.height * 0.2,
//             alignment: Alignment.center,
//           ),
//         ),
//       ],
//     ));

//     bool result = await WidgetToImage.saveImage(image);
//     if (result) {
//       Provider.of<CoinModel>(context, listen: false).decrement(2);
//       ShowToast.show('Image saved to gallery', Colors.green, Colors.white,
//           ToastGravity.BOTTOM);
//     } else {
//       ShowToast.show('Failed to save image', Colors.red, Colors.white,
//           ToastGravity.BOTTOM);
//     }
//   }

//   void _swapCamera() {
//     final CameraLensDirection newDirection =
//         controller.description.lensDirection == CameraLensDirection.back
//             ? CameraLensDirection.front
//             : CameraLensDirection.back;
//     _initializeControllerFuture = controller.dispose().then((_) {
//       controller = CameraController(
//           widget.cameras
//               .firstWhere((camera) => camera.lensDirection == newDirection),
//           ResolutionPreset.ultraHigh);
//       return controller.initialize();
//     });
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.black,
//     ));

//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Column(
//               children: [
//                 SafeArea(
//                   child: Stack(
//                     children: [
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         height: MediaQuery.of(context).size.height * 0.75,
//                         child: CameraPreview(controller),
//                       ),
//                       Positioned(
//                         left: _imagePosition.dx,
//                         top: _imagePosition.dy,
//                         child: GestureDetector(
//                           onPanUpdate: (details) {
//                             setState(() {
//                               _imagePosition += details.delta;
//                               if (_imagePosition.dx < 0) {
//                                 _imagePosition = Offset(0, _imagePosition.dy);
//                               } else if (_imagePosition.dy < 0) {
//                                 _imagePosition = Offset(_imagePosition.dx, 0);
//                               } else if (_imagePosition.dx >
//                                   MediaQuery.of(context).size.width * 0.6) {
//                                 _imagePosition = Offset(
//                                   MediaQuery.of(context).size.width * 0.6,
//                                   _imagePosition.dy,
//                                 );
//                               } else if (_imagePosition.dy >
//                                   MediaQuery.of(context).size.height * 0.6) {
//                                 _imagePosition = Offset(
//                                   _imagePosition.dx,
//                                   MediaQuery.of(context).size.height * 0.6,
//                                 );
//                               }
//                             });
//                           },
//                           child: Image.memory(
//                             widget.image,
//                             fit: BoxFit.contain,
//                             width: MediaQuery.of(context).size.width * 0.4,
//                             height: MediaQuery.of(context).size.height * 0.2,
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                       ),
//                       SafeArea(
//                         child: Opacity(
//                           opacity: 0.7,
//                           child: Container(
//                             margin: const EdgeInsets.only(left: 15),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: IconButton(
//                                 icon: const Icon(Icons.arrow_back_ios_rounded),
//                                 onPressed: () {
//                                   Get.back();
//                                 }),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     color: Colors.black,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Consumer<CoinModel>(
//                                 builder: (context, model, child) => Center(
//                                       child: Text(
//                                         _formatCoins(model.coins),
//                                         style: TextStyle(
//                                           color: Colors.pink[800],
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ))),
//                         Container(
//                           height: 70,
//                           width: 70,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(50),
//                             border:
//                                 Border.all(color: Colors.grey[800]!, width: 7),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.circle,
//                                   color: Colors.white,
//                                   size: 38,
//                                 ),
//                                 onPressed: _takePicture,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           height: 50,
//                           width: 50,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[800]!,
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.flip_camera_ios,
//                               color: Colors.white,
//                             ),
//                             onPressed: _swapCamera,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return SafeArea(
//               child: Column(
//                 children: [
//                   Stack(
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width,
//                         height: MediaQuery.of(context).size.height * 0.75,
//                         color: Colors.black,
//                       ),
//                       Positioned(
//                         left: _imagePosition.dx,
//                         top: _imagePosition.dy,
//                         child: GestureDetector(
//                           onPanUpdate: (details) {
//                             setState(() {
//                               _imagePosition += details.delta;
//                               if (_imagePosition.dx < 0) {
//                                 _imagePosition = Offset(0, _imagePosition.dy);
//                               } else if (_imagePosition.dy < 0) {
//                                 _imagePosition = Offset(_imagePosition.dx, 0);
//                               } else if (_imagePosition.dx >
//                                   MediaQuery.of(context).size.width * 0.6) {
//                                 _imagePosition = Offset(
//                                   MediaQuery.of(context).size.width * 0.6,
//                                   _imagePosition.dy,
//                                 );
//                               } else if (_imagePosition.dy >
//                                   MediaQuery.of(context).size.height * 0.8) {
//                                 _imagePosition = Offset(
//                                   _imagePosition.dx,
//                                   MediaQuery.of(context).size.height * 0.8,
//                                 );
//                               }
//                             });
//                           },
//                           child: Image.memory(
//                             widget.image,
//                             fit: BoxFit.contain,
//                             width: MediaQuery.of(context).size.width * 0.4,
//                             height: MediaQuery.of(context).size.height * 0.2,
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                       ),
//                       SafeArea(
//                         child: Opacity(
//                           opacity: 0.7,
//                           child: Container(
//                             margin: const EdgeInsets.only(left: 15),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: IconButton(
//                                 icon: const Icon(Icons.arrow_back_ios_rounded),
//                                 onPressed: () {
//                                   Get.back();
//                                 }),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Container(
//                       color: Colors.black,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Consumer<CoinModel>(
//                                   builder: (context, model, child) => Center(
//                                         child: Text(
//                                           _formatCoins(model.coins),
//                                           style: TextStyle(
//                                             color: Colors.pink[800],
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ))),
//                           Container(
//                             height: 70,
//                             width: 70,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(50),
//                               border: Border.all(
//                                   color: Colors.grey[800]!, width: 7),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(
//                                     Icons.circle,
//                                     color: Colors.white,
//                                     size: 38,
//                                   ),
//                                   onPressed: _takePicture,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             height: 50,
//                             width: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[800]!,
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.flip_camera_ios,
//                                 color: Colors.white,
//                               ),
//                               onPressed: _swapCamera,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   String _formatCoins(int coins) {
//     if (coins >= 100000000000000) {
//       return '${(coins / 1000000000000).toStringAsFixed(1)}T';
//     } else if (coins >= 10000000000000) {
//       return '${(coins / 1000000000000).toStringAsFixed(0)}T';
//     } else if (coins >= 1000000000000) {
//       return '${(coins / 1000000000000).toStringAsFixed(1)}T';
//     } else if (coins >= 10000000000) {
//       return '${(coins / 1000000000).toStringAsFixed(0)}B';
//     } else if (coins >= 1000000000) {
//       return '${(coins / 1000000000).toStringAsFixed(1)}B';
//     } else if (coins >= 10000000) {
//       return '${(coins / 1000000).toStringAsFixed(0)}M';
//     } else if (coins >= 1000000) {
//       return '${(coins / 1000000).toStringAsFixed(1)}M';
//     } else if (coins >= 10000) {
//       return '${(coins / 1000).toStringAsFixed(0)}K';
//     } else if (coins >= 1000) {
//       return '${(coins / 1000).toStringAsFixed(1)}K';
//     } else {
//       return '$coins';
//     }
//   }
// }
