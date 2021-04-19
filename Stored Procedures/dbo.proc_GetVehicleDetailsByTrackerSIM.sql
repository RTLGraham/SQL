SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetVehicleDetailsByTrackerSIM]
(
	@ids varchar(max)
)
AS
	--DECLARE @ids varchar(max)
	--set @ids = '89185015061600483976,89185015061600425381,89185015061600483927,89185015061600483984,89185015061600483844,89185000180221119202,89185015061600424012,89185015061600483851,89185015061600483943,89185015061600425373,89185000170427690189,89185015061600483968,89185015061600483950,89185015061600483919,89185015061600483935,89185015061600425365,891850001711097748161'


--query trackers by SIM card number
SELECT c.Name as Customer
      ,v.Registration
      ,i.[SIMCardNumber]
	  ,i.[TrackerNumber] 
	  ,t.Name as TrackerType
	  ,le.EventDateTime as LastOperation
	  ,le.Lat
	  ,le.Long
      ,i.[Archived] as DeviceArchived
      ,v.[Archived] as VehicleArchived
FROM [dbo].[IVH] i
inner join [dbo].[Vehicle] v on v.IVHId = i.IVHId
inner join [dbo].[IVHType] t on t.IVHTypeId = i.ivhtypeid
left join [dbo].[VehicleLatestEvent] le on le.VehicleId = v.VehicleId 
inner join [dbo].[customervehicle] cv on cv.vehicleid = v.vehicleid
inner join [dbo].[customer] c on c.customerid = cv.customerid
where (i.SIMCardNumber IN (SELECT Value FROM dbo.Split(@ids, ',')))

GO
