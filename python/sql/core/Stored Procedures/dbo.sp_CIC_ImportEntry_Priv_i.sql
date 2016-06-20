SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Priv_i]
	@Names xml,
	@FieldNames [varchar](max),
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @ER_ID int

INSERT INTO CIC_ImportEntry_PrivacyProfile (
	EF_ID,
	FieldNames
) VALUES (
	@EF_ID,
	@FieldNames
)
SET @ER_ID = SCOPE_IDENTITY()

INSERT INTO CIC_ImportEntry_PrivacyProfile_Name
SELECT @ER_ID, 
		LangID,
		N.value('ProfileName[1]', 'nvarchar(50)') AS ProfileName
FROM @Names.nodes('//DESC') as T(N)
INNER JOIN STP_Language l
	ON N.value('Culture[1]', 'varchar(5)') = l.Culture AND l.Active = 1
WHERE LangID IS NOT NULL

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Priv_i] TO [cioc_login_role]
GO
