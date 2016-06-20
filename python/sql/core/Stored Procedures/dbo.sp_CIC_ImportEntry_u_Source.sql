SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_u_Source]
	@EF_ID int,
	@SourceDbNameEn varchar(255),
	@SourceDbNameFr varchar(255),
	@SourceDbURLEn varchar(200),
	@SourceDbURLFr varchar(200)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

IF @SourceDbNameEn='' SET @SourceDbNameEn = NULL
IF @SourceDbURLEn='' SET @SourceDbURLEn = NULL

IF @SourceDbURLFr='' SET @SourceDbURLFr = NULL
IF @SourceDbNameFr='' SET @SourceDbNameFr = NULL

IF (@SourceDbNameEn IS NOT NULL OR @SourceDbURLEn IS NOT NULL) BEGIN
		INSERT INTO CIC_ImportEntry_Description (EF_ID,LangID,SourceDbName,SourceDbURL)
		SELECT EF_ID, 0, @SourceDbNameEn, @SourceDbURLEn
			FROM CIC_ImportEntry
		WHERE EF_ID=@EF_ID
			AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Description WHERE EF_ID=@EF_ID AND LangID=0)
END

IF (@SourceDbNameFr IS NOT NULL OR @SourceDbURLFr IS NOT NULL) BEGIN
		INSERT INTO CIC_ImportEntry_Description (EF_ID,LangID,SourceDbName,SourceDbURL)
		SELECT EF_ID, 2, @SourceDbNameFr, @SourceDbURLFr
			FROM CIC_ImportEntry
		WHERE EF_ID=@EF_ID
			AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Description WHERE EF_ID=@EF_ID AND LangID=2)
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_u_Source] TO [cioc_login_role]
GO
