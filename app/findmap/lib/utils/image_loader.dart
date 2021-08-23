import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<String> _noneThumbnailUrl = [];

Widget imageLoader(AnimationController controller, String url) {
  if (_noneThumbnailUrl.contains(url)) {
    return Image.asset('assets/archive_basic.png', fit: BoxFit.cover);
  }
  return ExtendedImage.network(
    url,
    fit: BoxFit.cover,
    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          controller.reset();
          return Image.asset(
            "assets/loading.gif",
            fit: BoxFit.fill,
          );

        case LoadState.completed:
          controller.forward();
          return FadeTransition(
            opacity: controller,
            child: ExtendedRawImage(
              image: state.extendedImageInfo?.image,
            ),
          );

        case LoadState.failed:
          controller.reset();
          _noneThumbnailUrl.add(url);
          return GestureDetector(
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Image.asset(
                  "assets/archive_basic.png",
                  fit: BoxFit.cover,
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
              // state.reLoadImage();
            },
          );
      }
    },
  );
}

Widget circleImageLoader(AnimationController controller, String url) {
  if (_noneThumbnailUrl.contains(url)) {
    return CircleAvatar(
      radius: 30.0,
      backgroundImage: AssetImage('assets/logo.png'),
      backgroundColor: Colors.transparent,
    );
  }
  return ExtendedImage.network(
    url,
    fit: BoxFit.cover,
    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          controller.reset();
          return Container();

        case LoadState.completed:
          controller.forward();
          return FadeTransition(
            opacity: controller,
            child: ExtendedRawImage(
              image: state.extendedImageInfo?.image,
            ),
          );

        case LoadState.failed:
          controller.reset();
          _noneThumbnailUrl.add(url);
          return CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage('assets/logo.png'),
            backgroundColor: Colors.transparent,
          );
      }
    },
  );
}
