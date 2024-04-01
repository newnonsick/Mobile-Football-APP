import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/page/camerapage.dart';
import 'package:project/utils/showtoast.dart';
import 'package:project/widget/makedismissible.dart';
import 'package:project/utils/widgettoimage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../provider/coins_provider.dart';

class ShareSheet extends StatelessWidget {
  final Widget child;
  const ShareSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MakeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (_, controllers) => Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Column(
                  children: [
                    Container(
                      height: 7,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.pink[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Share Image',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 15),
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                "* Use 2 coins per share",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                                child: Consumer<CoinModel>(
                                  builder: (context, model, child) => Text(
                                    '${model.coins}',
                                    style: TextStyle(
                                      color: Colors.pink[800],
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('coins',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder(
                              future: WidgetToImage.takeScreenshot(child),
                              builder: (_, AsyncSnapshot<Uint8List> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    width: double.infinity,
                                    child: Image.memory(snapshot.data!,
                                        fit: BoxFit.contain),
                                  );
                                } else {
                                  return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      width: double.infinity,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ));
                                }
                              }),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Consumer<CoinModel>(
                                      builder: (context, model, child2) => IconButton(
                                        onPressed: () async {
                                          if (model.coins < 2) {
                                            ShowToast.show(
                                                'Not enough coins to take photo',
                                                Colors.red,
                                                Colors.white,
                                                ToastGravity.BOTTOM);
                                            return;
                                          }
                                          final camera = await availableCameras();
                                          final image =
                                              await WidgetToImage.takeScreenshot(
                                                  child);
                                          Get.to(() => CamearaPage(
                                              cameras: camera, image: image));
                                        },
                                        icon: const Icon(
                                          Icons.camera,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Camera')
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Consumer<CoinModel>(
                                      builder: (context, model, child2) =>
                                          IconButton(
                                        onPressed: () async {
                                          if (model.coins < 2) {
                                            ShowToast.show(
                                                'Not enough coins to share',
                                                Colors.red,
                                                Colors.white,
                                                ToastGravity.BOTTOM);
                                            return;
                                          }
                                          final image = await WidgetToImage
                                              .takeScreenshot(child);
                                          bool result =
                                              await WidgetToImage.shareImage(
                                                  image);
                                          if (result) {
                                            model.decrement(2);
                                            Get.back();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.share,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Share')
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Consumer<CoinModel>(
                                      builder: (context, model, child2) =>
                                          IconButton(
                                        onPressed: () async {
                                          if (model.coins < 2) {
                                            ShowToast.show(
                                                'Not enough coins to download',
                                                Colors.red,
                                                Colors.white,
                                                ToastGravity.BOTTOM);
                                            return;
                                          }
                                          final image = await WidgetToImage
                                              .takeScreenshot(child);
                                          bool result =
                                              await WidgetToImage.saveImage(
                                                  image);
                                          if (result) {
                                            model.decrement(2);
                                            ShowToast.show(
                                                'Image saved to gallery',
                                                Colors.green,
                                                Colors.white,
                                                ToastGravity.BOTTOM);
                                          } else {
                                            ShowToast.show(
                                                'Failed to save image',
                                                Colors.red,
                                                Colors.white,
                                                ToastGravity.BOTTOM);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.download,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Download')
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
