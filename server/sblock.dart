part of fdart_server;


class SBlock extends  Block {

  List<List<String>> _data_fetched;
  bool _query_in_progress;
  final String _name ;
  String _table ;
  String QUERY ;
  WhereClause _where;
  Map<String,List<dynamic>> data={};

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

  WhereClause parse_where_clause (String where_clause) {
    if (where_clause == "") { return null;}
    var k_v=where_clause.split("=");
    print (k_v);
    return new WhereClause()..where=(new WhereList()..operator=""
                                                     ..items=[ new WhereItem()..column=k_v[0].trim()
                                                        ..value=k_v[1].trim()
                                                   ]);
  }
  bool match_where_clause(List<dynamic> v) {
    bool ret=true;
    this._where.where.items.forEach( (WhereItem c) {
      if ( "${v[this.rowMap[c.column]]}" != "${c.value}" )
      {
         ret = false;
      } 
    });
    return ret;
  }

  bool EXECUTE_QUERY(String where_clause) {
    //print ("Execute Query ${this.QUERY}") ;
    _data_fetched=new List<List<String>> ();
    _where=parse_where_clause(where_clause);
    nb_rows=0;
    return true; //TODO
  }

  num FETCH([int nb_ligne=10]){
    this.data.forEach( (k,v) {
      if (  _where == null || this.match_where_clause(v)) {
        this._data_fetched.add([ k , v]);
      }
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
      content.write("""<tr num="${i}">""");
      r.forEach( (col) {
        j++;
        content.write("""<td num="${j}""><input value="${col}"/></td>""") ;
      });
      content.write("</tr>");
    });
    return content;
  }



}