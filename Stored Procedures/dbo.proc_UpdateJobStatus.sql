SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_UpdateJobStatus]
	@Id INT,
	@Status TINYINT
AS
BEGIN
	SET NOCOUNT OFF

	UPDATE dbo.VehicleJob
	SET StatusInd = @Status, ResponseDate = GETDATE()
	WHERE VehicleJobId = @Id

END



GO
