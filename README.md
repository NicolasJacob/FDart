#FDart: Dart for Oracle Forms Developper


Coming from Oracle Forms and wanting to write RIA database applications ?

FDart is designed for you.

Checks the FDart features below to get conviced.

NOTE: FDart is under development and not ready yet. 

##FDart Feature (for Forms User)

### Similarities
* Block and Column are the main concepts for data. They are similar (same properties) in FDart.
* Directives (GO\_BLOCK/EXECUTE\_QUERY)
* Trigger mechanism (ON\_LOCK,ON\_VALIDATE\_ITEM...).
* Master/Detail relationship management.
* LOV (List of value)

###Differences
* Darts as a single language for client and server side code.
* The Client is a HTML5/CSS/Dart RIA application. FDart blocks can live in any web page.
* Most actions are performed on the client side (server is solicited only when data are required). This provide a richer user experience.
* FDart block can serve data not only from Table or Query, but also from others  datasource (JSON,XML,HTTP).
* Object Oriented : You can extend FDart block to create you custom block, either to define common rules or to provide advanced features.
* Declarative, Block can be fully managed in a declarative manner directly in the HTML.
* Programmatic: Block can also be fully managed in Dart,and Dart can be used to enrich blocks created in a declarative ways.
* PLSQL: Unfortunately PLSQL is not supported. All data shall be accessed and manipulated through blocks using collection feature.


##Samples
###Simplest FDart forms
This sample fully manage the data of the CUSTOMER table.

HTML File

    <html>
        <body>
        <p>Custormer List</p>   
        <block   name="MODEL" 
                 query="SELECT NAME,PHONE,ADDRESS FROM MODEL"
                 style="table"
                 editable
         >  
        </bock>
        <script type="application/dart" src="test.dart"></script>
        <script src="http://dart.googlecode.com/svn/branches/bleeding_edge/dart/client/dart.js">
        </script>
      </body>
    </html>



Dart Code  (test.dart):


    import "fdart_client.dart";
    main() 
    {
       CForm Form=new CForm("TEST");
       Form.init(<database connection>).then( ( bool status) {
         GO_BLOCK("MODEL"); 
         EXECUTE_QUERY();
       }
    }

###Master Detail in FDart:
HTML File
     
        ...  
        <block   name="MODEL"  -- Block defined in dart
         />  
        ...


Dart Code  (test.dart):


    class MODEL extends CBlock{
    bool VALIDATE_ITEM(String col,String value) 
    {
      if (col=="ID") {
          int.parse(value);
        };
    }
     }

     CForm Form=new CForm("TEST");

     // Create MODEL block in a programmatic way
     CBlock model= new MODEL();
     model.NAME="MODEL";
     model.COLUMNS['ID']=new Column("ID","NUMBER","TEXT");
     model.COLUMNS['NAME']=new Column("NAME","TEXT","TEXT");

    // Create INPUT block as a child of MODEL block.
     CBlock input=new CBlock();
     input.NAME="INPUT";
     input.COLUMNS['ID']=new Column("ID","NUMBER","TEXT");
     input.COLUMNS['NAME']=new Column("NAME","TEXT","TEXT");
     input.COLUMNS['DEFAULT_VALUE']=new Column("DEFAULT_VALUE","TEXT","TEXT");
     
     model.CHILDS.add(new Relation(input,"MODEL.id=INPUT.MODEL_id"));
     
     Form.addBlock(model);
     Form.init().then( ( bool status) {
         GO_BLOCK("MODEL");
         EXECUTE_QUERY();
       }
    }