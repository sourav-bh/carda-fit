import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

CachedNetworkImage buildCacheNetworkImage({double? width, double? height, url, plColor, imageColor}){
  if(width == 0 && height == 0){
    return CachedNetworkImage(
      placeholder: (context, url) {
        return Container(
          color: plColor ?? Colors.grey[500],
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey[500],
        );
      },
      imageUrl: url,
      fit: BoxFit.cover,
      color: imageColor,
    );
  } else if(height == 0){
    return CachedNetworkImage(
      placeholder: (context, url) {
        return Container(
          width: width,
          color: plColor ?? Colors.grey[500],
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          width: width,
          color: Colors.grey[500],
        );
      },
      imageUrl: url,
      fit: BoxFit.cover,
      width: width,
      color: imageColor,
    );
  } else {
    return CachedNetworkImage(
      placeholder: (context, url) {
        return const SizedBox.shrink();
      },
      errorWidget: (context, url, error) {
        return const SizedBox.shrink();
      },
      imageUrl: url,
      fit: BoxFit.cover,
      width: width,
      height: height,
      color: imageColor,
    );
  }
}