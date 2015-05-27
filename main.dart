import 'lib/common/block.dart';
import "server/fdart_server.dart";
import "dart:io";

void main() {


  var CUSTOMER={ "definition": ["id","FIRST_NAME","LAST_NAME","SEX","ADRESS"],
                 "data": {
                 "1": [ 1,"Jack","Palmer","Male", "12 rue Mozart"],
                 "2": [ 2,"Joe","Palmer","Male", "13 rue Mozart"],
                 "3": [ 3,"Jask","Palmer", "Male","12 rue Mozart"],
                 "4": [ 4,"Joes","Palmer", "Male","13 rue Mozart"],
                 "5": [ 5,"Jacdk","Palsmer", "Male","12 rue Mozart"],
                 "6": [ 6,"Joe","Palmer","Male", "13 rue Mozart"],
                 "7": [ 7,"Jack","Palsmer", "Male","12 rue Mozart"],
                 "8": [ 8,"Jose","Palmser", "Male","13 rue Mozart"],
                 "9": [ 9,"Jacdk","Palsmer", "Male","12 rue Mozart"],
                 "10": [ 10,"Joe","Palmer", "Male","13 rue Mozart"],
                 "11": [ 11,"Jack","Palsmer", "Male","12 rue Mozart"],
                 "12": [ 12,"Jose","Palmser", "Male","13 rue Mozart"],
                 }
  };

  var PURSHASE= {"definition": ["id","CUST_id","DATE","VALUE"],
                 
                 "data": {
                  "1" : [ 1,1, "12/12/13", 134],
                  "2" : [ 2,2, "12/12/12", 136]
                 }  
                };

  var database={ 'CUSTOMER': CUSTOMER, 'PURSHASE':PURSHASE };

  DartServer server = new DartServer();
  server.COLLECTIONS=database;

  server.listen(PORT);

  print("Serving the current time on http://${HOST}:${PORT}.");
}
