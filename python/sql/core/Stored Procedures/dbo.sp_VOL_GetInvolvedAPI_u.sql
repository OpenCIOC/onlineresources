SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_GetInvolvedAPI_u]
	@MemberID int,
	@Agencies [xml],
	@Interests [xml],
	@Skills [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 27-Jun-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@InterestObjectName nvarchar(100),
		@SkillObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100),
		@CommunitySetObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @InterestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Interest')
SET @SkillObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Skill')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')
SET @CommunitySetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Set')

DECLARE @AgencyTable TABLE (
	AgencyCode char(3) NOT NULL,
	GetInvolvedUser nvarchar(100),
	GetInvolvedToken nvarchar(100),
	GetInvolvedCommunitySet int,
	GetInvolvedSite nvarchar(200)
)

DECLARE @InterestTable TABLE (
	AI_ID int NOT NULL,
	GIInterestID int,
	GISkillID int
)

DECLARE @SkillTable TABLE (
	SK_ID int NOT NULL,
	GIInterestID int,
	GISkillID int
)


INSERT INTO @AgencyTable
	( AgencyCode, GetInvolvedUser, GetInvolvedToken, GetInvolvedCommunitySet, GetInvolvedSite )
SELECT 
	N.value('AgencyCode[1]', 'char(3)') AS AgencyCode,
	N.value('GetInvolvedUser[1]', 'nvarchar(100)') AS GetInvolvedUser,
	N.value('GetInvolvedToken[1]', 'nvarchar(100)') AS GetInvolvedToken,
	N.value('GetInvolvedCommunitySet[1]', 'int') AS GetInvolvedCommunitySet,
	N.value('GetInvolvedSite[1]', 'nvarchar(200)') AS GetInvolvedSite
FROM @Agencies.nodes('//Agency') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @AgencyObjectName, @ErrMsg

INSERT INTO @InterestTable
	( AI_ID, GIInterestID, GISkillID)
SELECT 
	N.value('AI_ID[1]', 'int') AS AI_ID,
	N.value('GIInterestID[1]', 'int') AS GIInterestID,
	N.value('GISkillID[1]', 'int') AS GISkillID
FROM @Interests.nodes('//Interest') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InterestObjectName, @ErrMsg

INSERT INTO @SkillTable
	( SK_ID, GIInterestID, GISkillID)
SELECT 
	N.value('SK_ID[1]', 'int') AS SK_ID,
	N.value('GIInterestID[1]', 'int') AS GIInterestID,
	N.value('GISkillID[1]', 'int') AS GISkillID
FROM @Skills.nodes('//Skill') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SkillObjectName, @ErrMsg


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END ELSE BEGIN
	MERGE INTO GBL_Agency dst
	USING (SELECT src.* FROM @AgencyTable src
			INNER JOIN GBL_Agency a
				ON a.AgencyCode=src.AgencyCode AND a.MemberID=@MemberID
			WHERE EXISTS(SELECT * FROM VOL_CommunitySet WHERE CommunitySetID=src.GetInvolvedCommunitySet)
			) src
		ON src.AgencyCode=dst.AgencyCode AND dst.RecordOwnerVOL=1
	WHEN MATCHED THEN
		UPDATE SET 
			GetInvolvedUser = src.GetInvolvedUser,
			GetInvolvedToken = src.GetInvolvedToken,
			GetInvolvedCommunitySet = src.GetInvolvedCommunitySet,
			GetInvolvedSite = src.GetInvolvedSite
	WHEN NOT MATCHED BY SOURCE AND dst.MemberID=@MemberID THEN
		UPDATE SET
			GetInvolvedUser = NULL,
			GetInvolvedToken = NULL,
			GetInvolvedCommunitySet = NULL,
			GetInvolvedSite = NULL
			
		;
		
		
	MERGE INTO VOL_Interest_GetInvolved_Map dst
	USING (SELECT DISTINCT src.* FROM @InterestTable src
			INNER JOIN VOL_Interest ai
				ON ai.AI_ID=src.AI_ID
			WHERE NOT (src.GIInterestID IS NULL AND src.GISkillID IS NULL) 
					AND (src.GIInterestID IS NULL OR EXISTS(SELECT * FROM VOL_GetInvolved_Interest WHERE GIInterestID=src.GIInterestID))
					AND (src.GISkillID IS NULL OR EXISTS(SELECT * FROM VOL_GetInvolved_Skill WHERE GISkillID=src.GISkillID))
					) src
		ON dst.AI_ID=src.AI_ID AND dst.GIInterestID=src.GIInterestID AND dst.GISkillID=src.GISkillID
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (AI_ID, GIInterestID, GISkillID) VALUES (src.AI_ID, src.GIInterestID, src.GISkillID)
		
	WHEN NOT MATCHED BY SOURCE THEN 
		DELETE 
		
		;
		
	MERGE INTO VOL_Skill_GetInvolved_Map dst
	USING (SELECT DISTINCT src.* FROM @SkillTable src
			INNER JOIN VOL_Skill ai
				ON ai.SK_ID=src.SK_ID
			WHERE NOT (src.GIInterestID IS NULL AND src.GISkillID IS NULL) 
					AND (src.GIInterestID IS NULL OR EXISTS(SELECT * FROM VOL_GetInvolved_Interest WHERE GIInterestID=src.GIInterestID))
					AND (src.GISkillID IS NULL OR EXISTS(SELECT * FROM VOL_GetInvolved_Skill WHERE GISkillID=src.GISkillID))
					) src
		ON dst.SK_ID=src.SK_ID AND dst.GIInterestID=src.GIInterestID AND dst.GISkillID=src.GISkillID
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (SK_ID, GIInterestID, GISkillID) VALUES (src.SK_ID, src.GIInterestID, src.GISkillID)
		
	WHEN NOT MATCHED BY SOURCE THEN 
		DELETE 
		
		;
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_GetInvolvedAPI_u] TO [cioc_login_role]
GO
