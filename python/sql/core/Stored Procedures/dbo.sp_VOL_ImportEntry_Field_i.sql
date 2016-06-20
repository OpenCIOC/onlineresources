SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ImportEntry_Field_i]
	@FieldName varchar(100),
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
	Notes: Could be much more efficient by accepting the xml list of fields
*/

INSERT INTO VOL_ImportEntry_Field (
	EF_ID,
	FieldID
)
SELECT	EF_ID,
		FieldID
	FROM VOL_ImportEntry, VOL_FieldOption
WHERE EF_ID=@EF_ID
	AND FieldName=@FieldName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ImportEntry_Field_i] TO [cioc_login_role]
GO
