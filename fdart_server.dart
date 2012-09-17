// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library("fdart_server");
#import("dart:io");
#import("dart:json");
#import("block.dart");



final HOST = "127.0.0.1";
final PORT = 8085;



final LOG_REQUESTS = true;

class DartServer implements HttpServer {
  Map _blocks;
  HttpServer http_server;
  
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
  
  DartServer() {
    this.http_server=new HttpServer();
    this._blocks=new Map ();
 
    
    WebSocketHandler wsHandler = new WebSocketHandler();
    this.http_server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
    
    
    this.http_server.addRequestHandler((req) => req.path != "/ws", requestReceivedHandler);
      
    wsHandler.onOpen = (WebSocketConnection conn) {
      print('new connection');
      
      conn.onMessage = (message) {
        print("message is $message");
        StringBuffer content=new StringBuffer();
        var jdata=JSON.parse(message);
        var response;
        switch (jdata['operation']) {
          case 'EXECUTE_QUERY':
           
            Block bl=this._blocks[jdata['block']];
            content.add(
"""<div id="${bl.NAME}"  style="overflow:auto; width:400px; height:300px;border-style:solid; border-width:1px; ">"""
            );
            content.add(
"""  <table class="deftable"  >
       <thead>
"""
            );
            bl.EXECUTE_QUERY();
            bl.FETCH(100);
            content.add("<tr>");
            bl.COLUMNS.forEach( (key,val) {
              content.add("<td>${key}</td>");
            });
            content.add("</tr></thead>");

            content.add("""<tbody id="${bl.NAME}_DATA" >""");
            var i =0;
            bl.ROWS.forEach( (List<String> r) {
              i++;
              content.add("""<tr id=${i}">""");
              r.forEach( (col) {
                content.add("<td>${col}</td>") ;
              });
              content.add("</tr>");
            });
            content.add("""</tbody></table></div>""");
            response={'operation':'display', 'content':'${content.toString()}'};
            break;
          case 'fetch':
            
            Block bl=this._blocks[jdata['block']];
            bl.FETCH(jdata['number']);
            content.add("""<tr id=${bl.ROWS.length}">""");
            bl.ROWS.forEach( (row) {
              row.forEach( (col) {
                content.add("<td>${col}</td>") ;
              });
              content.add("</tr>");
            });
            
            response={'operation':'append', 'table': "${bl.NAME}_DATA",  'content':'${content.toString()}'};
            break;
          case 'declare':
            print ("Create block : ${jdata['block']}");
            SBlock bl=new SBlock.fromTable(jdata['block'],jdata['query']);
            this._blocks[jdata['block']]=bl;
            response={'operation':'declare', 'block': bl.NAME ,  'status':'ok'};
            
            break;
        };
        
        conn.send(JSON.stringify(response));
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


