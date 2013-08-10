/*
 * Copyright (c) 2013, DB.
 */

import 'dart:io';
import 'dart:json';

final HOST = '127.0.0.1'; // eg: localhost 
final PORT = 4040;        // a port, must match the client program

void main() {
  HttpServer.bind(HOST, PORT).then(gotMessage, onError: printError);
}

void gotMessage(_server) {
  _server.listen((HttpRequest request) {
    switch (request.method) {
      case 'GET': 
        handleGet(request);
        break;
      case 'POST': 
        handlePost(request);
        break;
      case 'OPTIONS': 
        handleOptions(request);
        break;
      default: defaultHandler(request);
    }
  },
  onError: printError); // .listen failed
  print('Listening for GET and POST on http://$HOST:$PORT');
}

/**
 * Handle POST requests
 * Return the same set of data back to the client.
 */
void handlePost(HttpRequest req) {
  HttpResponse res = req.response;
  print('${req.method}: ${req.uri.path}');
  
  addCorsHeaders(res);
  
  req.listen((List<int> buffer) {
    // return the data back to the client
    res.write('Thanks for the data. This is what I heard you say: ');
    res.write(new String.fromCharCodes(buffer));
    res.close();
  },
  onError: printError);
}

/**
 * Add Cross-site headers to enable accessing this server from pages
 * not served by this server
 * 
 * See: http://www.html5rocks.com/en/tutorials/cors/ 
 * and http://enable-cors.org/server.html
 */
void addCorsHeaders(HttpResponse res) {
  res.headers.add('Access-Control-Allow-Origin', '*, ');
  res.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
}

void handleOptions(HttpRequest req) {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  print('${req.method}: ${req.uri.path}');
  res.statusCode = HttpStatus.NO_CONTENT;
  res.close();
}

void defaultHandler(HttpRequest req) {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  res.statusCode = HttpStatus.NOT_FOUND;
  res.write('Not found: ${req.method}, ${req.uri.path}');
  res.close();
}

void printError(error) => print(error);

/**
 * Handle GET requests 
 */
void handleGet(HttpRequest req) {
  HttpResponse res = req.response;
  print('${req.method}: ${req.uri.path}');
  String path = req.uri.path;
  
  addCorsHeaders(res);
  
  res.headers.add(HttpHeaders.CONTENT_TYPE, 'application/json');
  if ("/releases".matchAsPrefix(path) != null) {
    handleGetReleases(req, res);
  } else if ("/devjiras".matchAsPrefix(path) != null) {
    handleGetDevJIRAs(req, res);
  } else if ("/depjiras".matchAsPrefix(path) != null) {
    handleGetDepJIRAs(req, res);
  } else {
    res.write('unsupported request');
  }
  res.close();
}

var info = 
  { 
    'releases': [
      {
        'name' : 'R23',
        'depjiras': [
          {'name': 'JIRA123', 
            'releasenotes' : 'YAML file content', 
            'devjiras': [
              {
                'name': 'JIRA2345',
                'branches': [
                  { 'name': 'branch123', 'author': 'Vasily Pupkin' },
                  { 'name': 'branch124', 'author': 'Ioann Pupanov' }
                ]
              },
              {
                'name': 'JIRA2346',
                'branches': [
                  {'name': 'branch124', 'author': 'Ioann Pupanov'},
                  {'name': 'branch125', 'author': 'Seva Novgorodtsev'}
                ]
              }
            ]
          },
          {'name': 'JIRA133', 
            'releasenotes' : 'YAML file content', 
            'devjiras': [
              {
                'name': 'JIRA2347',
                'branches': [
                  { 'name': 'branch123', 'author': 'Vasily Pupkin' },
                  { 'name': 'branch124', 'author': 'Ioann Pupanov' }
                ]
              },
              {
                'name': 'JIRA2348',
                'branches': [
                  {'name': 'branch124', 'author': 'Ioann Pupanov'},
                  {'name': 'branch125', 'author': 'Seva Novgorodtsev'}
                ]
              }
            ]
          }
         ]
        },
       {
         'name': 'R24',
         'depjiras': [
            {'name': 'JIRA123', 
              'releasenotes' : 'YAML file content', 
              'devjiras': [
                {'name': 'JIRA2345',
                  'branches': [
                    { 'name': 'branch123', 'author': 'Vasily Pupkin' },
                    { 'name': 'branch124', 'author': 'Ioann Pupanov' }
                  ]
                },
                {'name': 'JIRA2346',
                  'branches': [
                    {'name': 'branch124', 'author': 'Ioann Pupanov'},
                    {'name': 'branch125', 'author': 'Seva Novgorodtsev'}
                  ]
                }
              ]
            }
          ]
        }
    ]
  };
void handleGetReleases(HttpRequest req, HttpResponse res) {
  // TODO: retrieve list from JIRA
  String path = req.uri.path;
  //
  // "/releases" -> list of releases
  //
  if (path == "/releases") {
    res.write(stringify(info));
  } else {
    //
    // "/releases/R23" -> release details 
    //
    var re = new RegExp(r'/releases/(.+)$'); 
    Match m = re.firstMatch(path);
    if (m != null) {
      print("looking for release ${m.group(0)}");
      res.write(stringify(info["releases"][m.group(1)]));
    } else {
      res.write(stringify({'error': 'invalid release request'}));
    }
  }
}

void handleGetDevJIRAs(HttpRequest req, HttpResponse res) {
  // retrieve list from 
}