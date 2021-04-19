SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_TAN_CheckIn]
(
	@userId UNIQUEIDENTIFIER,
	@vehicleId UNIQUEIDENTIFIER
)
AS
BEGIN

	UPDATE dbo.TAN_EntityCheckOut
	SET CheckInDateTime = GETUTCDATE(),
		CheckInUserId = @userId
	WHERE EntityId = @vehicleId
	  AND GETUTCDATE() BETWEEN CheckOutDateTime AND ISNULL(CheckInDateTime, '2099-21-31 00:00')

END

GO
