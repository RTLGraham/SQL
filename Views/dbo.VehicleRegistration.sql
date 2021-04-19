SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[VehicleRegistration]
AS
SELECT  VehicleIntId, 
		Registration, 
		CASE WHEN CHARINDEX('(', Registration) = 0 THEN NULL ELSE 
			CASE WHEN CHARINDEX('(', Registration) = 1 THEN '' ELSE SUBSTRING(Registration, 1, CHARINDEX('(', Registration)-2) END END AS Reg,
		CASE WHEN CHARINDEX('(', Registration) = 0 THEN NULL ELSE SUBSTRING(Registration, CHARINDEX('(', Registration)+1, (CHARINDEX(')', Registration)-CHARINDEX('(', Registration))-1) END AS FleetNum,
		CASE WHEN CHARINDEX('(', Registration) = 0 THEN NULL ELSE 
			CASE WHEN CHARINDEX(')', Registration) = LEN(Registration) THEN '' ELSE RIGHT(Registration, LEN(Registration)-CHARINDEX(')', Registration)-1) END END AS Final
FROM dbo.Vehicle

GO
