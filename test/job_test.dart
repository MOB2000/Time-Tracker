import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/app/home/models/job.dart';

void main() {
  group('fromMap', () {
    test('null data', () {
      final job = Job.fromMap(null);
      expect(job, null);
    });

    test('job with all properties', () {
      final job = Job.fromMap({
        'id': 'abc',
        'name': 'Blogging',
        'ratePerHour': 10,
      });
      expect(job, Job(name: 'Blogging', ratePerHour: 10, id: 'abc'));
    });

    test('missing name', () {
      final job = Job.fromMap({
        'id': 'abc',
        'ratePerHour': 10,
      });
      expect(job, null);
    });
  });

  group('toMap', () {
    test('valid name, ratePerHour', () {
      final job = Job(id: '', name: 'Blogging', ratePerHour: 10);
      expect(job.toMap(), {
        'id': '',
        'name': 'Blogging',
        'ratePerHour': 10,
      });
    });
  });
}
