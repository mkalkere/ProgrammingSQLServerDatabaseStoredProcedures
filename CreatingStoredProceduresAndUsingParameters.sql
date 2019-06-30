USE Contacts;

GO
--//Creating a Stored Procedure
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

--//Adding Parameters to Stored Procedures
GO

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

GO

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

GO

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



--// Output Parameter
GO

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
	
	SELECT ContactId,FirstName,LastName,DateOfBirth,AllowContactByPhone
		FROM dbo.Contacts
	WHERE ContactId = @ContactId;

SET NOCOUNT OFF;
END;

--// Adding Business Logic
GO

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
SET NOCOUNT ON; --//Turn OFF informational messages
	
	--//Check if the contact Already Exists
	IF NOT EXISTS(SELECT 1 FROM dbo.Contacts 
					WHERE FirstName = @FirstName AND LastName = @LastName AND (DateOfBirth = @DateOfBirth OR @DateOfBirth IS NULL))
	BEGIN; 
	INSERT INTO dbo.Contacts (FirstName,LastName,DateOfBirth,AllowContactByPhone)
		VALUES (@FirstName,@LastName,@DateOfBirth,@AllowContactByPhone);
	END	;

	SELECT @ContactId = SCOPE_IDENTITY();
	--//Calling a Stored Procedure
	EXEC dbo.SelectContact @ContactId = @ContactId --//Consistent Output

SET NOCOUNT OFF;--//Turn ON informational messages
END;
