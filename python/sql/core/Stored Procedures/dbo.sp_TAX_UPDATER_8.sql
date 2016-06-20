SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_8]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 15-Oct-2012
	Action: NO ACTION REQUIRED
*/

/* Delete invalid Related Concept references */
DELETE trc
	FROM TAX_TM_RC trc
WHERE Authorized=1
	AND NOT EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_TM_RC utrc
		WHERE utrc.Code=trc.Code
		AND utrc.RC_ID=(SELECT urc.RC_ID
			FROM tax_updater.dbo.UPDATER_RelatedConcept urc
			INNER JOIN TAX_RelatedConcept rc
				ON urc.Code=rc.Code
			WHERE rc.RC_ID=trc.RC_ID AND urc.RC_ID=utrc.RC_ID))


/* Insert new Related Concept references */
INSERT INTO TAX_TM_RC (Code,RC_ID,Authorized)
SELECT utrc.Code, (SELECT rc.RC_ID
		FROM tax_updater.dbo.UPDATER_RelatedConcept urc
		INNER JOIN TAX_RelatedConcept rc
			ON urc.Code=rc.Code
		WHERE urc.RC_ID=utrc.RC_ID), 1
FROM tax_updater.dbo.UPDATER_TM_RC utrc
WHERE NOT EXISTS(SELECT * FROM TAX_TM_RC trc
	WHERE trc.Code=utrc.Code
	AND trc.RC_ID=(SELECT rc.RC_ID
		FROM tax_updater.dbo.UPDATER_RelatedConcept urc
		INNER JOIN TAX_RelatedConcept rc
			ON urc.Code=rc.Code
		WHERE urc.RC_ID=utrc.RC_ID))

/* Update Authorization status of Related Concept references */
UPDATE trc
	SET Authorized		= 1,
		MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= '(Import)'
FROM TAX_TM_RC trc
WHERE Authorized=0
	AND EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_TM_RC utrc
		WHERE utrc.Code=trc.Code
		AND utrc.RC_ID=(SELECT urc.RC_ID
			FROM tax_updater.dbo.UPDATER_RelatedConcept urc
			INNER JOIN TAX_RelatedConcept rc
				ON urc.Code=rc.Code
			WHERE rc.RC_ID=trc.RC_ID AND urc.RC_ID=utrc.RC_ID))

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_8] TO [cioc_login_role]
GO
