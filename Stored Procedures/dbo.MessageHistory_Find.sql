SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the MessageHistory table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageHistory_Find]
(

	@SearchUsingOR bit   = null ,

	@MessageId int   = null ,

	@MessageText nvarchar (1024)  = null ,

	@Lat float   = null ,

	@SafeNameLong float   = null ,

	@ReverseGeocode nvarchar (255)  = null ,

	@Date datetime   = null ,

	@LastModified datetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [MessageId]
	, [MessageText]
	, [Lat]
	, [Long]
	, [ReverseGeocode]
	, [Date]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[MessageHistory]
    WHERE 
	 ([MessageId] = @MessageId OR @MessageId IS NULL)
	AND ([MessageText] = @MessageText OR @MessageText IS NULL)
	AND ([Lat] = @Lat OR @Lat IS NULL)
	AND ([Long] = @SafeNameLong OR @SafeNameLong IS NULL)
	AND ([ReverseGeocode] = @ReverseGeocode OR @ReverseGeocode IS NULL)
	AND ([Date] = @Date OR @Date IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [MessageId]
	, [MessageText]
	, [Lat]
	, [Long]
	, [ReverseGeocode]
	, [Date]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[MessageHistory]
    WHERE 
	 ([MessageId] = @MessageId AND @MessageId is not null)
	OR ([MessageText] = @MessageText AND @MessageText is not null)
	OR ([Lat] = @Lat AND @Lat is not null)
	OR ([Long] = @SafeNameLong AND @SafeNameLong is not null)
	OR ([ReverseGeocode] = @ReverseGeocode AND @ReverseGeocode is not null)
	OR ([Date] = @Date AND @Date is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
