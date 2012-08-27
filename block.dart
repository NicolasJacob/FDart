#library ("block");

class Column {
  final String NAME;
  String DATA_TYPE;
  String DISPLAY_TYPE; 
  Column(this.NAME,this.DATA_TYPE,this.DISPLAY_TYPE);
}
class Block {
  final String NAME ;
  String _table ;
  String QUERY ;
  Map<String,Column> COLUMNS;
  
  List<List<String>> _data_fetched;
  bool _query_in_progress;
  set TABLE(String t) {
  	this._table= t;
  	this.QUERY="""
  	SELECT * FROM ${this._table} 
  	""";
  }
  Block.fromTable(String name, String table): this.NAME=name {
  	this.TABLE=table;
  	this._query_in_progress=false;
  	this.COLUMNS=new Map<String,Column>();
  }
  String get TABLE() { return this._table; }
  
  bool EXECUTE_QUERY() {
  	print ("Execute Query ${this.QUERY}") ;
  	_data_fetched=new List<List<String>> ();
  	return true; //TODO
  }
  
  num FETCH([int nb_ligne=10]){
 	for (var i = 0; i < nb_ligne; i++) {
 	   var l = ["${i}","Record ${i}"];
      _data_fetched.add(l);
    }
  	return 10;
  }
  get ROWS() =>  _data_fetched;
  
  String toString(){
    return """
BLOCK\nTable: ${this.TABLE}""";
  }

}