import 'package:flutter/foundation.dart' show required;
import 'package:time_tracker/services/api_path.dart';
import 'package:time_tracker/services/firestore_service.dart';

import './api_path.dart';
import './firestore_service.dart';
import '../app/home/models/entry.dart';
import '../app/home/models/job.dart';

abstract class Database {
  Future<void> setJob(Job job);

  Future<void> deleteJob(Job job);

  Stream<Job> jobStream(String jobId);

  Stream<List<Job>> jobsStream();

  Future<void> setEntry(Entry entry);

  Future<void> deleteEntry(Entry entry);

  Stream<List<Entry>> entriesStream({Job job});
}

class FirestoreDatabase implements Database {
  final String uid;

  FirestoreDatabase({@required this.uid}) : assert(uid != null);

  final _service = FirestoreService.instance;

  @override
  Future<void> setJob(Job job) => _service.setData(
        path: APIPath.job(uid: uid, jobId: job.id),
        data: job.toMap(),
      );

  @override
  Future<void> deleteJob(Job job) async {
    final allEntries = await entriesStream(job: job).first;
    for (final entry in allEntries) {
      if (entry.jobId == job.id) {
        await deleteEntry(entry);
      }
    }
    return _service.deleteData(
      path: APIPath.job(uid: uid, jobId: job.id),
    );
  }

  @override
  Stream<Job> jobStream(String jobId) => _service.documentStream(
        path: APIPath.job(uid: uid, jobId: jobId),
        builder: (data) => Job.fromMap(data),
      );

  @override
  Stream<List<Job>> jobsStream() => _service.collectionStream(
        path: APIPath.jobs(uid: uid),
        builder: (data) => Job.fromMap(data),
      );

  @override
  Future<void> setEntry(Entry entry) => _service.setData(
        path: APIPath.entry(uid, entry.id),
        data: entry.toMap(),
      );

  @override
  Future<void> deleteEntry(Entry entry) => _service.deleteData(
        path: APIPath.entry(uid, entry.id),
      );

  @override
  Stream<List<Entry>> entriesStream({Job job}) =>
      _service.collectionStream<Entry>(
        path: APIPath.entries(uid),
        queryBuilder: job != null
            ? (query) => query.where('jobId', isEqualTo: job.id)
            : null,
        builder: (data) => Entry.fromMap(data),
        sort: (lhs, rhs) => rhs.start.compareTo(lhs.start),
      );
}
