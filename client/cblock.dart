part of fdart_client;

abstract class FormInputElement{
  get initial_value ;
  get current_value ;

}


/** CBlock:
 * Dart client side of a Block
 * Method communicate with server using JSON
 * Data are in the DOM
 */
class CBlock extends Block  {


  CForm  _FORM;
  int BUSY=0;
  bool editable=false;
  

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
  
  Element  row(int num) 
  {
    return this.element.query("tbody").queryAll("tr")[num];
  }
  
  Column getColumnDef(String name) => this.COLUMNS[this.rowMap[name]];
  
  dynamic getValue(String column_name) {
    print("Current record ${CURRENT_RECORD.number}");
    Element row=this.row(CURRENT_RECORD.number);
    print (row);
    Column col=getColumnDef(column_name);
    Element cell=row.queryAll("td")[this.rowMap[column_name]];
    switch (col.DISPLAY_TYPE) {
      case "input": 
        return (cell.nodes[0] as InputElement).value;
      default:
        return cell.nodes[0].text;
    }
   
    
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
    print ("style: ${this.element.style}");
    var mainDiv=new DivElement()..id=this.NAME
                          ..attributes["style"] =this.element.attributes["style"];

    mainDiv.nodes.add(
        new ButtonElement()..text="Clear"
                           ..on.click.add( (e) {
                                 this.CLEAR_BLOCK();
                              }
                              ));
    mainDiv.nodes.add( new ButtonElement()..text="Query"
        ..on.click.add( (e) {
          this.CLEAR_BLOCK();
          this.EXECUTE_QUERY("");
        }));

    mainDiv.nodes.add( new ButtonElement()..text="Save"
        ..on.click.add( (e) {
      this.SAVE();
    }

    ));
    mainDiv.insertAdjacentHTML("beforeend", "Edit");
    mainDiv.nodes.add(new InputElement()..type="checkbox"
        ..on.change.add ( (e) {
          this.editable=(e.srcElement as InputElement).checked;
          
        })
        );

    
    
    TableElement tableHeader=new TableElement();
    
    tableHeader..attributes["style"] =this.element.attributes["header-style"];
    var headerDiv=new DivElement()..id="${this.NAME}_header"
                                  ..attributes["style"]="width:${tableHeader.style.width}; ";
    
    tableHeader.createTHead();
    TableRowElement tr=tableHeader.tHead.insertRow(-1);
    tr..attributes["style"] =this.element.attributes["header-style"];
    var i=0;
    this.COLUMNS.forEach( (Column col) {
        //el.hidden=!val.VISIBLE;
        col.header= tr.insertCell(-1);
        col.header..text=col.LABEL
                  ..hidden=!col.VISIBLE
                  ..attributes["style"]=this.element.attributes["header-cell-style"];
        
        i++;
    });
    
    headerDiv.nodes.add(tableHeader);
    mainDiv.nodes.add(headerDiv);
    
   
    
    TableElement dataTable=new TableElement();
    dataTable..attributes["style"] =this.element.attributes["table-style"];
 
    var tableDiv=new DivElement()..id="${this.NAME}_data"
      ..attributes["style"]="height:${dataTable.style.height}; resize:both; width:${dataTable.style.width}; overflow:auto";
    mainDiv.nodes.add(tableDiv);
    
    mainDiv.nodes.add(dataTable);
  
    
    dataTable.createTBody();
    
    
    tableDiv.nodes.add(dataTable);
    tableDiv.on.scroll.add((Event e) {   
      DivElement div=e.srcElement;
      print ('scrollHeight ${div.scrollHeight} / ${div.clientHeight} + ${div.scrollTop}');
      if ((div.scrollTop>0) && (div.scrollHeight==div.clientHeight + div.scrollTop)) {
        FETCH(10);
      }
     });

    DivElement tf=new DivElement();
    tf..id="${this.NAME}_footer"
      ..insertAdjacentHTML("beforeend", "<p>Fetched Record: 0/?");
    mainDiv.nodes.add(tf);
    this.element.nodes.add(mainDiv);
 
  }
  void syncHeader() 
  { 
    int i=0;
    TableSectionElement tbody= this.element.query("#${this.NAME}_data").query("tbody");
    TableRowElement tr=tbody.nodes[0];

    this.COLUMNS.forEach( (Column col) {
   
      TableCellElement cell=tr.nodes[i];
      print(cell);
      double width=cell.getBoundingClientRect().width;
      try {
        print("remove: ${col.header.style.paddingLeft} ");
        String p=col.header.style.paddingLeft;
       
        width=width- double.parse(p.replaceFirst("px",""));
      } catch (e) {
         print(e);
      }
      col.header.width="${width}px";
      i++;
    });
    
  }
  void appendData( List<List<dynamic>> data)
  {
    var i =0;
    
    TableSectionElement tbody= this.element.query("#${this.NAME}_data").query("tbody");
    
    
    data.forEach( (List<dynamic> r) {
      TableRowElement tr=tbody.insertRow(-1);
      tr..attributes["style"] =this.element.attributes["row-style"];
      tr.id="$i";
      i++;
      //content.add("""<tr num=${id}>""");
      var j=0;
      r[1].forEach( (col) {
        Column c=this.COLUMNS[j];
        TableCellElement cell=tr.insertCell(-1);
         cell..id="$j"
             ..hidden=!c.VISIBLE
             ..attributes["style"] =this.element.attributes["cell-style"];
         switch (c.DISPLAY_TYPE) {
         case "textarea":
             TextAreaElement txt=new TextAreaElement();
			       txt..rows=1
			           ..text="$col"
			           ..attributes["style"]=c.STYLE;
			       txt.on.focus.add(onRowFocus);
			       txt.on.blur.add(onRowBlur);
			       cell.insertAdjacentElement("beforeend", txt)  ;  
             break;
         case "input":
           InputElement txt=new InputElement();
           txt..value="$col"
               ..attributes["style"]=c.STYLE;
           txt.on.focus.add(onRowFocus);
           txt.on.blur.add(onRowBlur);
           cell.insertAdjacentElement("beforeend", txt)  ;
           break;
         case "choice":
           SelectElement txt=new SelectElement();
        
           document.query("#gender").queryAll("option").forEach( (Element e) {
            txt.insertAdjacentElement("beforeend", e.clone(true));});
           
           txt..value='$col'
               ..attributes["style"]=c.STYLE;
           txt.on.focus.add(onRowFocus);
           txt.on.blur.add(onRowBlur);
      
           cell.insertAdjacentElement("beforeend", txt)  ;
           break;
         default:
           cell..insertAdjacentHTML("beforeend", """<div style="${c.STYLE}" >$col</div>""");
           break;
         }
        j++;
      });
    });
    int nb_items=tbody.queryAll("tr").length;
    this.element.query("#${this.NAME}_footer").nodes[0].text="Fetched Records: $nb_items";

    this.syncHeader();
    
 

  }
  
