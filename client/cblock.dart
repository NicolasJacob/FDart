part of fdart_client;

/** CBlock:
 * Dart client side of a Block
 * Method communicate with server using JSON
 * Data are in the DOM
 */
class CBlock extends Block  {


  CForm  _FORM;
  int BUSY=0;

  Map<String,dynamic> toJson()
  {
    print("toJSON");
    return {
      'name':this.NAME,
      'relations': JSON.stringify(this.CHILDS),
      'columns': JSON.stringify(this.COLUMNS)
    } ;
  }
  get FORM => this._FORM;
  set FORM (v) => this._FORM=v;

  Element _element;

  get element => this._element;
  set element (v) => this._element=v;

  CBlock() {}


  /* Data Exchange with remote server */

  void EXECUTE_QUERY(String where_clause) {
     this.send(Operation.EXECUTE_QUERY, {'where': where_clause} );
  }



  num FETCH([int nb_ligne=10]) {
    if (this.BUSY<=0) {
      this.BUSY++;
      this.send(Operation.FETCH, {'number':nb_ligne} );
    }
  }

  bool LOCK_RECORD() {

    this.send (Operation.LOCK, { "row_number": this.CURRENT_RECORD.number } );
    return true;
  }


  get ROWS {
    throw ("ROWS: No such method");
  }


  /* Navigation */
  void GO_RECORD(int number)
  {
    /*if (this.CURRENT_RECORD.number > 0 ) {
      VALIDATE_RECORD();
    }
    */
    this.CURRENT_RECORD.number=number;
    NEW_RECORD_INSTANCE();
  }
  get CURRENT_VALUE
  {

  }
  void GO_ITEM(int num)
  {
    this.CURRENT_ITEM.number=num;
  }




  void CLEAR_BLOCK() {
    Element el = this.getDataElement();
    if (el != null) { el.innerHTML="";}
    this.CURRENT_RECORD.number = 0;
    this.CURRENT_ITEM.number = 0;
  }



  Element getDataElement() {
    return this.element.query('tbody');
  }

  void send(String operation, data ) {
    var msg=JSON.stringify({'operation': operation, 'block':NAME, 'data': data});
    print( "Send : $msg");
    this.FORM.ws.send(msg);
  }

  void toHTMLTable() {
 
    var d=new DivElement()..id=this.NAME
                          ..attributes["style"] ="overflow:auto; width:400px; height:300px; border-style:solid; border-width:1px;" ;

    d.nodes.add(
        new ButtonElement()..text="Clear"
                           ..on.click.add( (e) {
                                 this.CLEAR_BLOCK();
                              }
                              ));
    d.nodes.add( new ButtonElement()..text="Query"
        ..on.click.add( (e) {
          this.CLEAR_BLOCK();
          this.EXECUTE_QUERY("");
        }));

    d.nodes.add( new ButtonElement()..text="Save"
        ..on.click.add( (e) {
      this.SAVE();
    }
    ));

    TableElement t=new TableElement();
    t.classes.add("deftable");
    d.nodes.add(t);


    t.createTHead();
    TableRowElement tr=t.tHead.insertRow(-1);
    var i=0;
    this.COLUMNS.forEach( (Column val) {
        //el.hidden=!val.VISIBLE;
        tr.insertCell(-1)..text=val.LABEL
                          ..hidden=!this.COLUMNS[i].VISIBLE;
        i++;
    });
    t.createTBody();
    this.element.nodes.add(d);

  }

  void appendData( List<List<dynamic>> data)
  {
    var i =0;
    TableSectionElement tbody= this.element.query("tbody");
    
  
    data.forEach( (List<dynamic> r) {
      TableRowElement tr=tbody.insertRow(-1);
      tr.id=r[0];
      //content.add("""<tr num=${id}>""");
      var j=0;
      r[1].forEach( (col) {

        tr.insertCell(-1)..id="$j"
                         ..hidden=!this.COLUMNS[j].VISIBLE
                         ..addHTML("""<input value="${col}"/>""");
        j++;
      });
    });
    
    
 

  }


  void addNodeEvent(Element elt) {
    elt.queryAll("input").forEach( (Element input) {
      //print("Add envents to $input ");
      input.on.focus.add((evt) {
        InputElement cell= evt.srcElement;
          if ( ! cell.attributes.containsKey("initialValue")) {
            cell.attributes["initialValue"]=cell.value;
          }
          cell.parent.parent.classes.add("focus");
          //cell.parent.parent.attributes["class"]="focus";
          int row=int.parse(cell.parent.parent.attributes['id']);
          int col=int.parse(cell.parent.attributes['id']);
          if (row != this.CURRENT_RECORD.number) {
            //print('focus $row , $col');
            GO_RECORD(row );

            this.CHILDS.forEach( (Relation r) {
              r.CHILD.CLEAR_BLOCK();
              r.CHILD.EXECUTE_QUERY("MODEL $row");
            });
          }
          GO_ITEM(col);
          //this.ON_LOCK();
        });

      input.on.blur.add((evt) {
        //print('blur');
        InputElement cell= evt.srcElement;
        cell.parent.parent.classes.remove("focus");
        if (cell.attributes["initialValue"]!=cell.value) {
          cell.parent.parent.classes.add("dirty");
          try {
            VALIDATE_ITEM(cell.parent.parent.attributes['num'],cell.parent.attributes['num'],cell.value);
            cell.classes.remove("error");
          }
          catch (e)
          {
            print ('Invalid value: $e');
            cell.classes.add("error");
          }
        }

       //cell.parent.parent.attributes["class"]="";
        //TODO: validate item, and cancel navigation in case of failure
      });
    }
    );
  }
  void message(String m) {
    window.alert(m);
  }
  
  void SAVE() {
    bool ok=true;
    this.element.queryAll(".error").forEach( (Element td) {
      if (td.classes.contains("error")) {
        ok=false;
        message("Cannot save: error on  $td ");
      }
    }
    );
    if (ok) {
      this.element.queryAll("tr.dirty").forEach( (Element tr) {
          this.BUSY++;
          List data=new List();
          tr.queryAll("input").forEach((InputElement i) {
            data.add(i.value);
          });
          this.send(Operation.UPDATE,{'json': data });
          tr.classes.remove("dirty");
      }
      );
    }
  }
  void setupTable( ) {
    Element div=this.element.query("div");
    div.on.scroll.add((e) {
      DivElement div=e.srcElement;

      print ('scrollHeight ${div.scrollHeight} / ${div.clientHeight} + ${div.scrollTop}');
      if ((div.scrollHeight==div.clientHeight + div.scrollTop)) {
        FETCH(10);

      }
     }
   );
   div.queryAll("td").forEach( addNodeEvent) ;

  }

}



