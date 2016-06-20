CREATE TABLE [dbo].[VOL_Member_Renewal]
(
[VMR_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[VMEM_ID] [int] NOT NULL,
[RenewalDate] [smalldatetime] NOT NULL CONSTRAINT [DF_VOL_Member_Renwal_RenewalDate] DEFAULT (getdate()),
[VMINV_ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Renewal] ADD CONSTRAINT [PK_VOL_Member_Renewal] PRIMARY KEY CLUSTERED  ([VMR_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Renewal] ADD CONSTRAINT [IX_VOL_Member_Renewal_UniquePair] UNIQUE NONCLUSTERED  ([VMEM_ID], [RenewalDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VOL_Member_Renewal] ON [dbo].[VOL_Member_Renewal] ([VMR_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Renewal] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Member_Renewal_VOL_Member] FOREIGN KEY ([VMEM_ID]) REFERENCES [dbo].[VOL_Member] ([VMEM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Member_Renewal] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Member_Renewal_VOL_Member_Invoice] FOREIGN KEY ([VMINV_ID]) REFERENCES [dbo].[VOL_Member_Invoice] ([VMINV_ID]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Member_Renewal] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Member_Renewal] TO [cioc_vol_search_role]
GO
