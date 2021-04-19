SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetReverseGeoCode]
(
	@lat float,
	@lon float
)
AS
--DECLARE @lat float
--DECLARE @lon float

--SET @lat = 53.4141890
--SET @lon = -2.066358

SELECT dbo.[GetAddressFromLongLat] (@lat, @lon ) AS ReverseGeoCode
--SELECT 'ADDRESS UNKNOWN' AS ReverseGeoCode

GO
