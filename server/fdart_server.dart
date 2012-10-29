// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library fdart_server;
import "dart:io";
import "dart:json";
import "../common/block.dart";
part "sblock.dart" ;

final HOST = "127.0.0.1";
final PORT = 8085;
final LOG_REQUESTS = true;

class DartServer implements HttpServer {
  Map _blocks;
  dynamic COLLECTIONS;
  HttpServer http_server;
  void set defaultRequestHandler( void f(HttpRequest req, HttpResponse resp) ) {}
  int port;
  void set sessionTimeout(t) { }
  void set onError(dynamic err) {}
  void listen(String str, int t , [int backlog]) {}
  void listenOn(ServerSocket sock) {}
  dynamic  addRequestHandler(bool handler(HttpRequest) ,  void act (HttpRequest, HttpResponse) )
  {}
  void close() {}
  //* Serve a given file in response */
  Future<bool> _serveFile(String path,HttpResponse response) {
    Completer<bool> c= new  Completer<bool>();
    print ("serving ${path}");
    File f=new File("./${path}");
    print("File : ${f}");
    f.exists().then( (bool status)  {
      if (status) {
        if (path.endsWith(".dart")) {
          response.headers.set(HttpHeaders.CONTENT_TYPE,"application/dart");
        } else if (path.endsWith(".js")) {
          response.headers.set(HttpHeaders.CONTENT_TYPE,"application/javascript");
        }else if (path.endsWith(".html")) {
          response.headers.set(HttpHeaders.CONTENT_TYPE,"text/html");
        }
        f.readAsText().then( (String res) {
          response.outputStream.writeString(res);
          c.complete(true);
        } );
      } else {
        print ('Error $path not found.');
        response.headers.set(HttpHeaders.CONTENT_TYPE,"text/html");
        response.outputStream.writeString("<p>Error : ${path} not found</p>");
        c.complete(false);
      }
    });
    return c.future;
    

  }

  void respond(WebSocketConnection conn,String operation,String response,String block,var data)
  {
    var resp={ 'operation': operation, 'response': response, 'block': block, 'data':data};
    conn.send(JSON.stringify(resp));
  }

  DartServer()
  {
    this.http_server=new HttpServer();
    this._blocks=new Map ();


    WebSocketHandler wsHandler = new WebSocketHandler();
    this.http_server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);


    this.http_server.addRequestHandler((req) => req.path != "/ws", requestReceivedHandler);

    wsHandler.onOpen = (WebSocketConnection conn) {
      print('new connection');

      conn.onMessage = (message) {
        print("message is $message");
        String response;
        Map resp_data;
        String block_name;
        String operation;
        try {
          var jdata=JSON.parse(message);
          operation = jdata['operation'].toUpperCase();
          block_name  = jdata['block'].toUpperCase() ;
          var op_data= jdata['data'] ;

          switch (operation) {
            case Operation.EXECUTE_QUERY:
              SBlock bl=this._blocks[block_name];
              bl.EXECUTE_QUERY(op_data["where"]);
              bl.FETCH(100);
              response=Response.DATA;
              resp_data={ 'json': JSON.stringify( bl.ROWS) };
              //resp_data={ 'html': bl.toHTMLTable().toString()};
              break;
            case Operation.FETCH:
              SBlock bl=this._blocks[block_name];
              bl.FETCH(op_data['number']);
              response=Response.APPEND;
              resp_data={ 'json': JSON.stringify( bl.ROWS) };
              //resp_data={ 'html': bl.toHTMLTable().toString()};
              break;
            case Operation.DECLARE:
              print ("Create block : ${block_name}");
              SBlock bl=new SBlock.fromTable(block_name,jdata['query']);
              bl.database=this.COLLECTIONS[block_name];
              this._blocks[block_name]=bl;
              response=Response.DECLARE;
              resp_data={ 'status': Status.OK };
              break;
            case Operation.UPDATE:
              SBlock bl=this._blocks[block_name];
              Map<String,List<dynamic>> data=bl.database;
              List<dynamic> new_data=op_data["json"];
              data[new_data[0]]= new_data;
              resp_data={ 'status': Status.OK };
              break;
            case Operation.LOCK:
              SBlock bl=this._blocks[block_name];
              response=Response.LOCKED;
              // TODO LOCK ROWS
              resp_data={ 'row_number': op_data['row_number'], 'status': Status.OK };
              break;
            default:
              response=Response.ERROR;
              // TODO LOCK ROWS
              resp_data={ 'cause': "Unknown operation: $operation", 'status': Status.ERROR };
          };
        } catch (e) {
          print(e);
          response=Response.ERROR;
          block_name="";
          operation="";
          // TODO LOCK ROWS
          resp_data={ 'cause': "Unknown error: $e", 'status': Status.ERROR };
        }
        respond(conn,operation,response,block_name,resp_data)  ;

      };

      conn.onClosed = (int status, String reason) {
        print('closed with $status for $reason');
      };


    };

  }
  ADD_BLOCK(SBlock b) {
    this._blocks[b.NAME]=b;
  }



  void requestReceivedHandler(HttpRequest request, HttpResponse response) {
    if (LOG_REQUESTS) {
      print("Request: ${request.method} ${request.uri}");
    }
    if (request.path!='/favicon.ico') {
     _serveFile(request.path,response).onComplete( (status) {response.outputStream.close();});
    }
    else {
      response.outputStream.close();
    }
    /*
    if (request.path.startsWith('/static')) {
      _serveFile(request.path,response);
    } else {

      String htmlResponse = createHtmlResponse();

      response.headers.set(HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
      response.outputStream.writeString(htmlResponse);
      response.outputStream.close();
    }*/
  }

}


