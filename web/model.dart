// Copyright (c) 2013, DB.

library model;

import 'package:web_ui/observe.dart';
import 'package:web_ui/observe/html.dart';
import 'package:yaml/yaml.dart';

@observable
class ViewModel {
  bool isVisible(Release release) => release != null &&
      ((showIncomplete && !release.done) || (showDone && release.done));

  bool get showIncomplete => locationHash != '#/completed';

  bool get showDone => locationHash != '#/active';
}

final ViewModel viewModel = new ViewModel();

// The real model:

@observable
class AppModel {
  final ObservableList<Release> releases = new ObservableList<Release>();

  bool get allChecked => releases.length > 0 && releases.every((t) => t.done);

  set allChecked(bool value) => releases.forEach((t) { t.done = value; });

  int get doneCount =>
      releases.fold(0, (count, t) => count + (t.done ? 1 : 0));

  int get remaining => releases.length - doneCount;

  void clearDone() => releases.removeWhere((t) => t.done);
}

final AppModel app = new AppModel();

@observable
class Release {
  bool done = false;
  String name;
  List<DeploymentJIRA> deploymentJIRAs;
  String implementationPlan;
  String eraPlan;

  Release(this.name) : deploymentJIRAs = toObservable([]);

  String toString() => "$name ${done ? '(done)' : '(not done)'}";
}

@observable
class DevelopmentJIRA {
  String name;
  List<Branch> branches;
}

@observable
class DeploymentJIRA {
  String name;
  var releaseNotes;
  List<DevelopmentJIRA> developmentJIRAs;
  
  DeploymentJIRA(this.name): developmentJIRAs = toObservable([]);
  
  bool loadReleaseNotes(String filenameYAML) {
    releaseNotes = loadYaml(filenameYAML);
  }
}

class Branch {
  String path;
}