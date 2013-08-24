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
  String url;

  Release(this.name, this.implementationPlan, this.eraPlan, _deploymentJIRAs) {
    deploymentJIRAs = toObservable(_deploymentJIRAs);
  }
  
  factory Release.fromJsonMap(Map mapJson) {
    return new Release(
        mapJson["name"],
        mapJson["implementationPlan"],
        mapJson["eraPlan"],
        mapJson["depJIRAs"]);
  }

  String toString() => "$name ${done ? '(done)' : '(not done)'}";
}

@observable
class DevelopmentJIRA {
  String name;
  List<Branch> branches;
  
  DevelopmentJIRA(this.name, this.branches);
  
  factory DevelopmentJIRA.fromJsonMap(Map mapJson) {
    return new DevelopmentJIRA(mapJson["name"], mapJson["branches"]);
  }
}

@observable
class DeploymentJIRA {
  String name;
  var releaseNotes;
  List<DevelopmentJIRA> developmentJIRAs;
  
  DeploymentJIRA(this.name, this.releaseNotes, _developmentJIRAs) {
    developmentJIRAs = toObservable(_developmentJIRAs);
  }
  
  factory DeploymentJIRA.fromJsonMap(Map mapJson) {
    return new DeploymentJIRA(
        mapJson["name"],
        mapJson["releaseNotes"],
        mapJson["devJIRAs"]);
  }

  bool loadReleaseNotes(String filenameYAML) {
    releaseNotes = loadYaml(filenameYAML);
  }
}

@observable
class Branch {
  String author;
  String name;
  Branch(this.author, this.name);
  
  factory Branch.fromJsonMap(Map mapJson) {
    return new Branch(mapJson["author"], mapJson["name"]);
  }
}

@observable
class ReleaseHolder implements Comparable<ReleaseHolder> {
  String description;
  String url;
  Release release;

  ReleaseHolder(this.description, this.url);
  
  factory ReleaseHolder.fromJsonMap(Map mapJson) {
    return new ReleaseHolder(
        mapJson["description"],
        mapJson["url"]);
  }
  
  int compareTo(ReleaseHolder other) {
    return description.compareTo(other.description);
  }

  String toString() => "$description $url";
}

