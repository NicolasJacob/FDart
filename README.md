FDart: Dart for Forms Developper
================================

Coming from Oracle Forms and wanting to write RIA database applications ?
FDart is designed for you.
Checks the FDart features below to get conviced.

NOTE: FDart is under development and not ready yet. 

FDart Feature (for Forms User)
------------------------------
* Block / Column / Triggers are similar in FDart
* A single language for client / server side
* Most actions performed on client side
* Table, Query, and others (XML,HTTP) Block datasource available.
* A simple FDart forms: <HTML><FBLOCK table: "CUSTORMER" order_by: "NAME" num_rows: 10 ></FBLOCK><HTML>

Simple Sample:
--------------
This sample fully manage data of the MODEL table.
HTML:
``<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>FDart Sample</title>
  </head>
  <body>
    <p>Hello world from FDart!</p>   
    <block  name="MODEL" query="SELECT NAME FROM MODEL">      
    </bock>
    <script type="application/dart" src="test.dart"></script>
    <script src="http://dart.googlecode.com/svn/branches/bleeding_edge/dart/client/dart.js"></script>
  </body>
</html>``
Dart Code:
``#import("fdart_client.dart");
main() {
 CForm Form=new CForm("TEST");
 Form.init(<database connection>).then( ( bool status) {
     Form.GO_BLOCK("MODEL");
     Form.EXECUTE_QUERY();
 }
);``


