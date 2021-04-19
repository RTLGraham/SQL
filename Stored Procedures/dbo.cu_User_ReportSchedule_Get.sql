SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_ReportSchedule_Get]
(
	@reportScheduleId INT
)
AS

--DECLARE @reportScheduleId INT
--SET @reportScheduleId = 121

DECLARE @newline CHAR(2),
		@paramstring NVARCHAR(MAX)
SET @newline = CHAR(13) + CHAR(10)

DECLARE @Params TABLE (ParameterId INT, Seq INT, Name VARCHAR(255), Value NVARCHAR(MAX))

-- Determine parameter list
INSERT INTO @Params (ParameterId, Seq, Name, Value)
SELECT rsp.ReportParameterId, rp.Seq, rp.Name, rsp.Value
FROM dbo.ReportScheduleParameter rsp
INNER JOIN dbo.ReportSchedule rs ON rsp.ReportScheduleId = rs.ReportScheduleId
INNER JOIN dbo.ReportParameter rp ON rs.ReportId = rp.ReportId AND rsp.ReportParameterId = rp.ReportParameterId
WHERE rsp.ReportScheduleId = @reportScheduleId
  AND rp.Archived = 0

-- Build the parameter string
SET @paramstring = ''
IF (SELECT COUNT(*) FROM @Params) > 0
BEGIN
	SELECT @paramstring = COALESCE(@paramstring + @newline,'') + CONVERT(NVARCHAR(5), Seq) + '|' + Value
	FROM @Params
	WHERE Value IS NOT NULL
	ORDER BY Seq
END

---- Append the ReportRDL as a pseudo parameter into @paramstring
--SET @paramstring = @paramstring + @newline + 99 + CONVERT(NVARCHAR(5), rdl.ReportRDLId)

SELECT  rs.ReportScheduleId,
		r.ReportId,
		r.Name,
		r.Description,
		r.WidgetTypeId,
		rs.Description AS Comment,
		rs.UserId,
		rs.ReportPeriodTypeId AS ReportPeriod,
		rpt.Name AS ReportPeriodName,
		dbo.TZ_GetDayList(rs.SchTime,DEFAULT,rs.UserId,rs.DayList,1) AS dwString,
		dbo.TZ_GetDayList(rs.SchTime,DEFAULT,rs.UserId,rs.DateList, 0) AS dmString,
		dbo.TZ_GetTime(rs.SchTime, DEFAULT, rs.UserId) AS 'DateTime',
		rs.ExportFormat AS Format,
		rs.EmailSubject AS 'Subject',
		rs.RecipientsTo AS 'To',
		rs.RecipientsCC AS CC,
		rs.RecipientsBCC AS BCC,
		rs.ReplyTo,
		@paramstring + @newline + CONVERT(NVARCHAR(5), 99) + '|' + CONVERT(NVARCHAR(5), rdl.ReportRDLId) AS ParamsString,
        rs.Disabled,
        rdl.ReportRDLId
FROM dbo.ReportSchedule rs
INNER JOIN dbo.ReportRDL rdl ON rs.ReportRDLId = rdl.ReportRDLId
INNER JOIN dbo.ReportPeriodType rpt ON rs.ReportPeriodTypeId = rpt.ReportPeriodTypeId
INNER JOIN dbo.Report r ON rs.ReportId = r.ReportId
WHERE rs.ReportScheduleId = @reportScheduleId

GO
