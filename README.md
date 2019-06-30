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
      
      
