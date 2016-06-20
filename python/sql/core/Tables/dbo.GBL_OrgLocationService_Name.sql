CREATE TABLE [dbo].[GBL_OrgLocationService_Name]
(
[OLS_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_GBL_OrgLocationService_Name_d] ON [dbo].[GBL_OrgLocationService_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ols
	FROM GBL_OrgLocationService ols
	INNER JOIN Deleted d
		ON ols.OLS_ID=d.OLS_ID
	WHERE NOT EXISTS(SELECT * FROM GBL_OrgLocationService_Name olsn WHERE olsn.OLS_ID=ols.OLS_ID)
		AND NOT EXISTS(SELECT * FROM GBL_BT_OLS pr WHERE pr.OLS_ID=ols.OLS_ID)

INSERT INTO GBL_OrgLocationService_Name (OLS_ID,LangID,[Name])
	SELECT d.OLS_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM GBL_OrgLocationService_Name olsn WHERE olsn.OLS_ID=d.OLS_ID)
			AND EXISTS(SELECT * FROM GBL_BT_OLS pr WHERE pr.OLS_ID=d.OLS_ID)
	
SET NOCOUNT OFF

GO
ALTER TABLE [dbo].[GBL_OrgLocationService_Name] ADD CONSTRAINT [PK_GBL_OrgLocationService_Name] PRIMARY KEY CLUSTERED  ([OLS_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_OrgLocationService_Name] ADD CONSTRAINT [FK_GBL_OrgLocationService_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_OrgLocationService_Name] ADD CONSTRAINT [FK_GBL_OrgLocationService_Name_GBL_OrgLocationService] FOREIGN KEY ([OLS_ID]) REFERENCES [dbo].[GBL_OrgLocationService] ([OLS_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_OrgLocationService_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_OrgLocationService_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_OrgLocationService_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_OrgLocationService_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_OrgLocationService_Name] TO [cioc_login_role]
GO
