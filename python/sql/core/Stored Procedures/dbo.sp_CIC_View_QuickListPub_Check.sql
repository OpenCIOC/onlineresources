
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_QuickListPub_Check]
	@MemberID int,
	@NewCodes varchar(max),
	@BadCodes varchar(max) OUTPUT,
	@NewIDs varchar(max) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE	@tmpPubCodes TABLE (PubCode varchar(20) COLLATE Latin1_General_100_CI_AI)

SET @NewCodes = RTRIM(LTRIM(@NewCodes))
IF @NewCodes = '' SET @NewCodes = NULL

IF @NewCodes IS NOT NULL BEGIN
	INSERT INTO @tmpPubCodes
	SELECT *
		FROM dbo.fn_GBL_ParseVarCharIDList(@NewCodes,';')
	SET @Error = @@ERROR
	
	IF @Error = 0 BEGIN
		SELECT @BadCodes = COALESCE(@BadCodes + ' ; ','') + tm.PubCode
			FROM @tmpPubCodes tm
			LEFT JOIN CIC_Publication pb
				ON tm.PubCode = pb.PubCode
		WHERE pb.PB_ID IS NULL
			OR (MemberID IS NOT NULL AND MemberID<>@MemberID)
			OR EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)

		IF @BadCodes IS NOT NULL BEGIN
			SET @Error = 3 -- No Such Record
		END ELSE BEGIN
			SELECT @NewIDs = COALESCE(@NewIDs + ',','') + CAST(pb.PB_ID AS varchar)
				FROM @tmpPubCodes tm
				INNER JOIN CIC_Publication pb
					ON tm.PubCode = pb.PubCode
				WHERE (MemberID IS NULL OR MemberID=@MemberID)
					AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
		END
	END
END

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_QuickListPub_Check] TO [cioc_login_role]
GO
