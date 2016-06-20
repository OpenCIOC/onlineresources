DECLARE @SQL nvarchar(500)
SET @SQL = N'BACKUP DATABASE [' + DB_NAME() + '] TO  DISK = N''D:\backup\PreUpgrade\' + DB_NAME() + '_backup_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'' WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N''' + DB_NAME() + '-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10'
EXECUTE sp_executesql @SQL