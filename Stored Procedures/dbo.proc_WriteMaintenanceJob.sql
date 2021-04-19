SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_WriteMaintenanceJob]
(
	@vid UNIQUEIDENTIFIER,
	@engineerDateTime DATETIME NULL,
	@engineer NVARCHAR(100) NULL,
	@supportTicketId INT
)
AS
BEGIN

	DECLARE @result INT

	INSERT INTO dbo.MaintenanceJob
	        ( VehicleIntId ,
	          IVHIntId ,
	          CreationDateTime ,
	          EngineerDateTime ,
	          Engineer ,
	          SupportTicketId ,
	          ResolvedDateTime ,
	          Archived ,
	          LastOperation
	        )
	SELECT v.VehicleIntId, i.IVHIntId, GETUTCDATE(), @engineerDateTime, @engineer, @supportTicketId, NULL, 0, GETDATE()
	FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	WHERE v.VehicleId = @vid

	SET @result = SCOPE_IDENTITY()
	SELECT @result as MaintenanceJobId

END


	



GO
