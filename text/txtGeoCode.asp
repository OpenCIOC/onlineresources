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
Dim	TXT_ADDRESS_POSTAL_CODE, _
	TXT_CONTINUE_PROCESSING, _
	TXT_FIND_LOCATION, _
	TXT_GC_BLANK_NO_GEOCODE, _
	TXT_GC_CURRENT_SETTING, _
	TXT_GC_DONT_CHANGE, _
	TXT_GC_SITE_ADDRESS, _
	TXT_GC_INTERSECTION, _
	TXT_GC_MANUAL, _
	TXT_GEOCODE, _
	TXT_GEOCODE_ADDRESS_CHANGED, _
	TXT_GEOCODE_CODING, _
	TXT_GEOCODE_INTERSECTION_CHANGED, _
	TXT_GEOCODE_NO_MAP_KEY, _
	TXT_GEOCODE_MAP_KEY_FAIL, _
	TXT_GEOCODE_TOO_MANY_QUERIES, _
	TXT_GEOCODE_UNKNOWN_ADDRESS, _
	TXT_GEOCODE_UNKNOWN_ERROR, _
	TXT_GEOCODE_UPDATED, _
	TXT_GEOCODE_UPDATING, _
	TXT_GEOCODE_USING, _
	TXT_GEOCODED_WITHOUT_POSTAL, _
	TXT_INVALID_MISSING_LAT_LONG_DATA, _
	TXT_LATITUDE, _
	TXT_LONGITUDE, _
	TXT_LOCATED_NEAR, _
	TXT_MAP_MARKER, _
	TXT_REFRESH_MAP, _
	TXT_RESTART_PROCESSING, _
	TXT_RETRY_WITHOUT_POSTAL, _
	TXT_SAVING, _
	TXT_SELECTED_GEOCODING, _
	TXT_SERVER_ERROR, _
	TXT_SORT_BY_NEAREST, _
	TXT_SUCCESS, _
	TXT_UNCHANGED, _
	TXT_UPDATE_MAP

