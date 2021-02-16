import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_job_page.dart';
import './job_list_tile.dart';
import './list_items_builder.dart';
import '../../../services/database.dart';
import '../models/job.dart';

class JobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => EditJobPage.show(
              context,
              database: Provider.of<Database>(context),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Job>>(
        stream: database.jobsStream(),
        initialData: [],
        builder: (context, snapshot) {
          return ListItemsBuilder(
            snapshot: snapshot,
            itemBuilder: (context, job) => JobListTile(job: job),
          );
        },
      ),
    );
  }
}
