import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/home/job_entries/job_entries_page.dart';

import '../../../common_widgets/show_alert_dialog.dart';
import '../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../services/database.dart';
import '../models/job.dart';

class JobListTile extends StatelessWidget {
  final Job job;

  const JobListTile({
    Key key,
    @required this.job,
  }) : super(key: key);

  Future<void> _delete(BuildContext context) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteJob(job);
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operation failed',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('job-${job.id}'),
      confirmDismiss: (direction) async {
        return await showAlertDialog(
          context,
          title: 'Confirm Delete',
          content: 'Do you want to delete?',
          defaultActionText: 'Yes',
          cancelActionText: 'No',
        );
      },
      background: Container(
        child: Icon(Icons.delete_forever),
        color: Colors.red,
        padding: EdgeInsets.all(12),
        alignment: Alignment.centerRight,
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _delete(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(job.name),
          trailing: Text(job.ratePerHour.toString()),
          onTap: () => JobEntriesPage.show(context, job),
        ),
      ),
    );
  }
}
