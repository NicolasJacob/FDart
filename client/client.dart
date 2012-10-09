// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library('fdart_client');
#import('dart:html');
#import('dart:json');
#import('../common/block.dart');

#source("cblock.dart");

final IP = '127.0.0.1';
final PORT = 8085;

WebSocket ws;
String CURRENT_BLOCK;
bool IS_CONNECTED;



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
      this.loadBlock();
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
          case 'DECLARE':
            //this.BLOCKS[jdata['block']]=new CBlock.fromJSON(this,jdata);
            print ("Block ${jdata['block']} registered on client and sever side");
            c.complete(true);
            break;
            
          case 'DATA':
          case 'APPEND':
            
            String blname=jdata['block'];
            print("Insert data in block $blname");
            CBlock bl=this.BLOCKS[blname];
            bl.BUSY--;
            bl.getDataElement().insertAdjacentHTML('beforeend', jdata['data']);
            bl.setupTable();
            break;
          default:
            print (jdata); 
            break;
        }
      };    
      
    });
    return c.future;
  }
  void loadBlock() {
    
    queryAll("block").forEach(  (Element block) {
      var bl_name=block.attributes['name'];
      print("Declare Block : ${bl_name}");
      CBlock bl= new CBlock(bl_name,this);
      bl.element=block;
      bl.element.queryAll("column").forEach((Element col) {
          bl.COLUMNS.add(new Column(col.attributes['name'],"" ,""));
        }
      );
    
      this.BLOCKS[bl_name]= bl;
      bl.toHTMLTable();
      var m=JSON.stringify({
            'operation':'declare', 
            'block':block.attributes['name'],
            'query':block.attributes['name'] });
      this.ws.send(m);
    });
  }
  
  void GO_BLOCK(String bl) {
    if (CURRENT_BLOCK != null) {
      CURRENT_BLOCK.EXIT();
    }
    CURRENT_BLOCK=BLOCKS[bl];
    CURRENT_BLOCK.ENTER();
  }
  
  void EXECUTE_QUERY() {
    CURRENT_BLOCK.EXECUTE_QUERY();
  }
  
  
}