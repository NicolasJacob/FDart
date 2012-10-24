import "common/block.dart";
import "server/fdart_server.dart";
import "dart:io";

void main() {


  var CUSTOMER=[ [1, "Jack","Palmer", "12 rue Mozart"],
              [2, "Joe","Palmer", "13 rue Mozart"],
              ];

  var PURSHASE= [ [ 1,1, "12/12/13", 134],
                  [ 2,2, "12/12/12", 136]];
  
  var database={ 'CUSTOMER': CUSTOMER, 'PURSHASE':PURSHASE };
  
  DartServer server = new DartServer();
  server.COLLECTIONS=database;

  server.http_server.listen(HOST, PORT);

  print("Serving the current time on http://${HOST}:${PORT}.");
}
