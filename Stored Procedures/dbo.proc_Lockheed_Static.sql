SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Lockheed_Static]
AS
BEGIN
	SELECT  Id,
			Location ,
			Name ,
			Address ,
			State ,
			Country ,
			Zip ,
			Lat ,
			Lon ,
			Quantity ,
			PartNo
	FROM Test_Database.dbo.LockheedStatic
	ORDER BY Id ASC
END

GO
