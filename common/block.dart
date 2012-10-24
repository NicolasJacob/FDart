library block;
import 'dart:json';

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
  String DATA_TYPE;
  String DISPLAY_TYPE;
  bool PRIMARY_KEY;
  bool VISIBLE;
  int WIDTH;
  bool dirty;
  Dynamic CURRENT_VALUE;
  Column(this.NAME);
  Map<String,String> toJson(){
    return { 'name':NAME,'type':DATA_TYPE};
  }
}

class Relation {
  Block CHILD;
  String JOIN_CLAUSE;
  Relation(this.CHILD,this.JOIN_CLAUSE);
  Map<String,String> toJson(){
    return { 'block': JSON.stringify(CHILD),'join':JOIN_CLAUSE};
  }
}

abstract class Block {
  String NAME;
  List<Column> COLUMNS=new List<Column>();
  List<Relation>  CHILDS =new List<Relation> ();
  Record  CURRENT_RECORD = new Record(null);
  Item    CURRENT_ITEM = new Item(null);

  /* High level control directive */
  void EXECUTE_QUERY(String where_clause);

  void ADD_COLUMN(Column c)
  {

    this.COLUMNS.add(c);

  }
  num FETCH([int nb_ligne=10]);
  get ROWS ;
  void CLEAR_BLOCK() ;
  void GO_RECORD(int number) ;
  Map<String,Dynamic> toJson();
  /*Trigger */
  bool LOCK_RECORD();
  bool VALIDATE_ITEM(String row,String col,String value) {}
  bool VALIDATE_RECORD() {}
  bool NEW_RECORD_INSTANCE() {}
  bool PRE_QUERY() {}
  bool EXIT_BLOCK() {}
  bool ENTER_BLOCK() {}

   StringBuffer get HTMLContent {
    StringBuffer content=new StringBuffer();
    int i=0;
    this.ROWS.forEach( (List<String> r) {
      i++;
      int j=0;
      content.add("""<tr num="${i}">""");
      r.forEach( (col) {
        j++;
        content.add("""<td num="${j}""><input value="${col}"/></td>""") ;
      });
      content.add("</tr>");
    });
    return content;
  }


}



