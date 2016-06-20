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
Dim TXT_INST_PRINT_MAP, _
	TXT_LETTER_PORTRAIT, _
	TXT_LETTER_LANDSCAPE, _
	TXT_LEGAL_PORTRAIT, _
	TXT_LEGAL_LANDSCAPE, _
	TXT_PAPER_TYPE, _
	TXT_PRINT_MAP, _
	TXT_PRINT_MAP_TOO_MANY_RECORDS

Sub setTxtPrintMap()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_INST_PRINT_MAP = "<p>To print a map of your selected records, select a paper / size orientation and click <em>Next</em>.</p>" & _
				"<p class=""Alert"">Please note that:</p>" & _
				"<ul>" & _
				"	<li>This tool is not effective across large areas or with very large numbers of records. Map pins may overlap.</li>" & _
				"	<li>You should always preview the map and accompanying recordlist before printing, especially when using a new printer.</li>" & _
				"	<li>The layout for paper size / orientation is approximate. You may need to adjust your margins or turn on settings such as <em>Scale to Fit</em>.</li>" & _
				"	<li>You can <strong>drag or zoom the map</strong> before printing if desired.</li>" & _
				"	<li>It is possible to include unmappable records in the list. You should avoid selecting these records for printing if you do not want them in the list.</li>" & _
				"	<li class=""Alert"">You will probably need to turn on a setting in your print/page setup to <i>Print Background Colours / Images</i> to make the map icons print correctly.</li>" & _
				"	<li>Internet Explorer does not handle transparent images properly when printing, so a black box will appear around the map icons when printing.</li>" & _
				"</ul>"
			TXT_LETTER_PORTRAIT = "Letter - Portrait"
			TXT_LETTER_LANDSCAPE = "Letter - Landscape"
			TXT_LEGAL_PORTRAIT = "Legal - Portrait"
			TXT_LEGAL_LANDSCAPE = "Legal - Landscape"
			TXT_PAPER_TYPE = "Paper Type & Orientation"
			TXT_PRINT_MAP = "Print Map"
			TXT_PRINT_MAP_TOO_MANY_RECORDS = "Too many records"
		Case CULTURE_FRENCH_CANADIAN
			TXT_INST_PRINT_MAP = "<p>Pour imprimer une carte de vos dossiers sélectionnés, sélectionnez la taille et l'orientation du papier et cliquez sur <em>Suivant</em>.</p>" & _
				"<p class=""Alert"">Remarque :</p>" & _
				"<ul>" & _
				"	<li>Cet outil n'est pas adapté aux grandes zones géographiques ni aux grands nombres de dossiers. Les marqueurs de cartes peuvent se chevaucher.</li>" & _
				"	<li>Vous devriez toujours prévisualiser la carte et la liste des dossiers associés avant d'imprimer, surtout si vous utilisez une nouvelle imprimante.</li>" & _
				"	<li>La mise en page pour la taille ou l'orientation du papier est approximative. Vous pourriez avoir besoin d'ajuster vos marges ou d'activer des paramètres tels que <em>Mise à l'échelle</em>.</li>" & _
				"	<li>Vous pouvez <strong>déplacer ou zoomer sur la carte</strong> avant l'impression, si vous le souhaitez.</li>" & _
				"	<li>Il est possible d'inclure des dossiers ne pouvant être cartographiés dans la liste. Vous devriez éviter de sélectionner des dossiers pour l'impression si vous ne les voulez pas dans la liste.</li>" & _
				"	<li class=""Alert"">Vous aurez probablement besoin d'activer un paramètre dans la configuration de l'impression ou de la page afin d'<i>imprimer les couleurs et les images de fond</i>, afin que les icônes de la carte s'impriment correctement.</li>" & _
				"	<li>Internet Explorer ne gère pas correctement les images transparentes lors de l'impression : une boîte noire apparaîtra donc autours des icônes sur la carte à l'impression.</li>" & _
				"</ul>"
			TXT_LETTER_PORTRAIT = "Lettre - Portrait"
			TXT_LETTER_LANDSCAPE = "Lettre - Paysage"
			TXT_LEGAL_PORTRAIT = "Légal - Portrait"
			TXT_LEGAL_LANDSCAPE = "Légal - Paysage"
			TXT_PAPER_TYPE = "Type et orientation du papier"
			TXT_PRINT_MAP = "Imprimer la carte"
			TXT_PRINT_MAP_TOO_MANY_RECORDS = "Trop de dossiers"
	End Select
End Sub

Call setTxtPrintMap()
%>
