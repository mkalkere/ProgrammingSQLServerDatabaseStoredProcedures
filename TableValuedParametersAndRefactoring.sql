--//Table Valued Parameters and Refactoring

--//Using Cursore

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

--//Using WHILE Loop
WHILE((SELECT COUNT(*) FROM @NoteTable) > 0)
BEGIN;
	SELECT TOP 1 @NoteValue = Note FROM @NoteTable;

	INSERT INTO dbo.ContactNotes(ContactId,Notes)
		VALUES(@ContactID,@NoteValue);

	DELETE FROM @NoteTable WHERE Note = @NoteValue;

END;

--//SET-based 
INSERT INTO dbo.ContactNotes(ContactId,Notes)
	SELECT @ContactId, Value
		FROM STRING_SPLIT(@Notes,',');

--//User Defined Data Type
GO

USE Contacts;

GO

CREATE TYPE dbo.DrivingLicense
FROM CHAR(16) NOT NULL;

DECLARE @DL DrivingLicense = 'ABCXYZ98743US140';

SELECT @DL;

--// Table-valued Parameters (TVP).
GO
USE Contacts;

DROP TYPE IF EXISTS dbo.ContactNote;

GO

CREATE TYPE dbo.ContactNote
AS TABLE
(
    Note VARCHAR(MAX) NOT NULL 
);

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

--//Creating a Multi-column Type;
GO

USE Contacts;

DROP TYPE IF EXISTS dbo.ContactNote;

CREATE TYPE dbo.ContactNote
AS TABLE
(
	ContactId		INT,
	Note			VARCHAR(MAX) NOT NULL
);
