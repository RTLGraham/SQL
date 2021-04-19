SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cuf_Driver_SetMileageClaimBusinessPrivate]
(
	@DriverTripId BIGINT,
	@IsBusiness BIT,
	@Comment NVARCHAR(MAX) = NULL
)
AS
BEGIN

	DECLARE @tripsandstopsid BIGINT	

	-- First determine if an entry exists in the TripsASndStopsWorkPlay table
	SELECT @tripsandstopsid = TripsAndStopsId
	FROM dbo.TripsAndStopsWorkPlay
	WHERE TripsAndStopsId = @DriverTripId

	-- If entry does not exist create it
	IF @tripsandstopsid IS NULL
		INSERT INTO dbo.TripsAndStopsWorkPlay (TripsAndStopsId, PlayInd, Comment)
		VALUES  (@DriverTripId, CASE WHEN @IsBusiness = 0 THEN 1 ELSE 0 END, @Comment)
	ELSE
		UPDATE dbo.TripsAndStopsWorkPlay
		SET PlayInd = CASE WHEN @IsBusiness = 0 THEN 1 ELSE 0 END, Comment = @Comment
		WHERE TripsAndStopsId = @tripsandstopsid

END	


GO
