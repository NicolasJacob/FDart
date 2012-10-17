#import("../client/client.dart");
#import("../common/block.dart");


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
 CBlock MODEL= new MODEL();
 MODEL.NAME="MODEL";
 MODEL.COLUMNS['ID']=new Column("ID","NUMBER","TEXT");
 MODEL.COLUMNS['NAME']=new Column("NAME","NUMBER","TEXT");
 Form.addBlock(MODEL);
 Form.init().then( ( bool status) {
     
     Form.GO_BLOCK("MODEL");
     //Form.EXECUTE_QUERY();
 }
 );}