import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/utils/showtoast.dart';
import 'package:project/widget/makedismissible.dart';
import 'package:project/utils/widgettoimage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShareSheet extends StatelessWidget {
  final Widget child;
  const ShareSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MakeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.5,
            builder: (_, controllers) => Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: controllers,
                  children: [
                    FutureBuilder(
                        future: WidgetToImage.takeScreenshot(child),
                        builder: (_, AsyncSnapshot<Uint8List> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.memory(snapshot.data!,
                                  fit: BoxFit.contain),
                            );
                          } else {
                            return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
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
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.camera,
                                  size: 35,
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
                              child: IconButton(
                                onPressed: () async {
                                  await WidgetToImage.takeScreenshot(child)
                                      .then((value) {
                                    WidgetToImage.shareImage(value);
                                  });
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.share,
                                  size: 35,
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
                              child: IconButton(
                                onPressed: () async {
                                  bool result = await WidgetToImage.saveImage(
                                      await WidgetToImage.takeScreenshot(
                                          child));
                                  if (result) {
                                    ShowToast.show('Image saved to gallery',
                                        Colors.green, Colors.white, ToastGravity.BOTTOM);
                                    // Fluttertoast.showToast(
                                    //   msg: 'Image saved to gallery',
                                    //   toastLength: Toast.LENGTH_SHORT,
                                    //   gravity: ToastGravity.BOTTOM,
                                    //   timeInSecForIosWeb: 1,
                                    //   backgroundColor: Colors.green,
                                    //   textColor: Colors.white,
                                    // );
                                  } else {
                                    ShowToast.show(
                                        'Failed to save image',
                                        Colors.red,
                                        Colors.white, ToastGravity.BOTTOM);
                                    // Fluttertoast.showToast(
                                    //   msg: 'Failed to save image',
                                    //   toastLength: Toast.LENGTH_SHORT,
                                    //   gravity: ToastGravity.BOTTOM,
                                    //   timeInSecForIosWeb: 1,
                                    //   backgroundColor: Colors.red,
                                    //   textColor: Colors.white,
                                    // );
                                  }
                                },
                                icon: const Icon(
                                  Icons.download,
                                  size: 35,
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
                ))));
  }
}
