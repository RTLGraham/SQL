SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetNavteqAddressFromLongLat] 
( 
	@lat FLOAT, 
	@lon FLOAT 
)
RETURNS NVARCHAR(MAX)
AS BEGIN 
	
	RETURN NULL
	-- To be used to call API to obtain the address (if required)

    --DECLARE @address NVARCHAR(MAX)
    
    --SELECT TOP 1 @address = StreetName
    --FROM UK_Skynet_Data.dbo.RevGeocodeSpeeding
    --WHERE Lat = @lat AND Long = @lon AND Archived = 0
    --ORDER BY RevGeocodeSpeedingId DESC
    
    --RETURN @address
   END

GO
