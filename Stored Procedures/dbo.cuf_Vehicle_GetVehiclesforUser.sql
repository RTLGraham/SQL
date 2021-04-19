SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehiclesforUser] (
	@userid uniqueidentifier
)
AS
--set @userid = N'DD14EDCF-56C1-4751-8FDE-F4B17CBB9326'

declare @vehicleids table (vehicleid uniqueidentifier)

insert into @vehicleids
select v.vehicleid
from dbo.[user] u
inner join dbo.[usergroup] ug on u.userid = ug.userid
left join dbo.[group] grp on ug.groupid = grp.groupid
left join dbo.[groupdetail] gd on ug.groupid = gd.groupid
left join [dbo].[Vehicle] v on gd.entitydataid = v.vehicleid
where u.userid = @userid
and grp.grouptypeid = 1

declare @vehid uniqueidentifier

declare Vehicle_cur cursor fast_forward read_only for select * from @vehicleids
open Vehicle_cur
fetch next from Vehicle_cur into @vehid
while @@fetch_status = 0
begin
	exec [dbo].[cuf_Vehicle_GetVehicleDetails] @vehicleid = @vehid, @date = null

	fetch next from Vehicle_cur into @vehid
end
close Vehicle_cur
deallocate Vehicle_cur

GO
