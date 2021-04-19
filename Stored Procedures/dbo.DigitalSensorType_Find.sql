SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the DigitalSensorType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DigitalSensorType_Find]
(

	@SearchUsingOR bit   = null ,

	@DigitalSensorTypeId smallint   = null ,

	@Name nvarchar (254)  = null ,

	@Description nvarchar (MAX)  = null ,

	@OnDescription nvarchar (MAX)  = null ,

	@OffDescription nvarchar (MAX)  = null ,

	@IconLocation nvarchar (MAX)  = null ,

	@LastOperation smalldatetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [DigitalSensorTypeId]
	, [Name]
	, [Description]
	, [OnDescription]
	, [OffDescription]
	, [IconLocation]
	, [LastOperation]
	, [Archived]
    FROM
	[dbo].[DigitalSensorType]
    WHERE 
	 ([DigitalSensorTypeId] = @DigitalSensorTypeId OR @DigitalSensorTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([OnDescription] = @OnDescription OR @OnDescription IS NULL)
	AND ([OffDescription] = @OffDescription OR @OffDescription IS NULL)
	AND ([IconLocation] = @IconLocation OR @IconLocation IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [DigitalSensorTypeId]
	, [Name]
	, [Description]
	, [OnDescription]
	, [OffDescription]
	, [IconLocation]
	, [LastOperation]
	, [Archived]
    FROM
	[dbo].[DigitalSensorType]
    WHERE 
	 ([DigitalSensorTypeId] = @DigitalSensorTypeId AND @DigitalSensorTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([OnDescription] = @OnDescription AND @OnDescription is not null)
	OR ([OffDescription] = @OffDescription AND @OffDescription is not null)
	OR ([IconLocation] = @IconLocation AND @IconLocation is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
