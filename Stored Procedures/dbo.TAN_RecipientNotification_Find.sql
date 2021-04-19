SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_RecipientNotification table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_Find]
(

	@SearchUsingOR bit   = null ,

	@NotificationTemplateId uniqueidentifier   = null ,

	@RecipientName varchar (200)  = null ,

	@RecipientAddress varchar (200)  = null ,

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
	, [RecipientName]
	, [RecipientAddress]
	, [Disabled]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_RecipientNotification]
    WHERE 
	 ([NotificationTemplateId] = @NotificationTemplateId OR @NotificationTemplateId IS NULL)
	AND ([RecipientName] = @RecipientName OR @RecipientName IS NULL)
	AND ([RecipientAddress] = @RecipientAddress OR @RecipientAddress IS NULL)
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
	, [RecipientName]
	, [RecipientAddress]
	, [Disabled]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_RecipientNotification]
    WHERE 
	 ([NotificationTemplateId] = @NotificationTemplateId AND @NotificationTemplateId is not null)
	OR ([RecipientName] = @RecipientName AND @RecipientName is not null)
	OR ([RecipientAddress] = @RecipientAddress AND @RecipientAddress is not null)
	OR ([Disabled] = @Disabled AND @Disabled is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Count] = @Count AND @Count is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