Sub setTxtGeoCode()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADDRESS_POSTAL_CODE = "Adresse ou code postal"
			TXT_CONTINUE_PROCESSING = "Poursuivre le traitement"
			TXT_FIND_LOCATION = "Trouver l'emplacement"
			TXT_GC_BLANK_NO_GEOCODE = "Aucune valeur (ne pas cartographier)"
			TXT_GC_CURRENT_SETTING = "Configuration du dossier courant"
			TXT_GC_DONT_CHANGE = "Ne pas mettre à jour la localisation géocodée (modifier uniquement la couleur du marqueur de carte)."
			TXT_GC_SITE_ADDRESS = "Adresse du site"
			TXT_GC_INTERSECTION = "Intersection"
			TXT_GC_MANUAL = "Placement cartographique manuel"
			TXT_GEOCODE = "Emplacement sur la carte"
			TXT_GEOCODE_ADDRESS_CHANGED = "L'adresse a changé mais le géocodage n'a pas été actualisé. Continuer la soumission ?"
			TXT_GEOCODE_CODING = "Géocodage"
			TXT_GEOCODE_INTERSECTION_CHANGED = "L'intersection a changé mais le géocodage n'a pas été actualisé. Continuer la soumission ?"
			TXT_GEOCODE_NO_MAP_KEY = "Le géocodage n'est pas disponible : il n'existe pas de clé API Google Maps pour ce domaine."
			TXT_GEOCODE_MAP_KEY_FAIL = "Erreur sur la clé Google Map. Contactez votre administrateur système."
			TXT_GEOCODE_TOO_MANY_QUERIES = "Il y a trop de requêtes Google. Essayer de nouveau plus tard."
			TXT_GEOCODE_UNKNOWN_ADDRESS = "Aucune localisation géographique correspondante n'a pu être trouvée pour l'adresse spécifiée. Cela peut être dû au fait que l'adresse est relativement nouvelle ou alors elle peut être incorrecte. "
			TXT_GEOCODE_UNKNOWN_ERROR = "Erreur à la requête de géocodage Google. Contactez votre administrateur système."
			TXT_GEOCODE_UPDATED = "Mis à jour"
			TXT_GEOCODE_UPDATING = "Mise à jour"
			TXT_GEOCODE_USING = "Placer le marqueur de carte en utilisant" & TXT_COLON
			TXT_GEOCODED_WITHOUT_POSTAL = "Emplacement géocodé sans utilisation du code postal."
			TXT_INVALID_MISSING_LAT_LONG_DATA = "Les données sur la latitude ou la longitude sont invalides ou manquantes."
			TXT_LATITUDE = "Latitude"
			TXT_LOCATED_NEAR = "Situé près de"
			TXT_LONGITUDE = "Longitude"
			TXT_MAP_MARKER = "Marqueur de carte"
			TXT_REFRESH_MAP = "Actualiser la carte"
			TXT_RESTART_PROCESSING = "Recommencer le traitement"
			TXT_RETRY_WITHOUT_POSTAL = "Si le géocodage par l'adresse échoue, essayez de nouveau sans le code postal."
			TXT_SAVING = "Sauvegarde"
			TXT_SELECTED_GEOCODING = "Mettre à jour le géocodage des dossiers sélectionnés"
			TXT_SERVER_ERROR = "Erreur serveur"
			TXT_SORT_BY_NEAREST = "Trier par ordre de proximité"
			TXT_SUCCESS = "Success"
			TXT_UNCHANGED = "Inchangé"
			TXT_UPDATE_MAP = "Mettre à jour la carte"
		Case Else
			TXT_ADDRESS_POSTAL_CODE = "Address or Postal Code"
			TXT_CONTINUE_PROCESSING = "Continue Processing"
			TXT_FIND_LOCATION = "Find Location"
			TXT_GC_BLANK_NO_GEOCODE = "No value (do not map)"
			TXT_GC_CURRENT_SETTING = "Current record setting"
			TXT_GC_DONT_CHANGE = "Don't update geocoded location (only change map pin colour)."
			TXT_GC_SITE_ADDRESS = "Site address"
			TXT_GC_INTERSECTION = "Intersection"
			TXT_GC_MANUAL = "Manual map placement"
			TXT_GEOCODE = "Map placement"
			TXT_GEOCODE_ADDRESS_CHANGED = "The address has changed but the geocode has not been refreshed. Continue submission?"
			TXT_GEOCODE_CODING = "Geocoding"
			TXT_GEOCODE_INTERSECTION_CHANGED = "The intersection has changed but the geocode has not been refreshed. Continue submission?"
			TXT_GEOCODE_NO_MAP_KEY = "Geocoding unavailable: there is no Google Maps API key for this domain."
			TXT_GEOCODE_MAP_KEY_FAIL = "Google Map Key Error. Contact your system administrator."
			TXT_GEOCODE_TOO_MANY_QUERIES = "Too many Google requests. Try again later."
			TXT_GEOCODE_UNKNOWN_ADDRESS = "No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect. "
			TXT_GEOCODE_UNKNOWN_ERROR = "Google geocoding request error. Contact your system administrator."
			TXT_GEOCODE_UPDATED = "Updated"
			TXT_GEOCODE_UPDATING = "Updating"
			TXT_GEOCODE_USING = "Place map marker using" & TXT_COLON
			TXT_GEOCODED_WITHOUT_POSTAL = "Geocoded location without using postal code."
			TXT_INVALID_MISSING_LAT_LONG_DATA = "Latitude and/or Longitude data is invalid or missing."
			TXT_LATITUDE = "Latitude"
			TXT_LOCATED_NEAR = "Located Near"
			TXT_LONGITUDE = "Longitude"
			TXT_MAP_MARKER = "Map Marker"
			TXT_REFRESH_MAP = "Refresh Map"
			TXT_RESTART_PROCESSING = "Restart Processing"
			TXT_RETRY_WITHOUT_POSTAL = "If geocode by address fails, retry without postal code."
			TXT_SAVING = "Saving"
			TXT_SELECTED_GEOCODING = "Update Geocoding on Selected Records"
			TXT_SERVER_ERROR = "Server Error"
			TXT_SORT_BY_NEAREST = "Sort by nearest"
			TXT_SUCCESS = "Success"
			TXT_UNCHANGED = "Unchanged"
			TXT_UPDATE_MAP = "Update Map"
	End Select
End Sub

Call setTxtGeoCode()
Call addTextFile("setTxtGeoCode")
%>
