import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/value_objects/coastin_country_label.dart';

String coastalPostOriginLine(CoastalPostDispatch post) {
  return coastinCountryForPersona(
    post.shorelineKeeper,
    localApproachRibbon: post.localApproachRibbon,
  );
}

int coastalPostReplyCount(CoastalPostDispatch post) => post.commentTideMarks.length;
