UPDATE sm SET
-- SELECT
 IconURL16='https://s3.amazonaws.com/cioc.shared/socialmedia16px/' + IconFileName,
 IconURL24='https://s3.amazonaws.com/cioc.shared/socialmedia24px/' + IconFileName
 FROM GBL_SocialMedia AS sm
 WHERE sm.IconFileName IS NOT NULL AND sm.IconURL16 IS NULL AND sm.IconURL24 IS NULL

UPDATE GBL_FieldOption SET 
UpdateFieldList='(SELECT (SELECT sm.SM_ID AS ''@ID'', ISNULL(smn.Name,sm.DefaultName) AS ''@Name'', IconFileName AS ''@Icon'', IconURL16 AS ''@Icon16'', IconURL24 AS ''@Icon24'', GeneralURL AS ''@GeneralURL'', pr.URL AS ''@URL'', pr.Protocol AS ''@Proto'' FROM GBL_SocialMedia sm LEFT JOIN GBL_SocialMedia_Name smn ON sm.SM_ID=smn.SM_ID AND smn.LangID=btd.LangID LEFT JOIN GBL_BT_SM pr ON pr.SM_ID=sm.SM_ID AND pr.NUM=bt.NUM AND pr.LangID=btd.LangID WHERE pr.NUM IS NOT NULL OR sm.Active=1 ORDER BY ISNULL(smn.Name,sm.DefaultName) FOR XML PATH(''SM''), TYPE) FOR XML PATH(''SOCIAL_MEDIA''),TYPE) AS SOCIAL_MEDIA',
FeedbackFieldList='(SELECT (SELECT sm.SM_ID AS "@ID", ISNULL(smn.Name,sm.DefaultName) AS ''@Name'', IconFileName AS ''@Icon'', IconURL16 AS ''@Icon16'', IconURL24 AS ''@Icon24'', GeneralURL AS ''@GeneralURL'', pr.URL AS ''@URL'', pr.Protocol AS ''@Proto'' FROM GBL_SocialMedia sm LEFT JOIN GBL_SocialMedia_Name smn ON sm.SM_ID=smn.SM_ID AND smn.LangID=btd.LangID LEFT JOIN GBL_BT_SM pr ON pr.SM_ID=sm.SM_ID AND pr.NUM=bt.NUM AND pr.LangID=btd.LangID WHERE pr.NUM IS NOT NULL OR sm.Active=1 ORDER BY ISNULL(smn.Name,sm.DefaultName) FOR XML PATH(''SM''), TYPE) FOR XML PATH(''SOCIAL_MEDIA''),TYPE) AS SOCIAL_MEDIA'
WHERE FieldName='SOCIAL_MEDIA'

UPDATE VOL_FieldOption SET
UpdateFieldList='(SELECT (SELECT sm.SM_ID AS "@ID", ISNULL(smn.Name,sm.DefaultName) AS ''@Name'', IconFileName AS ''@Icon'', IconURL16 AS ''@Icon16'', IconURL24 AS ''@Icon24'', GeneralURL AS ''@GeneralURL'', pr.URL AS ''@URL'', pr.Protocol AS ''@Proto'' FROM GBL_SocialMedia sm LEFT JOIN GBL_SocialMedia_Name smn ON sm.SM_ID=smn.SM_ID AND smn.LangID=vod.LangID LEFT JOIN VOL_OP_SM pr ON pr.SM_ID=sm.SM_ID AND pr.VNUM=vo.VNUM AND pr.LangID=vod.LangID WHERE pr.VNUM IS NOT NULL OR sm.Active=1 ORDER BY ISNULL(smn.Name,sm.DefaultName) FOR XML PATH(''SM''), TYPE) FOR XML PATH(''SOCIAL_MEDIA''),TYPE) AS SOCIAL_MEDIA',
FeedbackFieldList='(SELECT (SELECT sm.SM_ID AS "@ID", ISNULL(smn.Name,sm.DefaultName) AS ''@Name'', IconFileName AS ''@Icon'', IconURL16 AS ''@Icon16'', IconURL24 AS ''@Icon24'', GeneralURL AS ''@GeneralURL'', pr.URL AS ''@URL'', pr.Protocol AS ''@Proto'' FROM GBL_SocialMedia sm LEFT JOIN GBL_SocialMedia_Name smn ON sm.SM_ID=smn.SM_ID AND smn.LangID=vod.LangID LEFT JOIN VOL_OP_SM pr ON pr.SM_ID=sm.SM_ID AND pr.VNUM=vo.VNUM AND pr.LangID=vod.LangID WHERE pr.VNUM IS NOT NULL OR sm.Active=1 ORDER BY ISNULL(smn.Name,sm.DefaultName) FOR XML PATH(''SM''), TYPE) FOR XML PATH(''SOCIAL_MEDIA''),TYPE) AS SOCIAL_MEDIA'
WHERE FieldName='SOCIAL_MEDIA'
