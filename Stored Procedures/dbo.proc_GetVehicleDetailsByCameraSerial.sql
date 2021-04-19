SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetVehicleDetailsByCameraSerial]
(
	@ids varchar(max)
)
AS
	--DECLARE @ids varchar(max)
	--set @ids = '22003320,22223224,22217526,22208934,22208262,22204561,22210066,22217954,22214302,22223224,22006948,22217557,22232082,22201723'


--query cameras by camera serial No.
SELECT distinct c.Name as Customer
      ,v.Registration
	  ,ca.Serial as CameraSerial
	  ,p.Project
	  ,p.ApiUser
	  ,ca.LastOperation
      ,ca.[Archived] as DeviceArchived
      ,v.[Archived] as VehicleArchived
FROM [dbo].[Camera] ca
inner join [dbo].[VehicleCamera] vc on vc.CameraId = ca.CameraId
inner join [dbo].[Vehicle] v on v.VehicleId = vc.VehicleId
inner join [dbo].[customervehicle] cv on cv.vehicleid = v.vehicleid
inner join [dbo].[customer] c on c.customerid = cv.customerid
inner join [dbo].[Project] p on p.projectid = ca.projectid
where (ca.Serial IN (SELECT Value FROM dbo.Split(@ids, ',')))
order by ca.serial


SET ANSI_NULLS ON

GO
