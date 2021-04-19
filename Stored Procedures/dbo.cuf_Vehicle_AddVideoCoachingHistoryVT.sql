SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_AddVideoCoachingHistoryVT]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@comment NVARCHAR(MAX)
)
AS

	--DECLARE @evid BIGINT,
	--		@uid UNIQUEIDENTIFIER
	--
	--SET @evid = 2
	--SET @uid = N'96097197-8B42-4CB4-B0DC-E1E436C06D26'

	INSERT INTO dbo.VideoCoachingHistoryVT
	        ( IncidentId ,
	          StatusUserId ,
	          StatusDateTime ,
	          Comments ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( @evid , -- IncidentId - bigint
	          @uid , -- StatusUserId - uniqueidentifier
	          GETUTCDATE() , -- StatusDateTime - datetime
	          @comment , -- Comments - nvarchar(max)
	          GETDATE() , -- LastOperation - smalldatetime
	          0  -- Archived - bit
	        )


GO
