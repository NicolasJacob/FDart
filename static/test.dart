#import("../client/client.dart");

main() {
 CForm Form=new CForm("TEST");
 Form.init().then( ( bool status) {
    
     Form.GO_BLOCK("MODEL");
     //Form.EXECUTE_QUERY();
 }
 );
}