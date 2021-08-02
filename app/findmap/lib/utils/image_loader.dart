import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

Widget imageLoader(AnimationController controller, String url) {
  return ExtendedImage.network(
    url,
    fit: BoxFit.fill,
    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          controller.reset();
          return Image.asset(
            "assets/loading.gif",
            fit: BoxFit.fill,
          );
          break;

        case LoadState.completed:
          controller.forward();
          return FadeTransition(
            opacity: controller,
            child: ExtendedRawImage(
              image: state.extendedImageInfo?.image,
            ),
          );
          break;
        case LoadState.failed:
          controller.reset();
          return GestureDetector(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  "assets/archive_basic.png",
                  fit: BoxFit.fill,
                ),
                // Positioned(
                //   bottom: 0.0,
                //   left: 0.0,
                //   right: 0.0,
                //   child: Text(
                //     "load image failed, click to reload",
                //     textAlign: TextAlign.center,
                //   ),
                // )
              ],
            ),
            onTap: () {
              state.reLoadImage();
            },
          );
          break;
      }
    },
  );
}
