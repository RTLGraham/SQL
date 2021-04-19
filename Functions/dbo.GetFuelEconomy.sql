SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2012-05-02 10:47:06.537>
-- Description:	<Calculates the fuel economy>
-- =============================================
CREATE FUNCTION [dbo].[GetFuelEconomy]
(
	@fuel FLOAT,
	@distance FLOAT,
	@fuelmult FLOAT,
	@vehicleFuelmult FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @result FLOAT
	
	SET @result =
		CASE WHEN @fuelmult = 0.1 THEN
			SUM(@fuel * ISNULL(@vehicleFuelmult,1.0) * 100) / dbo.ZeroYieldNull(SUM(@distance))
		ELSE
			(SUM(@distance) * 1000) / dbo.ZeroYieldNull(SUM(@fuel * ISNULL(@vehicleFuelmult,1.0)) * @fuelmult) END
	
	RETURN @result
END

GO
