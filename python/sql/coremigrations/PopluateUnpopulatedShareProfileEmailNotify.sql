/*
UPDATE sp SET 
		ShareNotifyEmailAddresses = (SELECT CASE WHEN ShareNotifyEmailAddresses IS NOT NULL THEN ShareNotifyEmailAddresses ELSE STUFF(
			   (SELECT	', ' + u.Email FROM (SELECT DISTINCT Email
					FROM	GBL_Users u
					INNER JOIN CIC_SecurityLevel sl
						ON sl.SL_ID = u.SL_ID_CIC
					WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
								AND sl.MemberID = sp.ShareMemberID AND u.Email IS NOT NULL
					) u ORDER BY u.Email
				FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, '') END
		),
		NotifyEmailAddresses = (SELECT CASE WHEN NotifyEmailAddresses IS NOT NULL THEN NotifyEmailAddresses ELSE STUFF(
			   (SELECT	', ' + u.Email FROM (SELECT DISTINCT Email
					FROM	GBL_Users u
					INNER JOIN CIC_SecurityLevel sl
						ON sl.SL_ID = u.SL_ID_CIC
					WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
								AND sl.MemberID = sp.MemberID AND u.Email IS NOT NULL
					) u ORDER BY u.Email
				FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, '') END
		) 
		*/

SELECT * 
 FROM GBL_SharingProfile sp WHERE NotifyEmailAddresses IS NULL OR ShareNotifyEmailAddresses IS NULL