SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Indicator_GetSafetyWeights]
AS
BEGIN
	SELECT
		dbo.[IndWeight](7) * 100 AS EngineServiceBrake,
		dbo.[IndWeight](8) * 100 AS OverRevWithoutFuel,
		dbo.[IndWeight](9) * 100 AS Rop,
		dbo.[IndWeight](10) * 100 AS OverSpeed,
		dbo.[IndWeight](11) * 100 AS CoastOutOfGear,
		dbo.[IndWeight](12) * 100 AS HarshBraking	
END

GO
