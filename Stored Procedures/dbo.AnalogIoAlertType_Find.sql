SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the AnalogIoAlertType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[AnalogIoAlertType_Find]
(

	@SearchUsingOR bit   = null ,

	@AnalogIoAlertTypeId int   = null ,

	@Name varchar (50)  = null ,

	@Description varchar (MAX)  = null ,

	@LastModified datetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [AnalogIoAlertTypeId]
	, [Name]
	, [Description]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[AnalogIoAlertType]
    WHERE 
	 ([AnalogIoAlertTypeId] = @AnalogIoAlertTypeId OR @AnalogIoAlertTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [AnalogIoAlertTypeId]
	, [Name]
	, [Description]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[AnalogIoAlertType]
    WHERE 
	 ([AnalogIoAlertTypeId] = @AnalogIoAlertTypeId AND @AnalogIoAlertTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
