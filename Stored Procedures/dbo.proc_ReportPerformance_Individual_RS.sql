SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportPerformance_Individual_RS]
(
	@assetId UNIQUEIDENTIFIER, 
	@assetType INT,
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@isFlexible BIT
) 
AS
--DECLARE @entityId UNIQUEIDENTIFIER, 
--		@typeid INT,
--		@depid INT,
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@flexible BIT


--SET @uid = 'fd7bb89a-a486-438e-bf85-0e199e8bd243'
--SET @sdate = '2011-06-06 15:59:33'
--SET @edate = '2011-07-10 15:59:33'
--SET @entityId = N'a5d5bc6c-15d8-4df5-9b21-1aa173f32b64'
--SET @rprtcfgid = N'3fed49aa-15c3-4875-a980-d252a6daef80'
--SET @flexible = 0
--SET @typeid = 2

IF @assetType = 1 AND @isflexible = 0
	EXEC proc_ReportPerformance_Individual_Vehicle_RS @assetId, @sdate, @edate, @uid, @configid
ELSE IF @assetType = 1 AND @isflexible = 1
	EXEC proc_ReportPerformance_Individual_Vehicle_Flex_RS @assetId, @sdate, @edate, @uid, @configid
ELSE IF @assetType = 2 AND @isflexible = 0
	EXEC proc_ReportPerformance_Individual_Driver_RS @assetId, @sdate, @edate, @uid, @configid
ELSE IF @assetType = 2 AND @isflexible = 1
	EXEC proc_ReportPerformance_Individual_Driver_Flex_RS @assetId, @sdate, @edate, @uid, @configid
	




/*
{fd7bb89a-a486-438e-bf85-0e199e8bd243}
{06/06/2011 15:59:33}
{10/07/2011 15:59:33}
{a5d5bc6c-15d8-4df5-9b21-1aa173f32b64}
{3fed49aa-15c3-4875-a980-d252a6daef80}
false
*/

GO
