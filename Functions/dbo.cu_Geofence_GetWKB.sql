SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[cu_Geofence_GetWKB]( @wkt nvarchar(max), @srid int = -1 )
RETURNS varbinary(max) AS
BEGIN
	RETURN ST.GeomCollFromText( @wkt, @srid )
END

GO
