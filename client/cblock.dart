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

class CBlock implements Block  {
  final String NAME;
  final CForm  FORM; 
  int BUSY;
  Record CURRENT_RECORD;
  Item CURRENT_ITEM;
  final List<Column> COLUMNS=new List<Column>() ;
  Element element;
  
  CBlock(this.NAME,this.FORM) 
  {
    this.CURRENT_RECORD =new Record(0);
    this.CURRENT_ITEM =  new Item(null); 
    this.BUSY=0;
  } 
  
  CBlock.fromJSON(form,jdata): this.FORM=form , this.NAME=jdata['block'] 
  {
    this.CURRENT_RECORD=new Record(0);
    this.CURRENT_ITEM =  new Item(null);
    this.BUSY=0;
  }
  
  void EXECUTE_QUERY() {
    var m=JSON.stringify({
      'operation':'EXECUTE_QUERY', 
      'block': this.NAME,
       });
     FORM.ws.send(m);
  }
  /*Trigger */
  void EXIT() {
    
  }
  void ENTER() {
    
  }
  
  num FETCH([int nb_ligne=10]) {
    if (this.BUSY<=0) {
      this.BUSY++;
      this.send('FETCH', {'number':nb_ligne} );
    }
  }
  
  Element getDataElement() {
    return this.element.query('#${this.NAME}_DATA');
  }
  
  get ROWS() {
    
  }
  void CLEAR_BLOCK() {
    this.getDataElement().innerHTML="";
    this.CURRENT_RECORD.number = 0;
    this.CURRENT_ITEM.number = 0;
  }
  
  void ON_LOCK() {
    var data={ "row_number": this.CURRENT_RECORD.number };
    send ("LOCK", data );
  }
    
  void send(String operation, data ) {
    var msg=JSON.stringify({'operation': operation, 'block':NAME, 'data': data});
    print( "Send : $msg");
    this.FORM.ws.send(msg);
  }
  
  void toHTMLTable() {
    StringBuffer content=new StringBuffer();
    content.add(
        """<div id="${this.NAME}"  style="overflow:auto; width:400px; height:300px; border-style:solid; border-width:1px; ">"""
    );
    content.add(
        """<button id="clear">Clear</button>
           <button id="query">Query</button>
        """
    );
    content.add(
        """<table class="deftable">
        <thead>
        """
    );
    content.add("<tr>");
    this.COLUMNS.forEach( (val) {
      content.add("<td>${val.NAME}</td>");
    });
    content.add("</tr></thead>");
    
    content.add("""<tbody  contenteditable  id="${this.NAME}_DATA" ></tbody></table></div>""");
    this.element.insertAdjacentHTML("beforeend", content.toString());
    Element b = this.element.query("#query");
    b.on.click.add( (e) {
  
      this.EXECUTE_QUERY();
    }
    );
    b =this.element.query("#clear");
    b.on.click.add( (e) {
  
      this.CLEAR_BLOCK();
    }
    );
  }
  
  void appendData( List<List<String>> data)
  {
    var i =0;
    StringBuffer content=new StringBuffer();
    data.forEach( (List<String> r) {
      i++;
      content.add("""<tr num=${i}>""");
      var j=0;
      r.forEach( (col) {
        j++;
        content.add("<td num=$j >${col}</td>") ;
      });
      content.add("</tr>");
    });
    this.element.query("tbody").insertAdjacentHTML("beforeend", content.toString());

  }
  
  void VALIDATE_ITEM(){
    print ("VALIDATE_ITEM");
  }
  void VALIDATE_RECORD(){
    print ("VALIDATE_RECORD");
  }
  void NEW_RECORD_INSTANCE(){
    print ("NEW_RECORD_INSTANCE");
  }
  
  void GO_RECORD(int number) 
  {
    if (this.CURRENT_ITEM.number != 0) {
      VALIDATE_ITEM();
    }
    if (this.CURRENT_RECORD.number > 0 ) {
      VALIDATE_RECORD();
    }
    this.CURRENT_RECORD.number=number;
    NEW_RECORD_INSTANCE();
  }
  get CURRENT_VALUE() 
  {
    
  }
  void GO_ITEM(int num) 
  { 
    
    if (this.CURRENT_ITEM.number != null) {
      VALIDATE_ITEM();
    }
    this.CURRENT_ITEM.number=num;
  }
  
  void setupTable( ) {
    Element div=this.element.query("div");
    div.on.scroll.add((e) {
      Element div=e.srcElement;
      print ('scrollHeight ${div.$dom_scrollHeight} / ${div.$dom_clientHeight} + ${div.$dom_scrollTop}');
      if ((div.$dom_scrollHeight==div.$dom_clientHeight + div.$dom_scrollTop)) {
        FETCH(10);
        
      }
     }
   );
   div.queryAll("tr").forEach( (Element tr) {
     tr.on.click.add((evt) {
          GO_RECORD(int.parse(tr.attributes['num']) );
          GO_ITEM(int.parse(evt.srcElement.attributes['num']) );
          this.ON_LOCK();
          }
        );
     
    }
   );
  }
  
}



