// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library("fdart_server");
#import("dart:io");
#import("dart:json");
#import("../common/block.dart");
#import("../server/sblock.dart");


final HOST = "127.0.0.1";
final PORT = 8085;



final LOG_REQUESTS = true;



class DartServer implements HttpServer {
  Map _blocks;
  HttpServer http_server;
  void set defaultRequestHandler( void f(HttpRequest req, HttpResponse resp) ) {}
  int port;
  void set onError(dynamic err) {}
  void listen(String str, int t , [int backlog]) {}
  void listenOn(ServerSocket sock) {}
  dynamic  addRequestHandler(bool handler(HttpRequest) ,  void act (HttpRequest, HttpResponse) ) 
  {}
  void close() {}
  //* Serve a given file in response */
  _serveFile(String path,HttpResponse response) {
    File f=new File("./${path}");
    if (path.endsWith(".dart")) {
      response.headers.set(HttpHeaders.CONTENT_TYPE,"application/dart");
    } else if (path.endsWith(".js")) {
      response.headers.set(HttpHeaders.CONTENT_TYPE,"application/javascript");
    }else if (path.endsWith(".html")) {
      response.headers.set(HttpHeaders.CONTENT_TYPE,"text/html");
    }
    response.outputStream.writeString(f.readAsTextSync());
    response.outputStream.close();
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
              bl.EXECUTE_QUERY();
              bl.FETCH(100);
              response=Response.DATA;
              resp_data={ 'html': bl.toHTMLTable().toString()};
              break;
            case Operation.FETCH:
              SBlock bl=this._blocks[block_name];
              bl.FETCH(op_data['number']);
              response=Response.APPEND;
              resp_data={ 'html': bl.toHTMLTable().toString()};  
              break;
            case Operation.DECLARE:
              print ("Create block : ${block_name}");
              SBlock bl=new SBlock.fromTable(block_name,jdata['query']);
              this._blocks[block_name]=bl;
              response=Response.DECLARE;
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
    _serveFile(request.path,response);
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

  
  
  String createHtmlResponse() {
    return 
  '''
  <html>
    <link rel="stylesheet" href="/static/css/t1.css">
    <style>
      body { background-color: teal; }
      p { background-color: white; border-radius: 8px; border:solid 1px #555; text-align: center; padding: 0.5em; 
          font-family: "Lucida Grande", Tahoma; font-size: 18px; color: #555; }
    </style>
    <body>
      <br/><br/>
      <p>Current time: ${new Date.now()}</p>
      <p>Blocks: ${this._blocks}</p>
      <div class="block" name="MODELS" ></div>
      <p id="DEBUG"></p>
      <script type="application/dart" src="static/client.dart"></script>
      <script src="static/js/dart.js"></script>
  </body>
  </html>
  ''';
  }
}


