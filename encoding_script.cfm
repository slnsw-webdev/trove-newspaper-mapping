<!--- read in xml --->
<cfhttp url="http://www2-dev.ad.sl.nsw.gov.au/apps/trove-newspaper-map/newspapers.xml">
<cfset xmlData = xmlparse(trim(cfhttp.FileContent))>

<!--- ok read in csv file of data with lat / long's --->
<cfhttp name="latLongData"
        url="http://www2-dev.ad.sl.nsw.gov.au/apps/trove-newspaper-map/data/Australian_Post_Codes_Lat_Lon.csv"
        firstRowAsHeaders="true"
        method="get" />
 
<!---<cfdump var="#latLongData#" />--->

<!--- now loop through the xml and add in the town, post code and lat / long values for those items that match --->

<!--- get an array of book nodes using xmlSearch --->
<cfset Newspapers = xmlSearch(xmlData,'/response/newspaper')>

<!--- loop through the array and output the data --->
<cfoutput>

<cfset missedItems = 0>

<cfloop from="1" to="#arraylen(Newspapers)#" index="i">

	<!--- add elements into xml node at this position --->
	<cfset ArrayInsertAt(xmlData.response.newspaper[i].XmlChildren, 3, XmlElemNew(xmlData, "town"))>
    <cfset ArrayInsertAt(xmlData.response.newspaper[i].XmlChildren, 4, XmlElemNew(xmlData, "postcode"))>
    <cfset ArrayInsertAt(xmlData.response.newspaper[i].XmlChildren, 5, XmlElemNew(xmlData, "latlong"))>
	
    <cfset matchFound = false>
	<cfset newspaperXML = xmlparse(Newspapers[i])>
    <cfset title = newspaperXML.newspaper.title.XmlText>
    <cfset titleItems = listtoarray(title, " ", false)>
    
    <cfloop from="1" to="#arraylen(titleItems)#" index="a">
    	
        <cfset titleCleaned = Replace(titleItems[a], "(", "", "All")>
         <cfset titleCleaned = Replace(titleCleaned, ")", "", "All")>
        <cfset titleCleaned = Replace(titleCleaned, ",", "", "All")>
        
        <cfif not matchFound>
          <cfquery name="getData" dbtype="query">
              select * from latLongData
              where suburb like '#ucase(titleCleaned)#%'
          </cfquery>
          <cfif getData.recordcount>
          	<cfset matchFound = true>  
            <cfbreak>
          </cfif>
        </cfif>
    
    </cfloop>
    
    <cfif not matchFound>
    
    	#title#<br />
    	<cfset missedItems++>
    <cfelse>
    	
        
        <cfset xmlData.response.newspaper[i].town.XMLText = trim(getData.suburb)>
        <cfset xmlData.response.newspaper[i].postcode.XMLText = trim(getData.postcode)>
	    <cfset xmlData.response.newspaper[i].latlong.XMLText = trim(getData.lat) & ',' & trim(getData.lon)>
    
    </cfif>
    
</cfloop>

<cfdump var="#missedItems#">

</cfoutput>

<!--- write out new xml file --->
<cfset xmlString = toString(xmlData)>
<cffile action="write" addnewline="yes" file="#getdirectoryfrompath(getbasetemplatepath())#newspaperDataLatLong.xml" output="#xmlString#" fixnewline="yes">

