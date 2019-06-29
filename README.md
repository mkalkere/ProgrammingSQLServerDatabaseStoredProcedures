# Programming SQL Server Database Stored Procedures

## Creating Your First Stored Procedure

   - Introduction
   - A Quick SQL Server Recap
   - What Is a Stored Procedure
   - Installing SQL Server and Setting up a Database
   - Stored Procedure T-SQL Statements
        Create Procedure
        ```
            CREATE PROCEDURE <name of procedure>
            (Parameters (optional))
            AS
            BEGIN;
                Statements here...
            END;
        ```
        - Stored procedure names should be unique, however you can use the same name in the different schemas
        
        _Naming and Schemas_
            
            Ex:
                Report.SelectContact
                Contact.SelectContact
        
        Alter Procedure
        ```
            ALTER PROCEDURE <name of the procedure>
            (Parameters (optional))
            AS
            BEGIN;
                Statements here...
            END;
        ```
        - There is no difference between _Create Procedure_ and _Alter Procedure_, Othere than alter procedure does not change permissions.
        - Microsoft is considering if _Alter Procedure_ should even be in SQL server. It isn't used much and has been moved to maintenance mode. Most developers drop and create the procedure.
        
        DROP PROCEDURE
        ```
            DROP PROCEDURE [IF EXISTS] <name of the procedure>;
        ```
        - _IF EXISTS_ only works in 2017 and higher.
        
   - Creating a StoredProcedure
       ```
         Use Contacts;

         GO

         CREATE PROCEDURE dbo.SelectContacts
         AS
         BEGIN;--//SP BEGIN

         SELECT * FROM dbo.Contacts;

         END;--//SP END
       ```
       Executing a Stored Procedure
       ```
        EXEC dbo.SelectContacts
       ```
        
        - Always make sure you are in a correct database by using the USE statement.
        - Semicolon(;) is not mandatory at the end of each SQL statements, But [Microsoft](https://www.microsoft.com/en-us/ , "Microsoft") recommends as it might become mandatory in the future.
     
        
        
   - Managing Procedures Using SQL Server Management Studio
   - Summary
   
   
