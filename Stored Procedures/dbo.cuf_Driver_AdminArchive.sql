SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_AdminArchive]
(
	@driverId UNIQUEIDENTIFIER
)
AS
BEGIN
	BEGIN TRAN
	
	UPDATE dbo.Driver
	SET Archived = 1,
		LastOperation = GETDATE()
	WHERE DriverId = @driverId
	
	UPDATE dbo.CustomerDriver
	SET Archived = 1,
		EndDate = GETDATE()
	WHERE DriverId = @driverId
	
	COMMIT TRAN
END


GO
