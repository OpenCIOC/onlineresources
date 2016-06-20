/*
INSERT INTO dbo.VOL_OP_AC
        ( AC_ID, VNUM )
SELECT DISTINCT ac.AC_ID, rac.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/ACCESSIBILITY/CHK') AS T(N)) rac
INNER JOIN GBL_Accessibility_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_AC WHERE AC_ID=ac.AC_ID AND VNUM=rac.VNUM)

INSERT INTO dbo.VOL_OP_AC_Notes
        ( OP_AC_ID, LangID, Notes )
SELECT DISTINCT pr.OP_AC_ID, 0, Notes
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name, N.value('@N','nvarchar(max)') AS Notes
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/ACCESSIBILITY/CHK') AS T(N)) rac
INNER JOIN GBL_Accessibility_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
INNER JOIN dbo.VOL_OP_AC pr
	ON pr.VNUM=rac.VNUM AND pr.AC_ID=ac.AC_ID
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_AC_Notes WHERE OP_AC_ID=pr.OP_AC_ID AND LangID=0)
	AND rac.Notes IS NOT NULL

INSERT INTO dbo.VOL_OP_SK
        ( SK_ID, VNUM )
SELECT DISTINCT sk.SK_ID, rsk.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/SKILLS/CHK') AS T(N)) rsk
INNER JOIN dbo.VOL_Skill_Name sk
	ON rsk.Name=sk.Name AND sk.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_SK WHERE SK_ID=sk.SK_ID AND VNUM=rsk.VNUM)

INSERT INTO dbo.VOL_OP_AI
        ( AI_ID, VNUM )
SELECT DISTINCT ai.AI_ID, rai.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/INTERESTS/CHK') AS T(N)) rai
INNER JOIN dbo.VOL_Interest_Name ai
	ON rai.Name=ai.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_AI WHERE AI_ID=ai.AI_ID AND VNUM=rai.VNUM)

INSERT INTO dbo.VOL_OP_CM
        ( CM_ID, NUM_NEEDED, VNUM )
SELECT DISTINCT cm.CM_ID, rcm.NUM_NEEDED, rcm.VNUM
FROM
(SELECT ied.VNUM, N.value('@NO_NEEDED','int') AS NUM_NEEDED, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/NUM_NEEDED/CM') AS T(N)) rcm
INNER JOIN dbo.GBL_Community_Name cm
	ON rcm.Name=cm.Name AND cm.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_CM WHERE CM_ID=cm.CM_ID AND VNUM=rcm.VNUM)

INSERT INTO  VOL_OP_SB
SELECT DISTINCT ai.SB_ID, rai.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/SUITABILITY/CHK') AS T(N)) rai
INNER JOIN dbo.VOL_Suitability_Name ai
	ON rai.Name=ai.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_SB WHERE SB_ID=ai.SB_ID AND VNUM=rai.VNUM)

INSERT INTO VOL_OP_SB_Notes
		(OP_SB_ID, LangID, Notes)
SELECT DISTINCT pr.OP_SB_ID, 0, Notes
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name, N.value('@N','nvarchar(max)') AS Notes
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/SUITABILITY/CHK') AS T(N)) rac
INNER JOIN VOL_Suitability_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
INNER JOIN dbo.VOL_OP_SB pr
	ON pr.VNUM=rac.VNUM AND pr.SB_ID=ac.SB_ID
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_SB_Notes WHERE OP_SB_ID=pr.OP_SB_ID AND LangID=0)
	AND rac.Notes IS NOT NULL

INSERT INTO  VOL_OP_IL
SELECT DISTINCT ai.IL_ID, rai.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/INTERACTION_LEVEL/CHK') AS T(N)) rai
INNER JOIN dbo.VOL_InteractionLevel_Name ai
	ON rai.Name=ai.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_IL WHERE IL_ID=ai.IL_ID AND VNUM=rai.VNUM)

INSERT INTO VOL_OP_IL_Notes (OP_IL_ID, LangID, Notes)
SELECT DISTINCT pr.OP_IL_ID, 0, Notes
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name, N.value('@N','nvarchar(max)') AS Notes
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/INTERACTION_LEVEL/CHK') AS T(N)) rac
INNER JOIN VOL_InteractionLevel_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
INNER JOIN dbo.VOL_OP_IL pr
	ON pr.VNUM=rac.VNUM AND pr.IL_ID=ac.IL_ID
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_IL_Notes WHERE OP_IL_ID=pr.OP_IL_ID AND LangID=0)
	AND rac.Notes IS NOT NULL

INSERT INTO  VOL_OP_SSN
SELECT DISTINCT ai.SSN_ID, rai.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/SEASONS/CHK') AS T(N)) rai
INNER JOIN dbo.VOL_Seasons_Name ai
	ON rai.Name=ai.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_SSN WHERE SSN_ID=ai.SSN_ID AND VNUM=rai.VNUM)

INSERT INTO VOL_OP_SSN_Notes (OP_SSN_ID, LangID, Notes)
SELECT DISTINCT pr.OP_SSN_ID, 0, Notes
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name, N.value('@N','nvarchar(max)') AS Notes
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/SEASONS/CHK') AS T(N)) rac
INNER JOIN VOL_Seasons_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
INNER JOIN dbo.VOL_OP_SSN pr
	ON pr.VNUM=rac.VNUM AND pr.SSN_ID=ac.SSN_ID
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_SSN_Notes WHERE OP_SSN_ID=pr.OP_SSN_ID AND LangID=0)
	AND rac.Notes IS NOT NULL

INSERT INTO  VOL_OP_TRN
SELECT DISTINCT ai.TRN_ID, rai.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/TRAINING/CHK') AS T(N)) rai
INNER JOIN dbo.VOL_Training_Name ai
	ON rai.Name=ai.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_TRN WHERE TRN_ID=ai.TRN_ID AND VNUM=rai.VNUM)

INSERT INTO VOL_OP_TRN_Notes (OP_TRN_ID, LangID, Notes)
SELECT DISTINCT pr.OP_TRN_ID, 0, Notes
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name, N.value('@N','nvarchar(max)') AS Notes
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/TRAINING/CHK') AS T(N)) rac
INNER JOIN VOL_Training_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
INNER JOIN dbo.VOL_OP_TRN pr
	ON pr.VNUM=rac.VNUM AND pr.TRN_ID=ac.TRN_ID
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_TRN_Notes WHERE OP_TRN_ID=pr.OP_TRN_ID AND LangID=0)
	AND rac.Notes IS NOT NULL


INSERT INTO  VOL_OP_TRP
SELECT DISTINCT ai.TRP_ID, rai.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/TRANSPORTATION/CHK') AS T(N)) rai
INNER JOIN dbo.VOL_Transportation_Name ai
	ON rai.Name=ai.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_TRP WHERE TRP_ID=ai.TRP_ID AND VNUM=rai.VNUM)

INSERT INTO VOL_OP_TRP_Notes (OP_TRP_ID, LangID, Notes)
SELECT DISTINCT pr.OP_TRP_ID, 0, Notes
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name, N.value('@N','nvarchar(max)') AS Notes
FROM dbo.VOL_ImportEntry_Data ied
CROSS APPLY DATA.nodes('/RECORD/TRANSPORTATION/CHK') AS T(N)) rac
INNER JOIN VOL_Transportation_Name ac
	ON rac.Name=ac.Name AND ac.LangID=0
INNER JOIN dbo.VOL_OP_TRP pr
	ON pr.VNUM=rac.VNUM AND pr.TRP_ID=ac.TRP_ID
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_TRP_Notes WHERE OP_TRP_ID=pr.OP_TRP_ID AND LangID=0)
	AND rac.Notes IS NOT NULL

*/

