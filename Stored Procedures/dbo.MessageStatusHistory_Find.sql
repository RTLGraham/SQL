SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the MessageStatusHistory table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_Find]
(

	@SearchUsingOR bit   = null ,

	@MessageStatusHistoryId int   = null ,

	@MessageId int   = null ,

	@MessageStatusId int   = null ,

	@LastModified datetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [MessageStatusHistoryId]
	, [MessageId]
	, [MessageStatusId]
	, [LastModified]
    FROM
	[dbo].[MessageStatusHistory]
    WHERE 
	 ([MessageStatusHistoryId] = @MessageStatusHistoryId OR @MessageStatusHistoryId IS NULL)
	AND ([MessageId] = @MessageId OR @MessageId IS NULL)
	AND ([MessageStatusId] = @MessageStatusId OR @MessageStatusId IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [MessageStatusHistoryId]
	, [MessageId]
	, [MessageStatusId]
	, [LastModified]
    FROM
	[dbo].[MessageStatusHistory]
    WHERE 
	 ([MessageStatusHistoryId] = @MessageStatusHistoryId AND @MessageStatusHistoryId is not null)
	OR ([MessageId] = @MessageId AND @MessageId is not null)
	OR ([MessageStatusId] = @MessageStatusId AND @MessageStatusId is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
