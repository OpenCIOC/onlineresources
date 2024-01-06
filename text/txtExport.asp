<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<%
Dim TXT_COMPRESSED, _
	TXT_EXCEL, _
	TXT_EXPORT_COMPLETE, _
	TXT_EXPORT_CONFIGURATION, _
	TXT_EXPORT_DISTRIBUTIONS, _
	TXT_EXPORT_FILE, _
	TXT_EXPORT_FINISHED_AT, _
	TXT_EXPORT_FORMAT, _
	TXT_EXPORT_PROCESSING, _
	TXT_EXPORT_STARTED_AT, _
	TXT_EXPORTING_RECORDS, _
	TXT_FILE_FORMAT, _
	TXT_INST_CUSTOMIZE, _
	TXT_INST_RECORD_PERMISSION, _
	TXT_INST_RECORD_PERMISSION_OWN, _
	TXT_INST_RECORD_PERMISSION_VIEW, _
	TXT_INST_SAVE_FILE, _
	TXT_NO_EXPORT_FORMAT, _
	TXT_NO_PROFILE, _
	TXT_NO_RECORDS_TO_EXPORT, _
	TXT_PROFILES_NOT_AVAILABLE_ALL_FORMATS, _
	TXT_RECORDS_TO_EXPORT, _
	TXT_SHARE_FORMAT, _
	TXT_STARTING_EXPORT, _
	TXT_UNCOMPRESSED, _
	TXT_VERSION, _
	TXT_MICROSOFT_XML

Sub setTxtExport()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_COMPRESSED = "Compressed"
			TXT_EXCEL = "Excel Spreadsheet"
			TXT_EXPORT_COMPLETE = "Export Complete!"
			TXT_EXPORT_CONFIGURATION = "Export Configuration"
			TXT_EXPORT_DISTRIBUTIONS = "Distributions"
			TXT_EXPORT_FILE = "Export File"
			TXT_EXPORT_FINISHED_AT = "Export Finished At" & TXT_COLON
			TXT_EXPORT_FORMAT = "Export Format"
			TXT_EXPORT_PROCESSING = "The export is currently processing. This may take some time..."
			TXT_EXPORT_STARTED_AT = "Export started at" & TXT_COLON
			TXT_EXPORTING_RECORDS = "Exporting Records"
			TXT_FILE_FORMAT = "File Format"
			TXT_INST_CUSTOMIZE = "Use this form to customize export options"
			TXT_INST_RECORD_PERMISSION = "Note: No matter which records you have chosen, the actual records you are allowed to export are constrained by your permissions. You are only allowed to export" & TXT_COLON
			TXT_INST_RECORD_PERMISSION_OWN = "records you own"
			TXT_INST_RECORD_PERMISSION_VIEW = "records in your View"
			TXT_INST_SAVE_FILE = "Right click the link below and select &quot;Save File As&quot; to download."
			TXT_NO_EXPORT_FORMAT = "No type of Export was chosen."
			TXT_NO_PROFILE = "You must select an export profile."
			TXT_NO_RECORDS_TO_EXPORT = "No records to export."
			TXT_PROFILES_NOT_AVAILABLE_ALL_FORMATS = "Some Export Profile fields may not be available in all formats."
			TXT_RECORDS_TO_EXPORT = " record(s) to export."
			TXT_SHARE_FORMAT = "CIOC Sharing Format (XML)"
			TXT_STARTING_EXPORT = "Starting Export"
			TXT_UNCOMPRESSED = "Uncompressed"
			TXT_VERSION = "Version #"
			TXT_MICROSOFT_XML = "Microsoft Saved Recordset (XML)"
		Case CULTURE_FRENCH_CANADIAN
			TXT_COMPRESSED = "Compressé"
			TXT_EXCEL = "Tableau Excel"
			TXT_EXPORT_COMPLETE = "L'export est terminé !"
			TXT_EXPORT_CONFIGURATION = "Configuration de l'export"
			TXT_EXPORT_DISTRIBUTIONS = "Distributions"
			TXT_EXPORT_FILE = "Fichier d'export"
			TXT_EXPORT_FINISHED_AT = "L'export s'est terminé à" & TXT_COLON
			TXT_EXPORT_FORMAT = "Format d'export"
			TXT_EXPORT_PROCESSING = "L'export est en cours. Veuillez patienter..."
			TXT_EXPORT_STARTED_AT = "L'export a commencé à" & TXT_COLON
			TXT_EXPORTING_RECORDS = "Export des dossiers"
			TXT_FILE_FORMAT = "Format de fichier"
			TXT_INST_CUSTOMIZE = "Utiliser ce formulaire pour personnaliser les options d'export"
			TXT_INST_RECORD_PERMISSION = "Remarque : quels que soient les dossiers sélectionnés, les seuls dossiers que vous pourrez exporter sont déterminés par vos droits d'accès. Vous n'êtes autorisé à exporter que" & TXT_COLON
			TXT_INST_RECORD_PERMISSION_OWN = "dossiers dont vous êtes propriétaire."
			TXT_INST_RECORD_PERMISSION_VIEW = "dossiers dans votre vue."
			TXT_INST_SAVE_FILE = "Faites un clic droit sur le lien ci-dessous et sélectionnez &quot;Sauvegarder le fichier sous&quot; pour le télécharger."
			TXT_NO_EXPORT_FORMAT = "Aucun format d'export n'a été sélectionné."
			TXT_NO_PROFILE = "Vous devez sélectionner un profil d'export."
			TXT_NO_RECORDS_TO_EXPORT = "Aucun dossier à exporter."
			TXT_PROFILES_NOT_AVAILABLE_ALL_FORMATS = "Certains champs du profil d'export peuvent ne pas être disponible dans tous les formats."
			TXT_RECORDS_TO_EXPORT = " dossier(s) à exporter."
			TXT_SHARE_FORMAT = "Format de partage CIOC (XML)"
			TXT_STARTING_EXPORT = "Démarrage de l'export"
			TXT_UNCOMPRESSED = "Non compressé"
			TXT_VERSION = "Version no. "
			TXT_MICROSOFT_XML = "Recordset Microsoft sauvegardé (XML)"
	End Select
End Sub

Call setTxtExport()
%>
