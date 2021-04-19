SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_GetReleaseNote]
(
	@ReleaseNoteId INT
)
AS 
	
	SELECT TOP 1
		  ReleaseNoteId,
          AssemblyVersion ,
          Name ,
          Description ,
          ReleaseDate ,
          FileExtension,
          FilePayload
	FROM dbo.ReleaseNote
	WHERE ReleaseNoteId = @ReleaseNoteId
		AND Archived = 0

GO
