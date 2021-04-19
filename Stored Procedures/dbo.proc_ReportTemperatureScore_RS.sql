SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportTemperatureScore_RS]
(
	@vids NVARCHAR(MAX) = NULL,
	@gids NVARCHAR(MAX) = NULL,
	@sdate DATETIME,
	@edate DATETIME,
	@sensorid SMALLINT = NULL,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vids NVARCHAR(MAX),
--		@gids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@sensorid SMALLINT,
--		@uid UNIQUEIDENTIFIER

----SET @vids = NULL;
--SET @vids = N'5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461,BD5F9889-8007-4943-9001-46CB3ED2D36F,4DA5FA6D-8496-4D75-AA6A-4C32B377BDF9,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,BD15D85F-F591-4AB5-881A-65E296715D18,33A67A70-9935-4214-B7B0-69B7AC228F5C,46F9F76A-1324-474B-B0BD-6E160C3E8ACD,EB5F8AE0-FC95-4D38-87FE-801C22911CA6,2D68CB77-FE15-4030-839A-824B6D0806BA,9A615ECD-2389-4D20-B0BE-8667626A38BA,CF6E7729-C9E7-4373-BEAB-895D9A2F1379,8288801A-186F-4BE4-A044-8A4007BD2372,0BBEF81F-92A9-4183-A354-8B15F4B354DD,AE9AD52F-7659-4339-BB56-A39AC3923A54,DF0D3E78-19EB-4779-BAE8-A974FE4F1B33,F5F18987-540E-44A0-A9EB-BC42699EFA30,2E7A5E82-702A-4003-BB17-C072A93ED941,18750389-36C6-4D3E-BE79-C54B859CE83B,2C63EBDD-07D4-4F26-A3A4-C5E18DBCB5CF,0A293ED6-5DE5-4B92-BDF0-C8357DF9003D,D103A123-A2A2-4EF1-97DF-D184E971FE7B,C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,3AAEA81D-20C4-4F24-B022-DECA9C7C51B1,5081472D-203E-4F21-9CF8-E1F98619361A';
--SET @gids = N'B04062C4-67FA-41A9-9BFC-4776782653B4';
--SET @sdate = '2013-07-26 00:00';
--SET @edate = '2013-07-26 23:59';
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5';

-- 20/07/16 gp/as Added OverTemp2duration and OverTemp3duration

          DECLARE   @Results TABLE (
                    GroupName                   nvarchar(MAX),
                    Registration                nvarchar(MAX),
                    OutsideTime                 float,
                    OverTempDuration            float,
					OverTemp2Duration           float,
					OverTemp3Duration           float,
                    Confirmed                   int,
                    NonConfirmed                int,
                    AvgProductTempInside        float,
                    AvgProductTempOutside       float,
                    AvgExternalTempOutside      float,
                    DefrostCount                float,
                    FleetAvgPcTime              float,
                    FleetAvgProductTempInside   float,
                    FleetAvgProductTempOutside  float,
                    FleetAvgExternalTempOutside float,
                    FleetDefrostCount           float
          );

          DECLARE   @GroupAverages TABLE (
                    GroupName              nvarchar(MAX),
                    GroupAvgPcTime         float,
                    AvgProductTempInside   float,
                    AvgProductTempOutside  float,
                    AvgExternalTempOutside float,
                    DefrostCount           float
          );

          INSERT    @Results(GroupName, Registration, OutsideTime, OverTempDuration, OverTemp2Duration, OverTemp3Duration, Confirmed, NonConfirmed,
                    AvgProductTempInside, AvgProductTempOutside, AvgExternalTempOutside, DefrostCount)
          EXEC      proc_ReportTemperatureScore @vids, @gids, @sdate, @edate, @sensorid, @uid;

          INSERT    @GroupAverages(GroupName, GroupAvgPcTime, AvgProductTempInside, AvgProductTempOutside, AvgExternalTempOutside, DefrostCount)
          SELECT    GroupName, SUM(OverTempDuration)/dbo.ZeroYieldNull(SUM(OutsideTime)), AVG(AvgProductTempInside),
                    AVG(AvgProductTempOutside), AVG(AvgExternalTempOutside), AVG(DefrostCount)
          FROM      @Results
          GROUP BY  GroupName;

          UPDATE    @Results
          SET       FleetAvgPcTime = (SELECT AVG(GroupAvgPcTime) FROM @GroupAverages),
                    FleetAvgProductTempInside = (SELECT AVG(AvgProductTempInside) FROM @GroupAverages),
                    FleetAvgProductTempOutside = (SELECT AVG(AvgProductTempOutside) FROM @GroupAverages),
                    FleetAvgExternalTempOutside = (SELECT AVG(AvgExternalTempOutside) FROM @GroupAverages),
                    FleetDefrostCount = (SELECT AVG(DefrostCount) FROM @GroupAverages);

          SELECT    GroupName, Registration, OutsideTime, OverTempDuration, OverTemp2Duration, OverTemp3Duration, Confirmed, NonConfirmed,
                    AvgProductTempInside, 
                    ISNULL(AvgProductTempOutside, 0) AS AvgProductTempOutside, 
                    ISNULL(AvgExternalTempOutside, 0) AS AvgExternalTempOutside, 
                    DefrostCount,
                    FleetAvgPcTime, FleetAvgProductTempInside, FleetAvgProductTempOutside, FleetAvgExternalTempOutside, FleetDefrostCount
          FROM      @Results;
          
GO