  void onRowFocus(Event evt)  {
    print ("focus");
    Element cell= evt.srcElement;
    if ( ! cell.attributes.containsKey("initialValue")) {
      cell.attributes["initialValue"]=cell.value;
    }
    (cell.parent.parent as Element).classes.add("focus");
    //cell.parent.parent.attributes["class"]="focus";
    int row=int.parse( (cell.parent.parent as Element).attributes['id']);
    int col=int.parse( (cell.parent as Element).attributes['id']);
    if (row != this.CURRENT_RECORD.number) {
      //print('focus $row , $col');
      GO_RECORD(row );
      this.CHILDS.forEach( (Relation r) {
        r.CHILD.CLEAR_BLOCK();
        String where="";
        int k_idx=0;
        r.PARENT_KEYS.forEach( (String k) {
          where=where.concat( " ${r.CHILD.FOREIGN_KEYS[k_idx]} = ${this.getValue(k)}"); 
        }); 
        r.CHILD.EXECUTE_QUERY(where);
      });
    }
    GO_ITEM(col);
  }
  void onRowBlur(Event evt)  {
    Element cell= evt.srcElement;
    Element gparent=cell.parent.parent;
    Element ggparent=cell.parent.parent;
    gparent.classes.remove("focus");
    if (cell.attributes["initialValue"]!=cell.value) {
      ggparent.classes.add("dirty");
      try {
        VALIDATE_ITEM(ggparent.attributes['num'],gparent.attributes['num'],cell.value);
        cell.classes.remove("error");
      }
      catch (e)
      {
        print ('Invalid value: $e');
        cell.classes.add("error");
      }
    }
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
          tr.queryAll("textarea").forEach((TextAreaElement i) {
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

 

  }

}



