import 'dart:html';
import 'package:yaml/yaml.dart';

void main() {
//  releases = new List<Release>();
//  releases.add(new Release("R23.0"));
//  releases.add(new Release("R24.0"));
  
  query("#sample_text_id")
    ..text = "Click me!"
    ..onClick.listen(reverseText);
}

void reverseText(MouseEvent event) {
  var text = query("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  query("#sample_text_id").text = buffer.toString();
}
