#import ("block.dart");
#import ("fdart_server.dart");
#import("dart:io");

void main() {
  
  
  DartServer server = new DartServer();
  Block b=new Block.fromTable("MODELS","MODELS");
  b.COLUMNS['NAME']=new Column("NAME","TEXT","TEXT");
  b.COLUMNS['DESCRIPTION']=new Column("DESCRIPTION","TEXT","TEXT");
  server.ADD_BLOCK(b);
  
  
  server.http_server.listen(HOST, PORT);
  

  
  
  print("Serving the current time on http://${HOST}:${PORT}."); 
}
