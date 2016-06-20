SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ImportEntry_Data_Language_i]
	@ER_ID int,
	@English bit,
	@French bit,
	@NON_PUBLIC_E bit,
	@NON_PUBLIC_F bit,
	@DELETION_DATE_E smalldatetime,
	@DELETION_DATE_F smalldatetime
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 23-Feb-2014
	Action: NO ACTION REQUIRED
*/

IF @English=1 BEGIN
	INSERT INTO VOL_ImportEntry_Data_Language (
		ER_ID,
		LangID,
		NON_PUBLIC,
		DELETION_DATE
	)
	SELECT ER_ID, 0, @NON_PUBLIC_E, @DELETION_DATE_E
		FROM VOL_ImportEntry_Data
	WHERE ER_ID=@ER_ID
END

IF @French=1 BEGIN
	INSERT INTO VOL_ImportEntry_Data_Language (
		ER_ID,
		LangID,
		NON_PUBLIC,
		DELETION_DATE
	)
	SELECT ER_ID, 2, @NON_PUBLIC_F, @DELETION_DATE_F
		FROM VOL_ImportEntry_Data
	WHERE ER_ID=@ER_ID
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ImportEntry_Data_Language_i] TO [cioc_login_role]
GO
