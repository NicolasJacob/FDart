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
 CBlock model= new MODEL();
 model.NAME="MODEL";
 model.COLUMNS['ID']=new Column("ID","NUMBER","TEXT");
 model.COLUMNS['NAME']=new Column("NAME","TEXT","TEXT");
 
 CBlock input=new CBlock();
 input.NAME="INPUT";
 input.COLUMNS['ID']=new Column("ID","NUMBER","TEXT");
 input.COLUMNS['NAME']=new Column("NAME","TEXT","TEXT");
 input.COLUMNS['DEFAULT_VALUE']=new Column("DEFAULT_VALUE","TEXT","TEXT");
 
 model.CHILDS.add(new Relation(input,"MODEL.id=INPUT.MODEL_id"));
 
 Form.addBlock(model);
 Form.init().then( ( bool status) {
     
     Form.GO_BLOCK("MODEL");
     //Form.EXECUTE_QUERY();
 }
 );}