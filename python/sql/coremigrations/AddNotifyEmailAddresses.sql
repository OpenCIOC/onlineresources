UPDATE m
 SET NotifyEmailAddresses = STUFF(
	   (SELECT	', ' + Email FROM (SELECT DISTINCT Email
			FROM	GBL_Users u
			INNER JOIN CIC_SecurityLevel sl
				ON sl.SL_ID = u.SL_ID_CIC
			WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
						AND sl.MemberID = m.MemberID AND u.Email IS NOT NULL
			) x ORDER BY Email
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, ''),
   ShareNotifyEmailAddresses = STUFF(
	   (SELECT	', ' + Email
		FROM (SELECT DISTINCT Email
			FROM	GBL_Users u
			INNER JOIN CIC_SecurityLevel sl
				ON sl.SL_ID = u.SL_ID_CIC
			WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
						AND sl.MemberID = m.ShareMemberID AND u.Email IS NOT NULL
			) x ORDER BY Email
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, '')
FROM GBL_SharingProfile m
WHERE m.Domain=1

UPDATE m
 SET NotifyEmailAddresses = STUFF(
	   (SELECT	', ' + Email FROM (SELECT DISTINCT Email
			FROM	GBL_Users u
			INNER JOIN VOL_SecurityLevel sl
				ON sl.SL_ID = u.SL_ID_VOL
			WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
						AND sl.MemberID = m.MemberID AND u.Email IS NOT NULL
			) u ORDER BY u.Email
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, ''),
   ShareNotifyEmailAddresses = STUFF(
	   (SELECT	', ' + u.Email FROM (SELECT DISTINCT Email 
			FROM	GBL_Users u
			INNER JOIN VOL_SecurityLevel sl
				ON sl.SL_ID = u.SL_ID_VOL
			WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
						AND sl.MemberID = m.ShareMemberID AND u.Email IS NOT NULL
			) u ORDER BY u.Email
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, '')
FROM GBL_SharingProfile m
WHERE m.Domain=2
