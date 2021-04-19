SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the HardwareType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[HardwareType_Find]
(

	@SearchUsingOR bit   = null ,

	@HardwareTypeId int   = null ,

	@Name nvarchar (255)  = null ,

	@Description nvarchar (MAX)  = null ,

	@HardwareSupplierId int   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [HardwareTypeId]
	, [Name]
	, [Description]
	, [HardwareSupplierId]
	, [Archived]
    FROM
	[dbo].[HardwareType]
    WHERE 
	 ([HardwareTypeId] = @HardwareTypeId OR @HardwareTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([HardwareSupplierId] = @HardwareSupplierId OR @HardwareSupplierId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [HardwareTypeId]
	, [Name]
	, [Description]
	, [HardwareSupplierId]
	, [Archived]
    FROM
	[dbo].[HardwareType]
    WHERE 
	 ([HardwareTypeId] = @HardwareTypeId AND @HardwareTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([HardwareSupplierId] = @HardwareSupplierId AND @HardwareSupplierId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
