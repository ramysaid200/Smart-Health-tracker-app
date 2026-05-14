import 'dart:io';

void main() {
  print("Hello World");
  printDeviceInfo();
}

void printDeviceInfo() {
  print("Operating System: ${Platform.operatingSystem}");
  print("Operating System Version: ${Platform.operatingSystemVersion}");
  print("Number of Processors: ${Platform.numberOfProcessors}");
  print("Local Hostname: ${Platform.localHostname}");
  print("Path Separator: ${Platform.pathSeparator}");
  print("Line Terminator: ${Platform.lineTerminator}");
}
