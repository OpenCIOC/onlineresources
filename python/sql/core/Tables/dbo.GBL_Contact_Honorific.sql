CREATE TABLE [dbo].[GBL_Contact_Honorific]
(
[Honorific] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Contact_Honorific] ADD CONSTRAINT [PK_GBL_Honorific] PRIMARY KEY CLUSTERED  ([Honorific]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_Contact_Honorific] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Contact_Honorific] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Contact_Honorific] TO [cioc_vol_search_role]
GO
