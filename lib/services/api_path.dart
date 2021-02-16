import 'package:flutter/foundation.dart' show required;

class APIPath {
  static String job({
    @required String uid,
    @required String jobId,
  }) =>
      'users/$uid/jobs/$jobId';

  static String jobs({@required String uid}) => 'users/$uid/jobs';

  static String entry(String uid, String entryId) =>
      'users/$uid/entries/$entryId';

  static String entries(String uid) => 'users/$uid/entries';
}
