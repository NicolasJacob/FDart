#library ("block");

class Column {
  final String NAME;
  String DATA_TYPE;
  String DISPLAY_TYPE; 
  boolean dirty;
  Column(this.NAME,this.DATA_TYPE,this.DISPLAY_TYPE);
}

abstract class Block {
  get NAME;
  void EXECUTE_QUERY();
  num FETCH([int nb_ligne=10]);
  get ROWS() ;
  
  /*Trigger */
  void EXIT() ;
  void ENTER() ;
}


