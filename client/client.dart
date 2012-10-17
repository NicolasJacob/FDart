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
  Map<String,Block> BLOCKS=new Map<String,Block> ();
  final String NAME;
  Block CURRENT_BLOCK;
  WebSocket ws ;
  bool IS_CONNECTED;
  // Constructor
  CForm(this.NAME) ;
  
  void send(String operation,String block,var data) {
    var msg=JSON.stringify({'operation': operation, 'block':block, 'data': data});
    this.ws.send(msg);
  }
  
  addBlock(CBlock bl) {
    bl.FORM=this;
    this.BLOCKS[bl.NAME]=bl;
  }
  Future<bool> init() {
    Completer<bool> c=new  Completer<bool>();
    ws = new WebSocket("ws://$IP:$PORT/ws");
    ws.on.open.add((a) {
      print("open ${a}");
      IS_CONNECTED = true;
      this.loadBlock();
      c.complete(true);
    });
    
    ws.on.close.add((a) {
      print("close $a");
      IS_CONNECTED=false;
      ws=null;
    });
    
    ws.on.message.add((m) {
      print ("Message on web socket: ${m.data}");
      try {
        Map jdata = JSON.parse(m.data);  
        var response=jdata['response'];
        var block_name=jdata['block'];
        var resp_data=jdata['data'];
        CBlock bl=this.BLOCKS[block_name];
        switch (response){
          case Response.DECLARE:
            print ("Block ${block_name} registered on client and sever side");
            
            break;      
          case Response.DATA:
          case Response.APPEND:  
            print("Insert data in block block_name");   
            bl.BUSY--;
            bl.getDataElement().insertAdjacentHTML('beforeend', resp_data['html']);
            bl.setupTable();
            break;
          default:
            print ("Error: unknown response : $response"); 
            break;
        }  
      } catch (e) {
        print ("Error: $e");
      }
      
      
    });
    return c.future;
  }
  
  void loadBlock() {
    print ("Loading Blocks");
    queryAll("block").forEach(  (Element block) {
      var bl_name=block.attributes['name'];
      print ("Found block $bl_name");
      CBlock bl;
      if (this.BLOCKS.containsKey(bl_name)) {
        print ("Block $bl_name denined in Dart.s");
        bl= this.BLOCKS[bl_name];  
      }
      else
      {
        print("Error: block not defined. Using default config");
        bl=new CBlock();
        bl.NAME=bl_name;
        this.BLOCKS[bl_name]= bl;
      
      }
      bl.FORM=this;
      bl.element=block;
      bl.element.queryAll("column").forEach((Element col) {
          bl.COLUMNS[col.attributes['name']]=new Column(col.attributes['name'],"" ,"");
        }
      );
    
      
      bl.toHTMLTable();
      print("Declare block on server...");
      this.send( Operation.DECLARE,block.attributes['name'],{'query':block.attributes['name']} );

    });
  }
  
  void GO_BLOCK(String bl) {
    if (CURRENT_BLOCK != null) {
      CURRENT_BLOCK.EXIT_BLOCK();
    }
    CURRENT_BLOCK=BLOCKS[bl];
    CURRENT_BLOCK.ENTER_BLOCK();
  }
  
  void EXECUTE_QUERY() {
    CURRENT_BLOCK.EXECUTE_QUERY();
  }
  
  
}