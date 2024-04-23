import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";


Widget MyNetworkImage(String img ,  double? mwidth){
  return CachedNetworkImage(
    width: mwidth,
    imageUrl: img,
    fit: BoxFit.fitWidth,
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}