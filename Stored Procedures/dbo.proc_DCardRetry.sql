SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_DCardRetry]
@FileName VARCHAR(500)
AS
BEGIN

DECLARE @IVHIntId INT
DECLARE @TrackerNumber VARCHAR(50)

SELECT @TrackerNumber = [value] FROM dbo.Split(@FileName,'_') WHERE Id = 1

IF Len(@TrackerNumber) > 1
BEGIN

	SELECT @IVHIntId = IVHIntId FROM IVH WHERE TrackerNumber = @TrackerNumber AND Archived = 0

	IF @IVHIntId IS NOT NULL
	BEGIN

		INSERT INTO Command
				   (IVHIntId
				   ,Command
				   ,ExpiryDate
				   ,LastOperation
				   ,Archived)
		VALUES
		(
			@IVHIntId,
		CAST(
		'#FTP,DCARD,' + @FileName  
		AS BINARY(1024)) 	,
			DATEADD(hh, 24, GETDATE()),
			GETDATE(),
			0
		)
	END
		
END

END

GO
