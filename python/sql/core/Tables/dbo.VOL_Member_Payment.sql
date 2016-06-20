CREATE TABLE [dbo].[VOL_Member_Payment]
(
[VMPMT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[VMINV_ID] [int] NOT NULL,
[PaymentDate] [smalldatetime] NOT NULL,
[PaymentAmount] [decimal] (9, 2) NOT NULL,
[PaymentVoid] [bit] NOT NULL CONSTRAINT [DF_VOL_Member_Payment_PaymentVoid] DEFAULT ((0)),
[Notes] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Payment] ADD CONSTRAINT [PK_VOL_Member_Payment] PRIMARY KEY CLUSTERED  ([VMPMT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Payment] ADD CONSTRAINT [FK_VOL_Member_Payment_VOL_Member_Invoice] FOREIGN KEY ([VMINV_ID]) REFERENCES [dbo].[VOL_Member_Invoice] ([VMINV_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Member_Payment] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Member_Payment] TO [cioc_vol_search_role]
GO
