
class SBlock extends  Block {

  List<List<String>> _data_fetched;
  bool _query_in_progress;
  final String _name ;
  String _table ;
  String QUERY ;
  String _where;

  var nb_rows;

  SBlock.fromTable(this._name, this._table)  {
    this.COLUMNS=new Map<String,Column>();
  }
  
  set TABLE(String t) {
    this._table= t;
    this.QUERY="""
    SELECT * FROM ${this._table} 
    """;
  }
  get NAME() =>  this._name;

  String get TABLE() { return this._table; }
  

  
 
  bool EXECUTE_QUERY(String where_clause) {
    //print ("Execute Query ${this.QUERY}") ;
    _data_fetched=new List<List<String>> ();
    _where=where_clause;
    nb_rows=0;
    return true; //TODO
  }
  
  num FETCH([int nb_ligne=10]){
    _data_fetched=new List<List<String>> ();
    switch (this.NAME) {
    case 'MODEL': 
      for (var i = 0; i < nb_ligne; i++) {
         var l = ["${nb_rows}","Model ${nb_rows}"];
        _data_fetched.add(l);
        nb_rows++;
      }
      break;
    case 'INPUT':
      
      for (var i = 0; i < nb_ligne; i++) {
         var l = ["${nb_rows}","Input ${_where} ${nb_rows}",i];
        _data_fetched.add(l);
        nb_rows++;
      }
      break;
      
    }
    return 10;
  }
  get ROWS() =>  _data_fetched;
  
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