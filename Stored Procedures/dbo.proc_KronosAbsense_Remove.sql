SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_KronosAbsense_Remove]
(
	@kronosAbsenseId INT
)
AS
	SET NOCOUNT ON;

	UPDATE dbo.KronosAbsense
	SET Archived = 1
	WHERE KronosAbsenseId = @kronosAbsenseId


GO
