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
        - Semicolon(;) is not mandatory at the end of each SQL statements, But [Microsoft](https://www.microsoft.com/en-us/ "Microsoft") recommends as it might become mandatory in the future.
     
        Altering Stored Procedure
         
         ```
             Use Contacts;

             GO

             ALTER PROCEDURE dbo.SelectContacts
             AS
             BEGIN;--//SP BEGIN

             SELECT * FROM dbo.Contacts WHERE FirstName = 'Grace';

             END--//SP END
         ```
        
        
   - Managing Procedures Using SQL Server Management Studio
      - Stored Procedures
      - Natively Compiled Stored Procedures
         - Natively compiled stored procedures where first introduced ib SQL Server 2014.
         - When created they are compiled into _C programming language_ and are available to immediate use.
         - Natively Compiled Stored Procedures can only access in-memort tables, which are fairly advanced feature of SQL Server.
         - In-memory tables are fast and can be accessed fairly faster by the natively compiled stored procedures as opposed to regular stored procedures.
   
      Drop Stored Procedures
      
      ```
         DROP PROCEDURE IF EXISTS dbo.SelectContacts; --//IF EXISTS is only availabe in SQL Server 2017 and above
      ```
      
       - If yoy are using SQL Server versions before 2017 then you need to check the metadata table _sys.procedures_ to see if the stored procedure exists before trying to drop it.
         
         ```
            IF EXISTS(SELECT 1 FROM sys.procedures WHERE [Name] = 'dbo.SelectContacts')
            BEGIN;
               DROP PROCEDURE dbo.SelectContacts;
            END;
         ```
   
   - Summary
   
      - What a stored procedure is.
      - Benefits of stored procedure (Security and Code re-use).
      - Avoid bad practises like cursors!
      - Installing SQL Server.
      - T-SQL procedure statements
      - Managing procedures in Management Studio
      
   
## Creating Stored Procedures and Using Parameters

   - Introduction
      - Creating a Simple Stored Procedure
      - Adding Parameters
      - Optional and Output Parameters
      - Returning Data and System Options in stored Procedures
      
   - The Business Requirement
      
      - Insert Contact Procedure Requirements
         - Insert Contact
         - Return Details
         - Return ID
         - No Duplicates
      
      Alternate Options to Stored Procedures:
      1. Using SQL Server Management Studio.
      2. Embedded SQL statements in Code.
         Embedded SQL Limitations:
          - If the database schema changes then the application code needs to change as the SQL is embedded in the code.
          - Then insert statements could be stored in the seperate file allowing it to be read and executed, but thats giving the SQL statements to the application, not the database. It also makes parameterising the code much more difficult.
      3. Object-relational Mapping (ORM)
         Examples in .NET World:
            Entity Framework
            NHibernate
            
         These are software libraries that try to take the lot of database hassele away from the developer. They aim to prevent the developer from needing to write SQL codes, instead generating the code on the fly through an object model. They require the model to be updated if the database schema changes/ This usually requires the re-compilation of the application. ORM's offer a good parameter facilities and hides a lot of database implementation from developers. However they also take a lot of control away from the developer. The SQL ORM's generated can be overly complicated and inefficient. They are worth looking at but probably won't fulfill your need if you want total control over your database access.
         
     4. Stored Procedure    
         The Procedure can safely handle the 3 core requirements:
            - The T-SQL insert statement can be used to perform the insert statement.
            - The SELECT statement will take care of returning the ID of the generated contact.                  
   
   - The Insert Contact Stored Procedure
   
        - Do not use the spaces in the procedure names.
        - All variables in SQL Server begin with _@_ symbol.
        
        Create a Stored Procedure
        
        ```
        USE Contacts;

         GO

         CREATE PROCEDURE dbo.InsertContact
         AS
         BEGIN;

            DECLARE @FirstName			VARCHAR(40),
                  @LastName				VARCHAR(40),
                  @DateOfBirth			DATE,
                  @AllowContactByPhone	BIT;

            SELECT @FirstName = 'Mallikh',
                  @LastName = 'Kalkere',
                  @DateOfBirth = '1990-01-01',
                  @AllowContactByPhone = 0;

            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

         END;
        ```
                 
   - Executing and Testing a Stored Procedure
   
    ```
         USE Contacts;

         EXEC dbo.InsertContact
    ```
   
   - Adding Parameters to a Stored Procedure
   
   
     - Parameters are the variables which are passed by the calling program.
        
          Parameters
            
               - Strings
                  - CHAR, VARCHAR..
               - Numbers
                  - INT, DECIMAL..
               - Dates, XML
               - Custom Types
               
        - Parameters make your code flexible and re-usable.
        
      ```
         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE,
            @AllowContactByPhone	BIT
         )
         AS
         BEGIN;

            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

         END;
      ```
      
      Passing Prameters
      
      ```
         EXEC dbo.InsertContact 'Oliver', 'Mardy', '1892-01-01',0;
         
         EXEC dbo.InsertContact  @FirstName = 'Terry', @LastName = 'Thomas',@DateOfBirth = '1911-01-01',@AllowContactByPhone = 0;

      ```

   - Optional Parameters
   
      - It's possible to assign a default value to a parameter
         
         `@ParameterName = default`
         
      - This default value acts as a placeholder. If no value is passed when the store procedure is called then the default value is used. The code then can check for this default vaue as determine what course of action to take. Ex, Throw an error, insert the data or even convert the data. 
      
      - Making the parameter optional is straightforeward. add = NULL to the paramater.
      
      ```
         USE Contacts;

         GO

         --// Optional Parameter
         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE = NULL,
            @AllowContactByPhone	BIT
         )
         AS
         BEGIN;

            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

         END;
         
         --//Executing the Stored Procedure without passing the Optional Parameter
         EXEC dbo.InsertContact  @FirstName = 'Norman', @LastName = 'Wisdom',@AllowContactByPhone = 0;
         
      ```
   
   - Retrieving Record Parameters
   
      - Returning Record ID
      
         - Stored procedure should perform only one task(atomic)
         - This task can be made of number of sub tasks.
         - Don't creat a procedure that do a lot of different things.
         - Seperate out the tasks and create the individual stored procedures for each tasks.
      
      - SQL Server System Functions
         
         SQL Server provides the number of system functions all of which can be used in scripts. The used to be known as _Global Variables_
      
      There are number of System Functions available:
         - @@IDENTITY
      
      ```
         USE Contacts;

         GO

         --// Retrieving Record Parameters
         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE = NULL,
            @AllowContactByPhone	BIT
         )
         AS
         BEGIN;

            DECLARE @ContactId INT;

            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

            SELECT @ContactId = @@IDENTITY;

            SELECT ContactId,FirstName,LastName,DateOfBirth,AllowContactByPhone
               FROM dbo.Contacts
            WHERE ContactId = @ContactId;
         END;
      ```
      
      Triggers run when a something happens to a record in a particular table.
      Trigger can run after an Update,Delete or an Insert.
      
      @@IDENTITY - Isn't Safe to use.
      @@IDENTITY returns the last identity value inserted into the entire database.
      
      There are 2 other options:
         - IDENT_CURRENT()
            - It is limited to the particular Table.
            - It applies to any session and any scope. It means if the two calls inserted a record at the same time then one of then could receive the wrong identity value.            
            
        - SCOPE_IDENTITY()
            - It returens the identity value within the current scope. It returns the value that is inserted by the stored procedure.
      
      ```
         USE Contacts;

         GO

         --// Retrieving Record Parameters
         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE = NULL,
            @AllowContactByPhone	BIT
         )
         AS
         BEGIN;

            DECLARE @ContactId INT;

            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

            SELECT @ContactId = SCOPE_IDENTITY();

            SELECT ContactId,FirstName,LastName,DateOfBirth,AllowContactByPhone
               FROM dbo.Contacts
            WHERE ContactId = @ContactId;
         END;
      ```
   
   - Output Parameters
   
      ```
         USE Contacts;

         GO

         --// Output Parameter
         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE = NULL,
            @AllowContactByPhone	BIT,
            @ContactId				INT OUTPUT
         )
         AS
         BEGIN;


            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

            SELECT @ContactId = SCOPE_IDENTITY();

            SELECT ContactId,FirstName,LastName,DateOfBirth,AllowContactByPhone
               FROM dbo.Contacts
            WHERE ContactId = @ContactId;
         END;
         
         --//Retrieving Output Parameters
         USE Contacts;

         DECLARE @ContactIdOut INT;

         EXEC dbo.InsertContact  @FirstName = 'Marold', @LastName = 'Lloyd',@AllowContactByPhone = 0,@ContactId = @ContactIdOut OUTPUT;

         SELECT * FROM Contacts WHERE ContactId = @ContactIdOut ORDER BY ContactId  DESC

         SELECT @ContactIdOut
         
      ```
            
   - Using SET Operations
   
      - SET Options only effect the current session.
         - SET DATEFORMAT        - _Determines the format in which the dates must be specified_
         - SET IDENTITY_INSERT   - _Allows the current executing statement to manually insert the value into the identity column_
         - SET NOCOUNT           - _Set Option is the command used to turn on or off the informational messages_
            SET NOCOUNT {ON|OFF} - ON stops the informational messages being returned and OFF turns on the informational messages.
            IF SET NOCOUNT OFF is not set at the begining of the stored procedure then all the informational messages will be sent over to the calling program. To get a slight performance gain turn them off. It is a really good practice to _SET NOCOUNT ON_ at the top of every stored procedure.
            
            _SET NOCOUNT OFF_ when testing or debugging.
            It is a good practise to enable the _SET NOCOUNT OFF_ at the end of the stored procedure.  
            
            ```
               ....
               SET NOCOUNT ON;
               ...
               ...
               
               SETNOCOUNT OFF;
            ```
   
   - Calling a Procedure from Another Procedure
   
      ```
         --//Calling a Procedure from Another Procedure
         USE Contacts;

         DROP PROCEDURE IF EXISTS dbo.SelectContact;

         GO

         CREATE PROCEDURE dbo.SelectContact
         (
            @ContactId INT
         )
         AS
         BEGIN;
         SET NOCOUNT ON;

            SELECT 
               FirstName
               ,LastName
               ,DateOfBirth
               ,AllowContactByPhone
               ,CreatedDate
            FROM Contacts
            WHERE ContactId = @ContactId

         SET NOCOUNT OFF;
         END;
         
         USE Contacts;

         GO
         
         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE = NULL,
            @AllowContactByPhone	BIT,
            @ContactId				INT OUTPUT
         )
         AS
         BEGIN;
         SET NOCOUNT ON;

            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);

            SELECT @ContactId = SCOPE_IDENTITY();
            --//Calling a Stored Procedure
            EXEC dbo.SelectContact @ContactId = @ContactId

         SET NOCOUNT OFF;

         END;         
         
      ```
            
   - Adding Business Logic
      
      - T-SQL support flow control statements
         - IF statement
         - WHILE loop
         
      - Stored procedures must always return the consistent output regardless of the control flow inside the procedure. This allows the calling program to handle the output.
      
      ```
         --// Adding Business Logic
         USE Contacts;

         GO

         CREATE OR ALTER PROCEDURE dbo.InsertContact
         (
            @FirstName				VARCHAR(40),
            @LastName				VARCHAR(40), 
            @DateOfBirth			DATE = NULL,
            @AllowContactByPhone	BIT,
            @ContactId				INT OUTPUT
         )
         AS
         BEGIN;
         SET NOCOUNT ON;

            IF NOT EXISTS(SELECT 1 FROM dbo.Contacts 
                        WHERE FirstName = @FirstName AND LastName = @LastName AND (DateOfBirth = @DateOfBirth OR @DateOfBirth IS NULL))
            BEGIN; 
            INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
               VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);
            END	;

            SELECT @ContactId = SCOPE_IDENTITY();
            --//Calling a Stored Procedure
            EXEC dbo.SelectContact @ContactId = @ContactId

         SET NOCOUNT OFF;

         END;
      ```      
   
   - Summary
      
      - Implementation options
      - Parameter-less stored procedure
      - Mandatory and Optional Parameters
      - Retrieving identity values
      - Nesting Stored Procedure
      
## Table Valued Parameters and Refactoring

- Introduction

   - Refactoring a Stored Procedure
   - Table-valued Type
   - Calling a Table-valued Type Stored Procedure
   - (Bad) Alternatives to Table-valued Types   

- Inheriting a Stored Procedure

   - Using a Cursor
      - Declare cursor
      - Open cursor
      - Try to obtain the first record
      - Check if record found
      - Process record if found
      - Obtain next record
      - Check if record found
      - Repeat until all records read
      - Close cursor
      - Deallocate cursor
   
   ```
      USE Contacts;

      DROP PROCEDURE IF EXISTS dbo.InsertContactNotes;

      GO

      --EXEC dbo.InsertContactNotes @ContactId = 22, @Notes = 'Note1,Note2,Note3'
      CREATE PROCEDURE dbo.InsertContactNotes
      (
         @ContactId		INT,
         @Notes			VARCHAR(MAX)
      )
      AS
      BEGIN;
      SET NOCOUNT ON;

      DECLARE @NoteTable TABLE(Note VARCHAR(MAX));
      DECLARE @NoteValue VARCHAR(MAX);

      INSERT INTO @NoteTable(Note)
      SELECT Value
         FROM STRING_SPLIT(@Notes,',');

      DECLARE NoteCursor CURSOR FOR
         SELECT Note FROM @NoteTable;

      OPEN NoteCursor
      FETCH NEXT FROM NoteCursor INTO @NoteValue;

      WHILE @@FETCH_STATUS = 0
      BEGIN;
         INSERT INTO dbo.ContactNotes(ContactId,Notes)
            VALUES(@ContactID,@NoteValue);

         FETCH NEXT FROM NoteCursor INTO @NoteValue;
      END;

      CLOSE NoteCursor;
      DEALLOCATE NoteCursor;

      SELECT ContactId,Notes FROM ContactNotes WHERE ContactId = @ContactID;

      SET NOCOUNT OFF;
      END;
   ```

- Alternatives to Cursors

   - While Loop (can perfor a little better that a cursor. It does not have the overhead of setting up and closing the cursor)
      ```
         --//Using WHILE Loop
            WHILE((SELECT COUNT(*) FROM @NoteTable) > 0)
            BEGIN;
               SELECT TOP 1 @NoteValue = Note FROM @NoteTable;

               INSERT INTO dbo.ContactNotes(ContactId,Notes)
                  VALUES(@ContactID,@NoteValue);

               DELETE FROM @NoteTable WHERE Note = @NoteValue;

            END;
      ```
   
   - SET-based logic.
      - Relational databases are designed to work with thousands of records at a time not on one record at a time.
      
      ```
         INSERT INTO dbo.ContactNotes(ContactId,Notes)
            SELECT @ContactId, Value
               FROM STRING_SPLIT(@Notes,',');
      ```
    
- User-defined Data Types
   
   - T-SQL Create Type Statement
      Use to create aliases for primitive types, or to create a custom data types.
      
      ```
         CREATE TYPE <name of type>
         FROM <base type>;
         
         Example:
            
            USE Contacts;
            GO

            CREATE TYPE dbo.DrivingLicense
            FROM CHAR(16) NOT NULL;

            DECLARE @DL DrivingLicense = 'ABCXYZ98743US140';

            SELECT @DL;
         
         CREATE TYPE<name of type>
         AS TABLE
         (  
            Column definations here...
         );
      ```
   - Custom Types exists within individual databases.
   - T-SQL Drop Type Statement
      - Use to drop types
      - Atype can only be dropped if no other objects depend on it
      `DROP TYPE IF EXISTS <name of type>; `
  
   - User-defined Table Types
      - User-defined table type is nothing more than a table variable. Because it is explicitly defined SQL Server allows it be used like any other datatype.
      - The type may contain as may columns as you want and you can insert as many rows as you want to it.
      - This gives a consistent way to passing data to stored procedures and also ensures the calling application simply needs to create a data table using the same structure, then pass the data table as a structured parameter to the stored procedure.
      - Table-valued Parameters (TVP).
         ```
            USE Contacts;

            DROP TYPE IF EXISTS dbo.ContactNote;

            GO

            CREATE TYPE dbo.ContactNote
            AS TABLE
            (
               Note VARCHAR(MAX) NOT NULL 
            );

         ```
            - You can index, constrain and define primary keys on TVP if you want.
            - TVP must be defined with READONLY Option.
            
               Data held in the TVP is stored in the SQL Servers TempDB. This meanse the data only needs to be held in only one pace. It is not explicitly passed into the stored procedure with TVP. Rather passed by reference.
               
               The data is stored in the TempDB and the reference is passed to the stored procedure and the data can be read from TempDB in the stored procedure.
               
               This is done to prevent the large sets of data from continually being created, which could have a negative impact on the system performance.
               A TVP could contain a lot of data, so you really don't want to create a multiple copies of that data.
      - Creating a Copy From READONLY
            The data in the READONLY table type cannot be modified Inserting the records into a different variable of the same type will support data modifications.
               
               ```
                  CREATE PROCEDURE dbo.InsertContactNotes
                  (@ContactId INT, @Notes ContactNote READONLY)
                  AS
                  BEGIN;
                  
                  DECLARE @NotesUpdate ContactNote;
                  
                  INSERT INTO @NotesUpdate(Note)
                     SELECT Note FROM @ContactNotes;
               ```
        ```
         --//Using TVP
         USE Contacts;

         DROP PROCEDURE IF EXISTS dbo.InsertContactNotes;

         GO

         CREATE PROCEDURE dbo.InsertContactNotes
         (
            @ContactId		INT,
            @Notes			ContactNote READONLY
         )
         AS
         BEGIN;
         SET NOCOUNT ON;

         INSERT INTO dbo.ContactNotes(ContactId,Notes)
            SELECT @ContactId, Note
               FROM @Notes;

         SELECT * FROM ContactNotes WHERE ContactId = @ContactID
            ORDER BY NoteId DESC;

         SET NOCOUNT OFF;
         END;
        ```
             

- Calling a Stored Procedure with Table-Valued Parameter

   ```
      DECLARE @TempNotes  ContactNote;

      INSERT INTO @TempNotes (Note)
      VALUES
      ('Hi, Peter Called.'),
      ('Quick note to let you know Jo knows you to ring her. She rang at 14:30'),
      ('Terri asked about the quote, I have asked her to ring back tomorrow.');

      EXEC dbo.InsertContactNotes
            @ContactId = 23,
            @Notes = @TempNotes;
   ```
   - Creating a Multi-column Type
      Including a ContactId column in the Table-Valued Type.
      
      ```
         USE Contacts;

         DROP TYPE IF EXISTS dbo.ContactNote;

         CREATE TYPE dbo.ContactNote
         AS TABLE
         (
            ContactId		INT,
            Note			VARCHAR(MAX) NOT NULL
         ); 
      ```  
   
- Summary
   
   - Passing multiple records - badly
   - Don't use cursore
   - While loops
   - Table-valued Parameters in stored procedures

## Debigging and Troubleshooting Stored Procedures

- Introduction
- The Print Statement
- Debugging with SQL Server Management Studio
- Handling Errors with Try/Catch
- Return Codes
- Handling Failed Transactions
- Defensive Coding
- Summary
