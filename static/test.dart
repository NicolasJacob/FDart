import "../client/fdart_client.dart";
import "../common/block.dart";


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
 cust.ADD_COLUMN(new Column("ID")..VISIBLE=false
                                 ..DATA_TYPE="NUMBER"
                                 ..PRIMARY_KEY=true
    );
 cust.ADD_COLUMN(new Column("FISTNAME")..LABEL="First Name"
                                        ..DATA_TYPE="TEXT"
                                        ..WIDTH=12
                );
 cust.ADD_COLUMN( new Column("LASTNAME")..DATA_TYPE="TEXT"
                                        ..LABEL="Last Name");
 cust.ADD_COLUMN( new Column("PHONE")..DATA_TYPE="PHONE"
                                        ..LABEL="Phone N°");


 CBlock purshase=new CBlock();
 purshase.NAME="PURSHASE";
 purshase.ADD_COLUMN(new Column("id")..VISIBLE=false..DATA_TYPE="NUMBER"..PRIMARY_KEY=true);
 purshase.ADD_COLUMN(new Column("CUST_id")..VISIBLE=false..DATA_TYPE="NUMBER");
 purshase.ADD_COLUMN(new Column("id")..VISIBLE=false
                                     ..DATA_TYPE="NUMBER"
                                     ..PRIMARY_KEY=true);
 purshase.ADD_COLUMN(new Column("NAME"));
 cust.CHILDS.add(new Relation(purshase,"MODEL.id=INPUT.MODEL_id"));

 Form.addBlock(cust);
 Form.init().then( ( bool status) {

     Form.GO_BLOCK("CUSTOMER");
     //Form.EXECUTE_QUERY();
 }
 );}