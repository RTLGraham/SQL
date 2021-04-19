SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Artem Bessonov
-- Create date: 15-02-2021
-- Description:	Get Vehicle Types
-- =============================================
CREATE PROCEDURE [dbo].[proc_GetVehicleTypes]
AS
BEGIN
	SELECT [VehicleTypeID]
      ,[Number]
      ,[Name]
  FROM dbo.[VehicleType] WHERE Archived = 0
END

GO
