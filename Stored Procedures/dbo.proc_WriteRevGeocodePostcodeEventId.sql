SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROC [dbo].[proc_WriteRevGeocodePostcodeEventId] @revgeocodeid int, @pcode varchar(50) = NULL
AS
	UPDATE RevGeocode SET Postcode = @pcode WHERE RevGeocodeId = @revgeocodeid

GO
