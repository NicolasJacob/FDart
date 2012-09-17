// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library('client');

#import('dart:html');
#import('dart:json');
#import('../block.dart');

final IP = '127.0.0.1';
final PORT = 8085;

WebSocket ws;
String CURRENT_BLOCK;
bool IS_CONNECTED;


class CBlock implements Block  {
  String NAME;
  CForm _Form; 
  CBlock.fromJSON(this._Form,jdata) {
    this.NAME=jdata['block'];
  }
  
  void EXECUTE_QUERY() {
    var m=JSON.stringify({
      'operation':'EXECUTE_QUERY', 
      'block': this.NAME,
       });
    _Form.ws.send(m);
  }
  /*Trigger */
  void EXIT() {
    
  }
  void ENTER() {
    
  }
  
  num FETCH([int nb_ligne=10]) {
    var m=JSON.stringify({'operation':'fetch', 'block':NAME,'number':nb_ligne});
    print(m);
    ws.send(m);
  }
  
  get ROWS() {
    
  }
}

class CForm {
  Map<String,Block> BLOCKS;
  final String NAME;
  Block CURRENT_BLOCK;
  WebSocket ws ;
  bool IS_CONNECTED;
  // Constructor
  CForm(this.NAME) ;
  

  Future<bool> init() {
    BLOCKS=new Map<String,Block>();
    Completer<bool> c=new  Completer<bool>();
    ws = new WebSocket("ws://$IP:$PORT/ws");
    ws.on.open.add((a) {
      print("open ${a}");
      IS_CONNECTED = true;
      loadBlock(ws);
    });
    
    ws.on.close.add((a) {
      print("close $a");
      IS_CONNECTED=false;
      ws=null;
    });
    
    ws.on.message.add((m) {
      print ("Message on web socket: ${m.data}");
      Map jdata = JSON.parse(m.data);
      if (jdata.containsKey('operation')) {
        switch (jdata['operation']){
          case 'declare':
            this.BLOCKS[jdata['block']]=new CBlock.fromJSON(this,jdata);
            print ("Block ${jdata['block']} registered on client and sever side");
            c.complete(true);
            break;
          case 'display':
            var e=query('block');
            e.innerHTML=jdata['content'];
            var div=e.nodes[0];
            setupTable(ws,div);
            break;
          case 'append':
            Element t=query("#${jdata['table']}");
            //print (jdata['content']);
            t.insertAdjacentHTML('beforeend', jdata['content']);
            break;
          default:
            print (jdata); 
        }
      };    
      
    });
    return c.future;
  }
  void GO_BLOCK(String bl) {
    if (CURRENT_BLOCK != null) {CURRENT_BLOCK.EXIT();}
    CURRENT_BLOCK=BLOCKS[bl];
    CURRENT_BLOCK.ENTER();
  }
  
  void EXECUTE_QUERY() {
    CURRENT_BLOCK.EXECUTE_QUERY();
  }
}


void loadBlock(WebSocket ws) {
  
  queryAll("block").forEach((Element block) {
    print("Declare Block : ${block.attributes['name']}");
    
    var m=JSON.stringify({
        'operation':'declare', 
        'block':block.attributes['name'],
        'query':block.attributes['name'] });
    ws.send(m);
  });
}
  
void setupTable(WebSocket ws, Element div) {
  div.on.scroll.add((e) {
      var m=JSON.stringify({'operation':'fetch', 'block':div.attributes['id'],'number':1});
      print(m);
      ws.send(m);
    }
  );
  div.queryAll("tr").forEach( (Element el) {
    print ('add event to ${el}');
    el.on.click.add((evt) {
      print ( 'click ${el.attributes['id']}');
    }
    );
  }
  );
}

Future<WebSocket> setupWebsocket() {
 
  Completer<WebSocket> c=new  Completer<WebSocket>();
  print ("Creating Web Socket");
  ws = new WebSocket("ws://$IP:$PORT/ws");
  print ("Web Socket created.");
  ws.on.open.add((a) {
    print("open ${a}");
    IS_CONNECTED = true;
    c.complete(ws);
  });
  
  ws.on.close.add((c) {
    print("close $c");
    IS_CONNECTED = false;
  });
  
  ws.on.message.add((m) {
    print ("Message on web socket: ${m}");
    Map jdata = JSON.parse(m.data);
    if (jdata.containsKey('operation')) {
      switch (jdata['operation']){
        case 'declare':
          print ("Block registered on sever side");
          break;
        case 'display':
          var e=query('#DEBUG');
          e.innerHTML=jdata['content'];
          var div=e.nodes[0];
          setupTable(ws,div);
          break;
        case 'append':
          Element t=query("#${jdata['table']}");
          //print (jdata['content']);
          t.insertAdjacentHTML('beforeend', jdata['content']);
          break;
        default:
          print (jdata); 
      }
    };    
    
  });
  return c.future;
}

init() {
  Future<WebSocket> app;
  
  print("FDart initialization");
  app=setupWebsocket();
  app.then(
      (WebSocket WS) {
          loadBlock(WS);
       }
 );
  app.handleException( (var e) { print ("Error: ${e}" );});

}