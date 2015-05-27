import 'package:FDart/client/fdart_client.dart';


class MODEL extends CBlock{
  bool VALIDATE_ITEM(String row,String col,String value)
  {
    print ("validates");
    if (col=="1") {
        int.parse(value);
      };


  }

}


main() {


 CForm Form=new CForm("TEST");
 CBlock cust= new MODEL();
 cust.NAME="CUSTOMER";

 cust.ADD_COLUMN(new Column("id")..VISIBLE=false
                                 ..DATA_TYPE="NUMBER"
                                 ..PRIMARY_KEY=true
    );
 cust.ADD_COLUMN(new Column("FISTNAME")..LABEL="First Name"
                                        ..DATA_TYPE="TEXT"
                                        ..DISPLAY_TYPE="input"
                                        ..STYLE="height: 12px; "
                );

 cust.ADD_COLUMN( new Column("LASTNAME")..DATA_TYPE="TEXT"
                                        ..DISPLAY_TYPE="input"
                                        ..LABEL="Last Name"
                                        ..STYLE="height: 12px; "
                                        );
 cust.ADD_COLUMN( new Column("SEX")
     ..LABEL=r"Sex"
     ..DISPLAY_TYPE="choice"
     ..STYLE="width:100px"
 );
 cust.ADD_COLUMN( new Column("PHONE")..DATA_TYPE="PHONE"
                                        ..LABEL=r"Phone N°"
                                        ..STYLE="height: 12px; width:200px"
                                        );


 CBlock purshase=new CBlock();
 purshase.NAME="PURSHASE";
 purshase.ADD_COLUMN(new Column("id")..VISIBLE=false..DATA_TYPE="NUMBER"..PRIMARY_KEY=true);
 purshase.ADD_COLUMN(new Column("CUST_id")..VISIBLE=false..DATA_TYPE="NUMBER");

 purshase.ADD_COLUMN(
  new Column("NAME")
    ..DISPLAY_TYPE="input"
    ..LABEL="Date"
 );

 purshase.ADD_COLUMN(
   new Column("VALUE")
     ..DISPLAY_TYPE="input"
     ..LABEL="Total"
 );
 purshase.FOREIGN_KEYS.add("CUST_id");
 cust.CHILDS.add(new Relation(purshase,["id"] ,""));

 Form.addBlock(cust);
 Form.init().then( ( bool status) {

     Form.GO_BLOCK("CUSTOMER");
     Form.EXECUTE_QUERY("");
 }
 );}