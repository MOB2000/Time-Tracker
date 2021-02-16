import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';

import '../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../services/database.dart';
import '../models/job.dart';

class EditJobPage extends StatefulWidget {
  final Database database;
  final Job job;

  const EditJobPage({
    Key key,
    @required this.database,
    this.job,
  }) : super(key: key);

  @override
  _EditJobPageState createState() => _EditJobPageState();

  static Future<void> show(
    BuildContext context, {
    Database database,
    Job job,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => EditJobPage(
          database: database,
          job: job,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();
  String _name;

  int _ratePerHour;

  @override
  void initState() {
    super.initState();
    _name = widget.job?.name;
    _ratePerHour = widget.job?.ratePerHour;
  }

  Future<void> _createJob() async {
    try {
      final jobs = await widget.database.jobsStream().first;
      final allJobsNames = jobs.map((job) => job.name);
      if (widget.job == null && allJobsNames.contains(_name)) {
        await showAlertDialog(
          context,
          title: 'Name already used',
          content: 'Please choose another job name',
          defaultActionText: 'OK',
        );
      } else {
        await widget.database.setJob(
          Job(
            id: widget.job?.id ?? DateTime.now().toIso8601String(),
            name: _name,
            ratePerHour: _ratePerHour,
          ),
        );
      }
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operation Failed',
        exception: e,
      );
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      await _createJob();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.job == null ? 'Add Job' : 'Edit Job'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _name,
                      validator: (value) =>
                          value.isEmpty ? 'Email can not be empty' : null,
                      onSaved: (value) => _name = value,
                      decoration: InputDecoration(
                        labelText: 'Job name',
                      ),
                    ),
                    TextFormField(
                      initialValue: _ratePerHour?.toString(),
                      validator: (value) =>
                          value.isEmpty ? 'rate can not be empty' : null,
                      onSaved: (value) =>
                          _ratePerHour = int.tryParse(value) ?? 0,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Rate per hour',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
