SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_SetTripBusinessPrivate]
(
	@DriverTripId BIGINT,
	@IsBusiness BIT,
	@Comment NVARCHAR(MAX) = NULL
)
AS
BEGIN
	UPDATE dbo.DriverTrip
	SET IsBusiness = @IsBusiness, Comment = @Comment
	WHERE DriverTripId = @DriverTripId
END


GO
