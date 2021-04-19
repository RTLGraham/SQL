SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_WarehouseTemperatures]
(
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vid UNIQUEIDENTIFIER,
--    @sdate DATETIME,
--    @edate DATETIME,
--    @uid uniqueidentifier

--SET @VehicleId = N'A1313AC0-572F-4673-B0FD-9BF30D487AD7'
--SET @sdate = '2014-01-20 00:00'
--SET @edate = '2014-01-20 23:59'
--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'

EXECUTE dbo.[proc_ReportWarehouseTemperatures]
	@vid,
	@sdate,
	@edate,
	@uid

GO
