SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_GetLatLongFromPostcode] @pcode varchar(50)
AS
SELECT dbo.GetLatFromPostcode(@pcode) AS Lat, dbo.GetLongFromPostcode(@pcode) AS Long

GO
