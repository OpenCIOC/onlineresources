SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ImportEntry_Data_i]
	@EF_ID int,
	@ID varchar(50),
	@OWNER varchar(3),
	@PRIVACY_PROFILE varchar(100),
	@DATA nvarchar(MAX),
	@ER_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 04-Mar-2013
	Action: NO ACTION REQUIRED
*/

INSERT INTO VOL_ImportEntry_Data (
	EF_ID,
	VNUM,
	EXTERNAL_ID,
	OWNER,
	DATA
)
SELECT EF_ID,
		CASE
			WHEN EXISTS(SELECT * FROM VOL_Opportunity WHERE VNUM=@ID) THEN @ID
			--WHEN EXISTS(SELECT * FROM VOL_Opportunity WHERE EXTERNAL_ID=@ID) THEN (SELECT TOP 1 NUM FROM VOL_Opportunity WHERE EXTERNAL_ID=@ID ORDER BY CASE WHEN RECORD_OWNER=@OWNER THEN 0 ELSE 1 END, NUM)
			WHEN cioc_shared.dbo.RegexMatch(@ID,'V-([A-Z]){3}([0-9]){4,5}')=1 THEN @ID
			ELSE NULL
			END,
		NULL,
		--CASE WHEN cioc_shared.dbo.RegexMatch(@ID,'V-([A-Z]){3}([0-9]){4,5}')<>1 OR (NOT EXISTS(SELECT * FROM VOL_Opportunity WHERE NUM=@ID) AND EXISTS(SELECT * FROM VOL_Opportunity WHERE EXTERNAL_ID=@ID))
		--	THEN @ID ELSE NULL END,
		@OWNER,
		@DATA
	FROM VOL_ImportEntry
WHERE EF_ID=@EF_ID
	AND NOT EXISTS(SELECT * FROM VOL_ImportEntry_Data WHERE EF_ID=@EF_ID AND (VNUM=@ID OR EXTERNAL_ID=@ID))

SET @ER_ID = SCOPE_IDENTITY()

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ImportEntry_Data_i] TO [cioc_login_role]
GO
