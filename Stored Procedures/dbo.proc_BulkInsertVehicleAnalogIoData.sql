SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_BulkInsertVehicleAnalogIoData]
AS


INSERT INTO VehicleAnalogIoData SELECT * FROM dbo.VehicleAnalogIoDataTemp WHERE Archived = 0



GO
