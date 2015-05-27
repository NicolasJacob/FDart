

library fdart_server;
import 'file.dart';
import "dart:io";
import "dart:async";
import "dart:convert";
import '../lib/common/block.dart';
import 'package:route/server.dart';
part "sblock.dart" ;

final HOST = "127.0.0.1";
final PORT = 8085;
final LOG_REQUESTS = true;

class DartServer {
  Map _blocks;
  dynamic COLLECTIONS;
  HttpServer http_server;
  void listen(  int port) {

      HttpServer.bind(InternetAddress.ANY_IP_V6, PORT).then((server) {
         var router = new Router(server);
         var allUrls = new RegExp('/(.*)');
         router.serve(r'/ws')
           .transform(new WebSocketTransformer())
             .listen(webSocketHandler);
         router.serve(allUrls).listen(serveDirectory('', as: '/'));
         router.serve(r'/status').listen(_serveStatus);
       }
      , onError: (err) { print ("Error: $err");} );



  }
  //* Serve a given file in response */
  void _serveFile( HttpRequest req) {

    var path=req.uri.path;
    print ("serving ${path}");
    File f=new File("./${path}");
    print("File : ${f}");
    f.exists().then( (bool status)  {
      if (status) {
        if (path.endsWith(".dart")) {
          req.response.headers.set(HttpHeaders.CONTENT_TYPE,"application/dart");
        } else if (path.endsWith(".js")) {
          req.response.headers.set(HttpHeaders.CONTENT_TYPE,"application/javascript");
        }else if (path.endsWith(".html")) {
          req.response.headers.set(HttpHeaders.CONTENT_TYPE,"text/html");
        }
        f.readAsString().then( (String res) {
          req.response.write(res);

        } );
      } else {
        print ('Error $path not found.');
        req.response.headers.set(HttpHeaders.CONTENT_TYPE,"text/html");
        req.response.write("<p>Error : ${path} not found</p>");

      }
      req.response.close();
    });



  }
  void _serveStatus(HttpRequest req){
    req.response.headers.set(HttpHeaders.CONTENT_TYPE,"text/html");
    req.response.write("<p>It works !</p>");
    req.response.close();

  }

  void webSocketHandler ( WebSocket conn) {

      print('new connection');

      conn.listen( (message)  {
        print("message is $message");
        String response;
        Map resp_data;
        String block_name;
        String operation;
        try {
          var jdata=JSON.decoder.convert(message);
          operation = jdata['operation'].toUpperCase();
          block_name  = jdata['block'].toUpperCase() ;
          var op_data= jdata['data'] ;

          switch (operation) {
            case Operation.EXECUTE_QUERY:
              SBlock bl=this._blocks[block_name];
              bl.EXECUTE_QUERY(op_data["where"]);
              bl.FETCH(100);
              response=Response.DATA;
              resp_data={ 'json': JSON.encoder.convert( bl.ROWS) };
              //resp_data={ 'html': bl.toHTMLTable().toString()};
              break;
            case Operation.FETCH:
              SBlock bl=this._blocks[block_name];
              bl.FETCH(op_data['number']);
              response=Response.APPEND;
              resp_data={ 'json': JSON.encoder.convert( bl.ROWS) };
              //resp_data={ 'html': bl.toHTMLTable().toString()};
              break;
            case Operation.DECLARE:
              print ("Create block : ${block_name}");
              SBlock bl=new SBlock.fromTable(block_name,jdata['query']);
              bl.data=this.COLLECTIONS[block_name]['data'];
              this.COLLECTIONS[block_name]['definition'].forEach((String col) {
                bl.ADD_COLUMN(new Column(col));
              });
              this._blocks[block_name]=bl;
              response=Response.DECLARE;
              resp_data={ 'status': Status.OK };
              break;
            case Operation.UPDATE:
              SBlock bl=this._blocks[block_name];
              Map<String,List<dynamic>> data=bl.data;
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


      }, onError: (err) {print (err);}, onDone: ()=>{} /*, cancelOnError:()=>{}*/ );
  }
  void set defaultRequestHandler( void f(HttpRequest req, HttpResponse resp) ) {}
  int port;




  void respond(WebSocket conn,String operation,String response,String block,var data)
  {
    var resp={ 'operation': operation, 'response': response, 'block': block, 'data':data};
    conn.add(JSON.encoder.convert(resp));
  }

  DartServer()
  {

    this._blocks=new Map ();



  }
  ADD_BLOCK(SBlock b) {
    this._blocks[b.NAME]=b;
  }

}


