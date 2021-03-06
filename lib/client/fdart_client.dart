library fdart_client;
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import '../common/block.dart' ;
export  '../common/block.dart';
part 'cblock.dart';


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
    var msg=JSON.encoder.convert({'operation': operation, 'block':block, 'data': data});
    this.ws.send(msg);
  }

  addBlock(CBlock bl) {
    bl.FORM=this;
    this.BLOCKS[bl.NAME]=bl;
  }
  Future<bool> init() {
    Completer<bool> c=new  Completer<bool>();
    ws = new WebSocket("ws://$IP:$PORT/ws");
    ws.onOpen.listen((a) {
      print("open ${a}");
      IS_CONNECTED = true;
      this.loadBlock();
      c.complete(true);
    });

    ws.onClose.listen((a) {
      print("close $a");
      IS_CONNECTED=false;
      ws=null;
    });

    ws.onMessage.listen(( m) {
      print ("Message on web socket.");
      try {
        Map jdata = JSON.decoder.convert(m.data);
        var response=jdata['response'];
        var block_name=jdata['block'];
        var resp_data=jdata['data'];
        CBlock bl=this.BLOCKS[block_name];
        switch (response){
          case Response.ERROR:
            print(resp_data);
            break;
          case Response.DECLARE:
            print ("Block ${block_name} registered on client and sever side");
            break;
          case Response.DATA:
          case Response.APPEND:
            print("Insert ${resp_data['json']} data in block ${block_name}");
            bl.BUSY--;
            List<List<dynamic>> d=JSON.decoder.convert(resp_data['json']);
            bl.appendData(d);
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
  DivElement makeDiv(String name) {

    return new DivElement()..attributes['type']="block"
                           ..attributes['name']=name;
  }

  void loadBlock() {
    print ("Loading Blocks");
    querySelectorAll("block").forEach(  (Element block) {
      var bl_name=block.attributes['name'];
      print ("Found block $bl_name");
      CBlock bl;
      if (this.BLOCKS.containsKey(bl_name)) {
        print ("Block $bl_name defined in Dart.");
        bl= this.BLOCKS[bl_name];
      }
      else
      {
        print("Block not defined in dart. Using HTML definition.");
        bl=new CBlock();
        bl.NAME=bl_name;
        this.BLOCKS[bl_name]= bl;
        bl.element.queryAll("column").forEach((Element col) {
            bl.ADD_COLUMN(new Column(col.attributes['name']));
          }
        );

      }
      bl.FORM=this;
      bl.element=block;

      bl.toHTMLTable();
      print("Declare block on server...");

      this.send( Operation.DECLARE,
                 block.attributes['name'],
                 bl.toJson()
                 );

      bl.CHILDS.forEach(( Relation r) {
        CBlock child=r.CHILD;
        child.FORM=this;
        child.element=makeDiv(child.NAME);
        child.toHTMLTable();
        this.BLOCKS[child.NAME]= child;
        bl.element.insertAdjacentElement("beforeend", child.element);
        this.send( Operation.DECLARE,
            child.NAME,
            child.toJson()
        );
      });

    });
  }

  void GO_BLOCK(String bl) {
    if (CURRENT_BLOCK != null) {
      CURRENT_BLOCK.EXIT_BLOCK();
    }
    CURRENT_BLOCK=BLOCKS[bl];
    CURRENT_BLOCK.ENTER_BLOCK();
  }

  void EXECUTE_QUERY(String where_clauses) {
    CURRENT_BLOCK.EXECUTE_QUERY(where_clauses);
  }


}