/*
INSERT INTO dbo.GBL_Contact
        ( VolVNUM ,
          VolOPDID ,
          LangID ,
          VolContactType ,
          NAME_HONORIFIC ,
          NAME_FIRST ,
          NAME_LAST ,
          NAME_SUFFIX ,
          TITLE ,
          ORG ,
          EMAIL ,
          FAX_NOTE ,
          FAX_NO ,
          FAX_EXT ,
          FAX_CALLFIRST ,
          PHONE_1_TYPE ,
          PHONE_1_NOTE ,
          PHONE_1_NO ,
          PHONE_1_EXT ,
          PHONE_1_OPTION ,
          PHONE_2_TYPE ,
          PHONE_2_NOTE ,
          PHONE_2_NO ,
          PHONE_2_EXT ,
          PHONE_2_OPTION ,
          PHONE_3_TYPE ,
          PHONE_3_NOTE ,
          PHONE_3_NO ,
          PHONE_3_EXT ,
          PHONE_3_OPTION
        )
SELECT ied.VNUM,
	vod.OPD_ID,
	CASE WHEN N.value('@LANG', 'char(1)') = 'F' THEN 2 ELSE 0 END AS LangID,
	'CONTACT',
	N.value('@NMH', 'nvarchar(60)') AS NAME_HONORIFIC,
	N.value('@NMFIRST', 'nvarchar(60)') AS NAME_FIRST,
	N.value('@NMLAST', 'nvarchar(100)') AS NAME_LAST,
	N.value('@NMS', 'nvarchar(30)') AS NAME_SUFFIX, 
	N.value('@TTL', 'nvarchar(100)') AS TITLE,
	N.value('@ORG', 'nvarchar(100)') AS ORG,
	N.value('@EML', 'varchar(100)') AS EMAIL,
	N.value('@FAXN', 'nvarchar(100)') AS FAX_NOTE,
	N.value('@FAXNO', 'nvarchar(100)') AS FAX_NO,
	N.value('@FAXEX', 'nvarchar(100)') AS FAX_EXT,
	ISNULL(N.value('@FAXCALL', 'nvarchar(100)'),0) AS FAX_CALLFIRST,
	N.value('@PH1TYPE', 'nvarchar(100)') AS PHONE_1_TYPE,
	N.value('@PH1N', 'nvarchar(100)') AS PHONE_1_NOTE,
	N.value('@PH1NO', 'nvarchar(100)') AS PHONE_1_NO,
	N.value('@PH1EXT', 'nvarchar(100)') AS PHONE_1_EXT,
	N.value('@PH1OPT', 'nvarchar(100)') AS PHONE_1_OPTION,
	N.value('@PH2TYPE', 'nvarchar(100)') AS PHONE_2_TYPE,
	N.value('@PH2N', 'nvarchar(100)') AS PHONE_2_NOTE,
	N.value('@PH2NO', 'nvarchar(100)') AS PHONE_2_NO,
	N.value('@PH2EXT', 'nvarchar(100)') AS PHONE_2_EXT,
	N.value('@PH2OPT', 'nvarchar(100)') AS PHONE_2_OPTION,
	N.value('@PH3TYPE', 'nvarchar(100)') AS PHONE_3_TYPE,
	N.value('@PH3N', 'nvarchar(100)') AS PHONE_3_NOTE,
	N.value('@PH3NO', 'nvarchar(100)') AS PHONE_3_NO,
	N.value('@PH3EXT', 'nvarchar(100)') AS PHONE_3_EXT,
	N.value('@PH3OPT', 'nvarchar(100)') AS PHONE_3_OPTION
FROM dbo.VOL_ImportEntry_Data ied
INNER JOIN dbo.VOL_Opportunity_Description vod
	ON vod.VNUM = ied.VNUM AND vod.LangID=0
CROSS APPLY DATA.nodes('/RECORD/CONTACT/CONTACT') AS T(N)
WHERE NOT EXISTS(SELECT * FROM GBL_Contact WHERE VOLVNUM=ied.VNUM AND VolContactType='CONTACT')
*/

/*
SELECT * 
--DELETE c
FROM GBL_Contact c
INNER JOIN VOL_Opportunity vo
	ON c.VolVNUM=vo.VNUM
WHERE MemberID=1700
*/


/*
INSERT INTO dbo.VOL_OP_CommunitySet
		(CommunitySetID, VNUM)
SELECT DISTINCT csn.CommunitySetID, rac.VNUM
FROM
(SELECT ied.VNUM, N.value('@V','nvarchar(255)') AS Name
FROM dbo.VOL_ImportEntry_Data ied
INNER JOIN VOL_ImportEntry ie
	ON ie.EF_ID = ied.EF_ID AND ie.MemberID=1700
CROSS APPLY DATA.nodes('/RECORD/COMMUNITY_SETS/CHK') AS T(N)) rac
INNER JOIN VOL_CommunitySet_Name csn
	ON rac.Name=csn.SetName AND csn.LangID=0
WHERE NOT EXISTS(SELECT * FROM dbo.VOL_OP_CommunitySet WHERE CommunitySetID=csn.CommunitySetID AND VNUM=rac.VNUM)
*/
