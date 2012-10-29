part of fdart_server;


class SBlock extends  Block {

  List<List<String>> _data_fetched;
  bool _query_in_progress;
  final String _name ;
  String _table ;
  String QUERY ;
  String _where;
  Map<String,List<dynamic>> database={};

  var nb_rows;


  SBlock.fromTable(this._name, this._table) ;


  set TABLE(String t) {
    this._table= t;
    this.QUERY="""
    SELECT * FROM ${this._table}
    """;
  }
  get NAME =>  this._name;

  String get TABLE { return this._table; }




  bool EXECUTE_QUERY(String where_clause) {
    //print ("Execute Query ${this.QUERY}") ;
    _data_fetched=new List<List<String>> ();
    _where=where_clause;
    nb_rows=0;
    return true; //TODO
  }

  num FETCH([int nb_ligne=10]){
    this.database.forEach( (k,v) {
      this._data_fetched.add([ k , v]);
    });


    return 10;
  }
  get ROWS =>  _data_fetched;

  String toString(){
    return """
BLOCK\nTable: ${this.TABLE}""";
  }

  /*Trigger */
  void EXIT() {

  }
  void ENTER() {

  }


  StringBuffer toHTMLTable() {
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