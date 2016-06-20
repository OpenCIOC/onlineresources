CREATE TABLE [dbo].[VOL_SecurityLevel_ExternalAPI]
(
[SL_ID] [int] NOT NULL,
[API_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_ExternalAPI] ADD CONSTRAINT [PK_VOL_SecurityLevel_ExternalAPI] PRIMARY KEY CLUSTERED  ([SL_ID], [API_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_ExternalAPI] ADD CONSTRAINT [FK_VOL_SecurityLevel_ExternalAPI_GBL_ExternalAPI] FOREIGN KEY ([API_ID]) REFERENCES [dbo].[GBL_ExternalAPI] ([API_ID])
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_ExternalAPI] ADD CONSTRAINT [FK_VOL_SecurityLevel_ExternalAPI_VOL_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[VOL_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
