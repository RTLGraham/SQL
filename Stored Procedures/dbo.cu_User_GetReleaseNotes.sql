SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_GetReleaseNotes]
AS 
	
	SELECT 
		  ReleaseNoteId,
          AssemblyVersion ,
          Name ,
          Description ,
          ReleaseDate ,
          CASE WHEN FilePayload IS NOT NULL THEN 1 ELSE 0 END AS IsFileAvailable
	FROM dbo.ReleaseNote
	WHERE Archived = 0
	ORDER BY ReleaseDate DESC


GO
