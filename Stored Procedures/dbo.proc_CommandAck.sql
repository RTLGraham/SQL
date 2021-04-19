SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_CommandAck] 
	@commandid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE VehicleCommand
	SET AcknowledgedDate = GetDate()
	WHERE VehicleCommand.CommandId = @commandid
END

GO
