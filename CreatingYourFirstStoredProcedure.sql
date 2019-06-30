USE [Contacts]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [dbo].[SelectContacts]
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'dbo.SelectContacts')
BEGIN;
	DROP PROCEDURE dbo.SelectContacts
END;

GO
 CREATE OR ALTER PROCEDURE [dbo].[SelectContacts]
 AS
 BEGIN;--//SP BEGIN

 SELECT * FROM dbo.Contacts --/WHERE FirstName = 'Grace';

 END--//SP END
GO

EXEC dbo.SelectContacts
