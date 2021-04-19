SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_SetUnplannedPlay]
(
       @vid UNIQUEIDENTIFIER, 
       @start DATETIME, 
       @end DATETIME, 
       @reason NVARCHAR(MAX)=NULL, 
       @uid UNIQUEIDENTIFIER
)
AS

EXECUTE [dbo].[proc_SetUnplannedPlay] 
   @vid
  ,@start
  ,@end
  ,@reason
  ,@uid

GO
