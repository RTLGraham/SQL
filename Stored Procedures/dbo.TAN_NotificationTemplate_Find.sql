SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_NotificationTemplate table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_NotificationTemplate_Find]
(

	@SearchUsingOR bit   = null ,

	@NotificationTemplateId uniqueidentifier   = null ,

	@TriggerId uniqueidentifier   = null ,

	@NotificationTypeId int   = null ,

	@Header nvarchar (MAX)  = null ,

	@Body varchar (2000)  = null ,

	@Disabled bit   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null ,

	@Count bigint   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [NotificationTemplateId]
	, [TriggerId]
	, [NotificationTypeId]
	, [Header]
	, [Body]
	, [Disabled]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_NotificationTemplate]
    WHERE 
	 ([NotificationTemplateId] = @NotificationTemplateId OR @NotificationTemplateId IS NULL)
	AND ([TriggerId] = @TriggerId OR @TriggerId IS NULL)
	AND ([NotificationTypeId] = @NotificationTypeId OR @NotificationTypeId IS NULL)
	AND ([Header] = @Header OR @Header IS NULL)
	AND ([Body] = @Body OR @Body IS NULL)
	AND ([Disabled] = @Disabled OR @Disabled IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Count] = @Count OR @Count IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [NotificationTemplateId]
	, [TriggerId]
	, [NotificationTypeId]
	, [Header]
	, [Body]
	, [Disabled]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_NotificationTemplate]
    WHERE 
	 ([NotificationTemplateId] = @NotificationTemplateId AND @NotificationTemplateId is not null)
	OR ([TriggerId] = @TriggerId AND @TriggerId is not null)
	OR ([NotificationTypeId] = @NotificationTypeId AND @NotificationTypeId is not null)
	OR ([Header] = @Header AND @Header is not null)
	OR ([Body] = @Body AND @Body is not null)
	OR ([Disabled] = @Disabled AND @Disabled is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Count] = @Count AND @Count is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
