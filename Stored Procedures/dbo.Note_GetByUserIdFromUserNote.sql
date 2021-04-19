SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets records through a junction table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_GetByUserIdFromUserNote]
(

	@UserId uniqueidentifier   
)
AS


SELECT dbo.[Note].[NoteId]
       ,dbo.[Note].[NoteEntityId]
       ,dbo.[Note].[NoteTypeId]
       ,dbo.[Note].[Note]
       ,dbo.[Note].[NoteDate]
       ,dbo.[Note].[LastModified]
       ,dbo.[Note].[Archived]
  FROM dbo.[Note]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[UserNote] 
                WHERE dbo.[UserNote].[UserId] = @UserId
                  AND dbo.[UserNote].[NoteId] = dbo.[Note].[NoteId]
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			
				


GO
