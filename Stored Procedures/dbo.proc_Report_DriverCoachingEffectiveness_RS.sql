SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DriverCoachingEffectiveness_RS]
          @uid UNIQUEIDENTIFIER,
          @gids NVARCHAR(MAX),
          @sdate DATETIME,
          @edate DATETIME,
		  @groupby INT
AS
	SET NOCOUNT ON;

	EXECUTE dbo.[cuf_Driver_CoachingEffectiveness] 
	   @uid
	  ,@gids
	  ,@sdate
	  ,@edate
	   ,1,1,@groupby


GO
