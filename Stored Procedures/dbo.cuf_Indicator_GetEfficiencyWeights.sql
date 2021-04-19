SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Indicator_GetEfficiencyWeights]
AS
BEGIN
	SELECT 
		dbo.[IndWeight](1) * 100 AS SweetSpotWeight,
		dbo.[IndWeight](2) * 100 AS OverRevWithFuelWeight,
		dbo.[IndWeight](3) * 100 AS TopGearWeight,
		dbo.[IndWeight](4) * 100 AS CruiseWeight,
		dbo.[IndWeight](5) * 100 AS CoastInGearWeight,
		dbo.[IndWeight](6) * 100 AS IdleWeight
END

GO
