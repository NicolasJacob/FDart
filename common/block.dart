library block;
import 'dart:json';

class WhereItem {
  String column;
  dynamic value;
}

class WhereList {
  String operator;
  List<WhereItem> items;
}

class WhereClause {
  WhereList where;
}

class Operation {

  static const String EXECUTE_QUERY='EXECUTE_QUERY';
  static const String FETCH='FETCH';
  static const String LOCK='LOCK';
  static const String DECLARE='DECLARE';
  static const String UPDATE='UPDATE';

}

class Response {

  static const String DATA='DATA';
  static const String DECLARE='DECLARE';
  static const String APPEND='APPEND';
  static const String LOCKED='LOCKED';
  static const String ERROR='ERROR';

}
class Status {

  static const String OK='OK';
  static const String ERROR='ERROR';
}
/**
 * Record class is used to remember current record
 */
class Record {
  int number;
  Record(this.number);
}

/**
 * Item class is used to remember current record
 */
class Item {
  int number;
  String value;
  Item(this.number);
}

class Column {
  final String NAME;
  String LABEL="";
  String DATA_TYPE="TEXT";
  String DISPLAY_TYPE="INPUT";
  bool PRIMARY_KEY=false;
  bool VISIBLE=true;
  String STYLE="";
  bool dirty=false;
  dynamic CURRENT_VALUE;
  dynamic header;
  
  Column(this.NAME);
  
  Map<String,String> toJson(){
    return { 'name':NAME,'type':DATA_TYPE};
  }
}

class Relation {
  final Block CHILD;
  final List<String> PARENT_KEYS;
  final String WHERE_CLAUSE;
  Relation(this.CHILD,this.PARENT_KEYS,this.WHERE_CLAUSE);
  Map<String,String> toJson(){
    return { 'block': JSON.stringify(CHILD),
             'parent_keys': JSON.stringify(PARENT_KEYS),
             'where': WHERE_CLAUSE};
  }
}

abstract class Block {
  String         NAME;
  List<Column>   COLUMNS=new List<Column>();
  List<Relation> CHILDS =new List<Relation> ();
  List<String>   FOREIGN_KEYS=new List();
  Record         CURRENT_RECORD = new Record(null);
  Item           CURRENT_ITEM = new Item(null);
  Map<String,int> rowMap=new  Map<String,int>();

  /* High level control directive */
  void EXECUTE_QUERY(String where_clause);

  void ADD_COLUMN(Column c)
  {
    this.COLUMNS.add(c);
    this.rowMap[c.NAME]=this.COLUMNS.length-1;
  }
  
  num FETCH([int nb_ligne=10]);
  
  get ROWS ;
  
  // Return current value for selected column
  dynamic getValue(colomn_name) ; 
  
  void CLEAR_BLOCK() ;
  
  void GO_RECORD(int number) ;
  
  Map<String,dynamic> toJson();
  
  /*Trigger */
  bool LOCK_RECORD();
  bool VALIDATE_ITEM(String row,String col,String value) {}
  bool VALIDATE_RECORD() {}
  bool NEW_RECORD_INSTANCE() {}
  bool PRE_QUERY() {}
  bool EXIT_BLOCK() {}
  bool ENTER_BLOCK() {}




}



