// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library('client');

#import('dart:html');
#import('dart:json');

final IP = '127.0.0.1';
final PORT = 8085;

WebSocket WS;
bool IS_CONNECTED;
main() {
  print("In Dart");
  setupWebsocket();
 
}

void setupTable(Element div) {
  div.on.scroll.add((e) {
     
      var m=JSON.stringify({'operation':'fetch', 'block':div.attributes['id'],'number':1});
      print(m);
      WS.send(m);
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
void setupWebsocket() {
  WS = new WebSocket("ws://$IP:$PORT/ws");
  WS.on.open.add((a) {
    print("open $a");
    IS_CONNECTED = true;
    queryAll(".block").forEach((Element block) {
      print("Block : ${block.attributes['name']}");
      var m=JSON.stringify({'operation':'get', 'block':block.attributes['name']});
      WS.send(m);
    });
  });
  
  WS.on.close.add((c) {
    print("close $c");
    IS_CONNECTED = false;
  });
  
  WS.on.message.add((m) {
    print( m.data);
    var jdata = JSON.parse(m.data);
    switch (jdata['operation']){
      case 'display':
        var e=query('#DEBUG');
        e.innerHTML=jdata['content'];
        var div=e.nodes[0];
        setupTable(div);
        break;
      case 'append':
        Element t=query("#${jdata['table']}");
        t.insertAdjacentHTML('beforeend', jdata['content']);
      default:
        print (jdata); 
    };    
    
  });
}