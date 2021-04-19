SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the CFG_History table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_Delete]
(

	@HistoryId int   
)
AS


				    DELETE FROM [dbo].[CFG_History] WITH (ROWLOCK) 
				WHERE
					[HistoryId] = @HistoryId
					
			


GO
