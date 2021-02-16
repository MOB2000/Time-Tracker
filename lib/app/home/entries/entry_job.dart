import 'package:time_tracker/app/home/models/entry.dart';
import 'package:time_tracker/app/home/models/job.dart';

class EntryJob {
  final Entry entry;
  final Job job;

  EntryJob(
    this.entry,
    this.job,
  );
}
