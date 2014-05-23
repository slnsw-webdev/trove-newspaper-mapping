<cfsetting requesttimeout="99999">

<cfhttp url="http://www2-dev.ad.sl.nsw.gov.au/apps/trove-newspaper-map/newspaperDataLatLong.xml">
<cfset xmlData = xmlparse(trim(cfhttp.FileContent))>

<cfset Newspapers = xmlSearch(xmlData,'/response/newspaper')>

<cfloop from="#arraylen(Newspapers)#" to="1" index="i" step="-1">
	
    
    <cfset town = xmlData.response.newspaper[i].town.XMLText>
    <cfset state = xmlData.response.newspaper[i].state.XMLText>
    
    <cfset address = town & ", " & state & ", Australia">
    
    <cfif len(address)>
    
      <cfoutput>Geo-ecoding ... #address# ... </cfoutput>
      
      <cftry>
          <!--- geoencode and update latLong --->
          <cfset api = "http://maps.googleapis.com/maps/api/geocode/json?address=#URLEncodedFormat(address)#&sensor=false">
          <cfhttp url="#api#" resolveurl="no" timeout="120"></cfhttp>
          <cfset response = DeserializeJSON(cfhttp.FileContent)>
          <cfset point = response["results"][1]["geometry"]["location"]>
          <cfset xmlData.response.newspaper[i].latlong.XMLText = trim(point.lat) & ',' & trim(point.lng)>
          <cfoutput>lat/long is ... #trim(point.lat)#,#trim(point.lng)#</cfoutput>
      <cfcatch>
          <cfoutput>Couldn't geo encode ... #address#<br /></cfoutput>
      </cfcatch>
      </cftry>
      
      <cfflush>
    
    </cfif>
    
    <!--- write out new xml file --->
	<cfset xmlString = toString(xmlData)>
	<cffile action="write" addnewline="yes" file="#getdirectoryfrompath(getbasetemplatepath())#newspaperDataLatLong.xml" output="#xmlString#" fixnewline="yes">
    
    <cfset sleep(2000)>

</cfloop>