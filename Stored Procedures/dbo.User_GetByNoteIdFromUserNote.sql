SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[User_GetByNoteIdFromUserNote]
(

	@NoteId uniqueidentifier   
)
AS


SELECT dbo.[User].[UserID]
       ,dbo.[User].[Name]
       ,dbo.[User].[Password]
       ,dbo.[User].[Archived]
       ,dbo.[User].[Email]
       ,dbo.[User].[Location]
       ,dbo.[User].[FirstName]
       ,dbo.[User].[Surname]
       ,dbo.[User].[CustomerID]
       ,dbo.[User].[ExpiryDate]
  FROM dbo.[User]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[UserNote] 
                WHERE dbo.[UserNote].[NoteId] = @NoteId
                  AND dbo.[UserNote].[UserId] = dbo.[User].[UserID]
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			

GO
