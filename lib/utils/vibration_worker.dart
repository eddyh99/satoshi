import 'dart:developer';

import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    log("worker : $task");
    Vibration.vibrate(
      pattern: [500, 1000, 2000, 3000, 4000, 5000],
    );
    return Future.value(true);
  });
}
