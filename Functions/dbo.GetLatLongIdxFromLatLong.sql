SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[GetLatLongIdxFromLatLong] (@lat float, @long float)
RETURNS bigint AS  
BEGIN 
DECLARE @revgeocodeid int
DECLARE @latlongidx bigint
DECLARE @cmd varchar(400)

SET @latlongidx = (floor(@lat * 1000) + 90000)*1000000 + floor(@long * 1000) + 180000

RETURN @latlongidx
END

GO
