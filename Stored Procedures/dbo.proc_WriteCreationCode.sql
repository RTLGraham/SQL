SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteCreationCode]
	@oldccid smallint = NULL, @ccid smallint = NULL, @ccname varchar(50), @ccdesc varchar(100)
AS
IF @oldccid IS NULL
BEGIN
	INSERT INTO CreationCode	(CreationCodeId, Name, Description)
	VALUES			(@ccid, @ccname, @ccdesc)
END
ELSE
BEGIN
	UPDATE CreationCode SET CreationCodeId = @ccid, Name = @ccname, Description = @ccdesc
	WHERE CreationCodeId = @oldccid
END

GO
