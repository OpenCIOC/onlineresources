SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Pub_i]
	@Code varchar(20),
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
	Notes: Could be much more efficient by accepting the xml list of publication codes
*/

INSERT INTO CIC_ImportEntry_Pub (
	EF_ID,
	PB_ID,
	Code
)
SELECT	EF_ID,
		PB_ID,
		PubCode
	FROM CIC_ImportEntry, CIC_Publication
WHERE EF_ID=@EF_ID
	AND PubCode=@Code

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Pub_i] TO [cioc_login_role]
GO
