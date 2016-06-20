UPDATE vo SET VNUM=src.VNUM
FROM VOL_Opportunity vo
INNER JOIN 
(SELECT OP_ID,
 VNUM='V-' + vo.RECORD_OWNER + RIGHT('00000' + CAST(ROW_NUMBER() OVER (PARTITION BY vo.RECORD_OWNER ORDER BY vo.OP_ID) AS varchar(4)), 4)
 FROM VOL_Opportunity vo
 ) AS src
	ON vo.OP_ID=src.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_Opportunity_Description dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_Feedback dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_AC dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_AI dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_CL dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_CM dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_CommunitySet dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_IL dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_Referral dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_Reminder dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_SB dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_SharingProfile dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_SK dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_SM dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_SSN dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_TRN dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_OP_TRP dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_Opportunity_History dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VNUM=vo.VNUM
FROM VOL_Opportunity_StatsCache dst
INNER JOIN VOL_Opportunity vo
	ON vo.OP_ID = dst.OP_ID
	
UPDATE dst SET VolVNUM=vo.VNUM, VolOPDID=vo.OPD_ID
FROM GBL_Contact dst
INNER JOIN VOL_Opportunity_Description vo
	ON vo.OP_ID = dst.VolOPID AND vo.LangID=dst.LangID
	
UPDATE dst SET VolVNUM=vo.VNUM, VolOPDID=vo.OPD_ID
FROM GBL_RecordNote dst
INNER JOIN VOL_Opportunity_Description vo
	ON vo.OP_ID = dst.VolOPID AND vo.LangID=dst.LangID