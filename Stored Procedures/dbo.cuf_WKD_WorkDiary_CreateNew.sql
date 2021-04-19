SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_WKD_WorkDiary_CreateNew]
(
	@did UNIQUEIDENTIFIER,
	@number NVARCHAR(20)
)
AS
	DECLARE @dintid INT,
			@workDiaryId INT
	
	SET @dintid = dbo.GetDriverIntFromId(@did)
	
	/*Do nothing if there is an active diary with the same number */		
	SELECT @workDiaryId = wd.WorkDiaryId
	FROM dbo.WKD_WorkDiary wd
	WHERE wd.Number = @number
		AND wd.DriverIntId = @dintid
		AND Archived = 0
		AND EndDate IS NULL
	
	IF @workDiaryId IS NULL
	BEGIN
		UPDATE dbo.WKD_WorkDiary
		SET EndDate = GETUTCDATE()
		WHERE DriverIntId = @dintid
			AND EndDate IS NULL
			AND Archived = 0
		
		
		
		INSERT INTO dbo.WKD_WorkDiary
				( DriverIntId ,
				  StartDate ,
				  Number ,
				  EndDate ,
				  Archived ,
				  LastOperation
				)
		VALUES  ( @dintid , -- DriverIntId - int
				  GETUTCDATE() , -- StartDate - datetime
				  @number , -- Number - varchar(20)
				  NULL , -- EndDate - datetime
				  0 , -- Archived - bit
				  GETDATE()  -- LastOperation - smalldatetime
				)
				
		SET @workDiaryId = SCOPE_IDENTITY()
	END
	
	RETURN @workDiaryId

GO
