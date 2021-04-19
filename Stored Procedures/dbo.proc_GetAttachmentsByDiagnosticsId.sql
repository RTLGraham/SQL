SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetAttachmentsByDiagnosticsId] 
	@diagnosticsId INT
AS
BEGIN
	SELECT AttachmentId
      ,DiagnosticsId
      ,FName
      ,Description
      ,Url
      ,BucketName
      ,AttachmentTypeId
      ,Archived
      ,LastOperation
  FROM [dbo].[Attachment] WHERE DiagnosticsId = @diagnosticsId

END


GO
