<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:lido="http://www.lido-schema.org"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:oai="http://www.openarchives.org/OAI/2.0/">
  <xsl:output method="xml" encoding="UTF-16" indent="yes"/>
  <xsl:param name="data_language"/>
  <xsl:param name="ui_language"/>
  <xsl:param name="display_language">
    <xsl:choose>
      <xsl:when
        test="$data_language = 'de-DE' or data_language = 'en-US' or $data_language = 'fr-FR' or $data_language = 'nl-NL'">
        <xsl:value-of select="$data_language"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$ui_language = 1">nl</xsl:when>
          <xsl:when test="$ui_language = 2">fr</xsl:when>
          <xsl:when test="$ui_language = 3">de</xsl:when>
          <xsl:otherwise>en</xsl:otherwise>
        </xsl:choose>
        <!--<xsl:text>de-DE</xsl:text>-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Authored by Richard Martin (Royal College of Music Museum), based on the adlibXML to LIDO transformation XSLT -->

  <!-- 
  
  **************  adlibXML to MIMO transformation  **************************************
  
  History:
  
  2015-03-16 REM  Integration of static OAI-PMH
  
  2014-03-11 REM  Updates per MIMO feedback - fixed multi-inscriptions, typo in lido:objectDescriptionSet
  
  2014-11-17 REM  Revisions to adlibXML2LIDO XSLT. Used to transform data 
                  on RCM Museum Adlib system to LIDO XML ready for MIMO.

  ***************************************************************************************
  -->
  <!-- 
  
  **************  adlibXML to LIDO transformation  **************************************

  History:
  2014-05-02 KB   Replaced all occurrences of @value with @option (neutral value)
                  Fixed problems with spaces in all possible occurrences of lido:displayDate
                  Added required sub-element lido:eventType to lido:subjectEvent
                  Added requrired attribute lido:type to lido:objectID
  2014-04-30 KB   Added missing template for "association.subject.type|content.subject.type" mode="subject"
                  and also fixed both apply statements (cf. bug #6484)
  2013-12-06 KB   Changed lido:eventType/lido:term to "Production"
                  lido:objectMeasurements will be repeated only if dimension.value isn't empty
  2013-12-05 KB   Added lido:repositoryWrap and lido:resourceWrap
                  Disabled mappings for multilingual field contents
                  Only first 'Production_date' group will be matched, however, all production
                  dates will be merged into lido:displayDate
  2013-05-02 KB   Upgraded to lido v1.0 and grouped adlibXML as exported by Adlib 7.1
  2013-02-02 KB   Added parameters for user interface and data language
  2011-04-12 KB   Added mapping for iconographic content and associations
  2011-03-28 KB   Added mapping for description, measurements and creation event (i.e. creator,
                  production place, production date and period, material and technique)
  2011-03-01 KB   Added conditional mapping of object name to lido:titleWrap and
                  title to lido:objectWorkTypeWrap; titles and object names can be repeated
  2011-01-20 KB   Iniital coding
  
  ***************************************************************************************
  -->

  <xsl:template match="/">
    <xsl:apply-templates select="adlibXML"/>   <!-- 1. Define [adlibXML] as source for data -->
  </xsl:template>
  <xsl:template match="adlibXML">
  <Repository xmlns="http://www.openarchives.org/OAI/2.0/static-repository"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/static-repository
    http://www.openarchives.org/OAI/2.0/static-repository.xsd">
    <Identify> <!-- 2. Identify Royal College of Music as data source -->
      <oai:repositoryName>Royal College of Music Museum</oai:repositoryName>
      <oai:baseURL>http://www.rcm.ac.uk/mimo/RCMtoMIMO20150207.xml</oai:baseURL>
      <oai:protocolVersion>2.0</oai:protocolVersion>
      <oai:adminEmail>museum@rcm.ac.uk</oai:adminEmail>
      <oai:earliestDatestamp>2015-02-17</oai:earliestDatestamp>
      <oai:deletedRecord>no</oai:deletedRecord>
      <oai:granularity>YYYY-MM-DD</oai:granularity>
    </Identify>
    <ListMetadataFormats> <!-- 3. Standard metadata formats for MIMO data supply -->
      <oai:metadataFormat>
        <oai:metadataPrefix>oai_dc</oai:metadataPrefix>
        <oai:schema> http://www.openarchives.org/OAI/2.0/oai_dc.xsd </oai:schema>
        <oai:metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</oai:metadataNamespace>
      </oai:metadataFormat>
      <oai:metadataFormat>
        <oai:metadataPrefix>lido</oai:metadataPrefix>
        <oai:schema>http://www.lido-schema.org lido-v1-0.xsd</oai:schema>
        <oai:metadataNamespace>http://www.lido-schema.org</oai:metadataNamespace>
      </oai:metadataFormat>
    </ListMetadataFormats>
    <ListRecords> <!-- 4. Umbrella for all records exported from Adlib [recordList] -->
      <xsl:attribute name="metadataPrefix">lido</xsl:attribute>
      <xsl:apply-templates select="recordList"/>     
    </ListRecords> 
  </Repository>
  </xsl:template>
  <xsl:template match="recordList">
    <xsl:apply-templates select="record"/>
  </xsl:template>
  <xsl:template match="record"> <!-- 5. Individual Adlib [record], in this case individual instrument records -->
    <oai:record>
      <oai:header>
        <oai:identifier><xsl:value-of select="object_number"/></oai:identifier> <!-- 6. Use inventory number as [oai:identifier] -->
        <oai:datestamp>2015-02-17</oai:datestamp> <!-- [note: datestamp strings to be code-generated in future update] -->
      </oai:header>
      <oai:metadata>
        <lido:lidoWrap xmlns="http://www.openarchives.org/OAI/2.0/"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org">
          <xsl:attribute name="xsi:schemaLocation">http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd</xsl:attribute>
    <lido:lido>
      <lido:lidoRecID lido:type="local">
        <xsl:text>RCM:</xsl:text>
        <xsl:value-of select="priref"/> <!-- 7. unique Adlib identifier inserted here -->
      </lido:lidoRecID>
      <lido:descriptiveMetadata>
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$display_language"/>
        </xsl:attribute>
        <lido:objectClassificationWrap>
          <lido:objectWorkTypeWrap>
            <lido:objectWorkType>
              <lido:term>musical instruments</lido:term> <!-- note: [objectWorkType] is always musical instruments for MIMO -->
            </lido:objectWorkType>
          </lido:objectWorkTypeWrap>
          <lido:classificationWrap>
            <lido:classification>
              <lido:term>
                <xsl:value-of select="object_name"/> <!-- 8. Insert object classification (e.g. violin, harpsichord etc.) -->
              </lido:term></lido:classification>
            <lido:classification>
              <lido:conceptID lido:type="SH_Class">
                <xsl:value-of select="object_category"/> <!-- 9. Insert Hornbostel-Sachs classification -->
              </lido:conceptID>
            </lido:classification>
          </lido:classificationWrap>
        </lido:objectClassificationWrap>
        <lido:objectIdentificationWrap>
          <lido:titleWrap>
            <lido:titleSet>
              <lido:appellationValue><xsl:value-of select="object_name"/></lido:appellationValue> <!-- 10. Insert object name -->
            </lido:titleSet>
          </lido:titleWrap>
          <lido:inscriptionsWrap>         
                <xsl:apply-templates select="inscription.description"/> <!-- 11. Insert all free text inscription fields -->
          </lido:inscriptionsWrap>
          <lido:repositoryWrap> 
            <lido:repositorySet>
              <lido:repositoryName>
                <lido:legalBodyName>
                  <lido:appellationValue>Royal College of Music Museum</lido:appellationValue> <!-- 12. Legal body name is always [Royal College of Music Museum] -->
                </lido:legalBodyName>
              </lido:repositoryName>
              <lido:workID lido:type="inventory number"><xsl:value-of select="object_number"/></lido:workID> <!-- 13. Insert RCM inventory number -->
            </lido:repositorySet>
          </lido:repositoryWrap>
          <lido:objectDescriptionWrap>
            <lido:objectDescriptionSet lido:type="general description">
              <lido:descriptiveNoteValue><xsl:value-of select="description"/></lido:descriptiveNoteValue> <!-- 14. Insert instrument description -->
            </lido:objectDescriptionSet>
          </lido:objectDescriptionWrap>
          <lido:objectMeasurementsWrap>
            <lido:objectMeasurementsSet>
              <lido:displayObjectMeasurements><xsl:value-of select="dimension.free"/></lido:displayObjectMeasurements> <!-- 15. Insert dimensions free text field -->
            </lido:objectMeasurementsSet>
          </lido:objectMeasurementsWrap>
        </lido:objectIdentificationWrap>
        <lido:eventWrap>
          <lido:eventSet>
            <lido:event>
              <lido:eventType>
                <lido:term xml:lang="en">production</lido:term> <!-- 16. Production event as standard event content -->
              </lido:eventType>
              <lido:eventActor>
                <lido:actorInRole>
                  <lido:actor>
                    <xsl:attribute name="lido:type"><xsl:value-of select="creator.qualifier"/></xsl:attribute> <!-- 17. Insert creator role (usually 'maker') -->
                    <lido:nameActorSet>
                      <lido:appellationValue><xsl:value-of select="creator"/></lido:appellationValue> <!-- 18. Insert creator/maker name -->
                    </lido:nameActorSet>
                  </lido:actor>
                  <lido:roleActor>
                    <lido:term>instrument maker</lido:term> <!-- 19. Standard role is instrument maker -->
                  </lido:roleActor>
                </lido:actorInRole>
              </lido:eventActor>
              <lido:eventDate>
                <lido:displayDate></lido:displayDate> <!-- [displayDate] to be fixed: output will depend on date ranges and text strings -->
               <lido:date>
                 <lido:earliestDate><xsl:value-of select="production.date.start.prec"/><xsl:text> </xsl:text><xsl:value-of select="production.date.start"/></lido:earliestDate> <!-- 20. Insert production dates - includes scope for qualifiers such as 'post', 'ante', 'circa' -->
                 <lido:latestDate><xsl:value-of select="production.date.end.prec"/><xsl:text> </xsl:text><xsl:value-of select="production.date.end"/></lido:latestDate> 
               </lido:date> 
              </lido:eventDate>
              <lido:periodName>
                <lido:term><xsl:value-of select="production.period"/></lido:term> <!-- 21. Insert production period (e.g. mid 18th century, late 19th century) -->
              </lido:periodName>
              <lido:eventPlace>
                <lido:displayPlace><xsl:value-of select="production.place"/></lido:displayPlace> <!-- 22. Insert production place (e.g. Vienna, Paris, London, Germany) -->
              </lido:eventPlace>
            </lido:event>
          </lido:eventSet>
        </lido:eventWrap> 
      </lido:descriptiveMetadata>
      <lido:administrativeMetadata>
        <xsl:attribute name="xml:lang">en</xsl:attribute>
        <lido:recordWrap>
          <lido:recordID>
            <xsl:attribute name="lido:type">local</xsl:attribute>
            <xsl:value-of select="priref"/> <!-- 23. Insert unique Adlib record identifer -->
          </lido:recordID>
          <lido:recordType>
            <lido:term>item</lido:term> <!-- [recordType] is always 'item' -->
          </lido:recordType>
          <lido:recordSource>
            <lido:legalBodyID lido:type="local">GB-Lcm</lido:legalBodyID> <!-- RCM legal body ID -->
          </lido:recordSource>
        </lido:recordWrap>
        <!-- Re: [resourceWrap], RCM is currently supplying one image only to MIMO 
          for each instrument, hence the object number is used as the image filename for simplicity. Section to be updated -->
        <lido:resourceWrap>
          <lido:resourceSet>
            <lido:resourceID>
              <xsl:attribute name="lido:type">local</xsl:attribute><xsl:value-of select="object_number"/><xsl:text>.jpg</xsl:text></lido:resourceID>
            <lido:resourceType>
              <lido:term>image</lido:term>
            </lido:resourceType>
          </lido:resourceSet>
        </lido:resourceWrap>
      </lido:administrativeMetadata>
    </lido:lido></lido:lidoWrap>
      </oai:metadata>   
    </oai:record>
  </xsl:template>

<!-- END --> 


<!-- TEMPLATES - MOST NOT CURRENTLY USED BUT AVAILABLE FOR FUTURE LIDO IMPLEMENTATION -->

  <!-- 
  **************   adlib fields   *****************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="Associated_period">
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">association</xsl:attribute>
        <lido:subjectDate>
          <lido:displayDate>
            <xsl:value-of select="association.period/term"/>
          </lido:displayDate>
          <xsl:apply-templates select="association.period.date.start[. != '']"/>
        </lido:subjectDate>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="association.period.date.start|content.date.start">
    <lido:date>
      <lido:earliestDate>
        <xsl:value-of select="."/>
      </lido:earliestDate>
      <lido:latestDate>
        <xsl:value-of select="../association.period.date.end"/>
        <xsl:value-of select="../content.date.end"/>
      </lido:latestDate>
    </lido:date>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="Associated_person">
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">association</xsl:attribute>
        <lido:subjectActor>
          <lido:actor>
            <xsl:apply-templates select="association.person.type[. != '']"/>
            <lido:nameActorSet>
              <lido:appellationValue>
                <xsl:value-of select="association.person/name"/>
              </lido:appellationValue>
            </lido:nameActorSet>
          </lido:actor>
        </lido:subjectActor>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="association.person.type|content.person.name.type">
    <xsl:attribute name="lido:type">
      <xsl:value-of select="text[@language='0']"/>
    </xsl:attribute>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="Associated_subject">
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">association</xsl:attribute>
        <xsl:apply-templates select="association.subject.type[@option='EVENT']" mode="event"/>
        <xsl:apply-templates
          select="association.subject.type[@option='ANIMAL' or @option='OBJECT' or @option='PLANT']"
          mode="object"/>
        <xsl:apply-templates select="association.subject.type[@option='GEOKEYW']" mode="place"/>
        <xsl:apply-templates
          select="association.subject.type[@option='' or @option='ACTIV' or @option='CONCEPT' or @option='SUBJECT']"
          mode="subject"/>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="association.subject.type|content.subject.type" mode="event">
    <lido:subjectEvent>
      <lido:event>
        <lido:eventType>
          <lido:term>Event (non-specified)</lido:term>
        </lido:eventType>
        <lido:eventName>
          <lido:appellationValue>
            <xsl:value-of select="../association.subject/term"/>
            <xsl:value-of select="../content.subject/term"/>
          </lido:appellationValue>
        </lido:eventName>
      </lido:event>
    </lido:subjectEvent>
  </xsl:template>
  
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="association.subject.type|content.subject.type" mode="object">
    <lido:subjectObject>
      <lido:displayObject>
        <xsl:value-of select="../association.subject/term"/>
        <xsl:value-of select="../content.subject/term"/>
      </lido:displayObject>
      <xsl:apply-templates select="../content.subject.identifier[. != '']"/>
    </lido:subjectObject>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="association.subject.type|content.subject.type" mode="place">
    <lido:subjectPlace>
      <lido:place>
        <lido:namePlaceSet>
          <lido:appellationValue>
            <xsl:value-of select="../association.subject/term"/>
            <xsl:value-of select="../content.subject/term"/>
          </lido:appellationValue>
        </lido:namePlaceSet>
      </lido:place>
    </lido:subjectPlace>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="association.subject.type|content.subject.type" mode="subject">
    <lido:subjectConcept>
      <lido:term>
        <xsl:value-of select="../association.subject/term"/>
        <xsl:value-of select="../content.subject/term"/>
      </lido:term>
    </lido:subjectConcept>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="content.classification.code">
    <xsl:variable name="pos">
      <xsl:value-of select="position()"/>
    </xsl:variable>
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">iconographic content</xsl:attribute>
        <lido:subjectConcept>
          <lido:conceptID>
            <xsl:attribute name="lido:type">ID</xsl:attribute>
            <xsl:apply-templates select="../content.classification.scheme[position() = $pos]"/>
            <xsl:value-of select="."/>
          </lido:conceptID>
        </lido:subjectConcept>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="content.classification.scheme">
    <xsl:attribute name="lido:source">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="content.date.period">
    <xsl:variable name="pos">
      <xsl:value-of select="position()"/>
    </xsl:variable>
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">iconographic content</xsl:attribute>
        <xsl:apply-templates select="../content.date.position[position() = $pos]"/>
        <lido:subjectDate>
          <lido:displayDate>
            <xsl:value-of select="term"/>
          </lido:displayDate>
          <xsl:apply-templates select="../content.date.start[position() = $pos]"/>
        </lido:subjectDate>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="content.date.position|content.person.position|content.subject.position">
    <lido:extentSubject>
      <xsl:value-of select="."/>
    </lido:extentSubject>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="Content_person">
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">iconographic content</xsl:attribute>
        <xsl:apply-templates select="content.person.position[. != '']"/>
        <lido:subjectActor>
          <lido:actor>
            <xsl:apply-templates select="content.person.name.type[. != '']"/>
            <lido:nameActorSet>
              <lido:appellationValue>
                <xsl:value-of select="content.person.name/name"/>
              </lido:appellationValue>
            </lido:nameActorSet>
          </lido:actor>
        </lido:subjectActor>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="Content_subject">
    <lido:subjectSet>
      <lido:subject>
        <xsl:attribute name="lido:type">iconographic content</xsl:attribute>
        <xsl:apply-templates select="content.subject.position[. != '']"/>
        <xsl:apply-templates select="content.subject.type[@option='EVENT']" mode="event"/>
        <xsl:apply-templates
          select="content.subject.type[@option='ANIMAL' or @option='OBJECT' or @option='PLANT']"
          mode="object"/>
        <xsl:apply-templates select="content.subject.type[@option='GEOKEYW']" mode="place"/>
        <xsl:apply-templates
          select="content.subject.type[@option='' or @option='ACTIV' or @option='CONCEPT' or @option='SUBJECT']"
          mode="subject"/>
      </lido:subject>
    </lido:subjectSet>
  </xsl:template>
  
  <!-- *****
  ********************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="content.subject.identifier">
    <lido:object>
      <lido:objectID lido:type="local">
        <xsl:value-of select="."/>
      </lido:objectID>
    </lido:object>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- not currently used -->
  <xsl:template match="creator">
    <lido:eventActor>
      <lido:actorInRole>
        <lido:actor>
          <lido:nameActorSet>
            <lido:appellationValue>
              <xsl:value-of select="name"/>
            </lido:appellationValue>
          </lido:nameActorSet>
          <xsl:apply-templates
            select="../creator.date_of_birth[. != '' or creator.date_of_death != '']"
            mode="vitalDatesActor"/>
        </lido:actor>
        <xsl:apply-templates select="../creator.role[. != '']"/>
        <xsl:apply-templates select="../creator.qualifier[. != '']"/>
      </lido:actorInRole>
    </lido:eventActor>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="creator.date_of_birth" mode="vitalDatesActor">
    <lido:vitalDatesActor>
      <xsl:apply-templates select="../creator.date_of_birth[. != '']"/>
      <xsl:apply-templates select="../creator.date_of_death[. != '']"/>
    </lido:vitalDatesActor>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="creator.date_of_birth">
    <lido:earliestDate>
      <xsl:attribute name="lido:type">birthDate</xsl:attribute>
      <xsl:value-of select="."/>
    </lido:earliestDate>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="creator.date_of_death">
    <lido:latestDate>
      <xsl:attribute name="lido:type">deathDate</xsl:attribute>
      <xsl:value-of select="."/>
    </lido:latestDate>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="creator.qualifier">
    <lido:attributionQualifierActor>
      <xsl:value-of select="."/>
    </lido:attributionQualifierActor>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="creator.role">
    <lido:roleActor>
      <lido:term>
        <xsl:value-of select="term"/>
      </lido:term>
    </lido:roleActor>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Description">
    <lido:objectDescriptionSet>
      <xsl:attribute name="lido:type">general description</xsl:attribute>
      <lido:descriptiveNoteValue>
        <xsl:value-of select="description"/>
      </lido:descriptiveNoteValue>
      <xsl:apply-templates select="description.name"/>
    </lido:objectDescriptionSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="description.name">
    <lido:sourceDescriptiveNote>
      <xsl:value-of select="."/>
    </lido:sourceDescriptiveNote>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Dimension[last()]">
    <lido:measurementsSet>
      <lido:measurementType>
        <xsl:value-of select="dimension.type/term"/>
      </lido:measurementType>
      <lido:measurementUnit>
        <xsl:value-of select="dimension.unit/term"/>
      </lido:measurementUnit>
      <lido:measurementValue>
        <xsl:value-of select="dimension.value"/>
      </lido:measurementValue>
    </lido:measurementsSet>
    <xsl:apply-templates select="dimension.precision[. != '']"/>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Dimension[position() &lt; last()]">
    <lido:measurementsSet>
      <lido:measurementType>
        <xsl:value-of select="dimension.type/term"/>
      </lido:measurementType>
      <lido:measurementUnit>
        <xsl:value-of select="dimension.unit/term"/>
      </lido:measurementUnit>
      <lido:measurementValue>
        <xsl:value-of select="dimension.value"/>
      </lido:measurementValue>
    </lido:measurementsSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="dimension.free">
    <lido:displayObjectMeasurements>
      <xsl:value-of select="."/>
    </lido:displayObjectMeasurements>
  </xsl:template>

  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="dimension.precision">
    <lido:qualifierMeasurements>
      <xsl:value-of select="."/>
    </lido:qualifierMeasurements>
  </xsl:template>
  
  <!-- 
  *************************************************************
  -->
  
  <xsl:template match="inscription.description">
    <lido:inscriptions>
      <lido:inscriptionDescription>
        <lido:descriptiveNoteValue><xsl:value-of select="." /></lido:descriptiveNoteValue>
      </lido:inscriptionDescription>
    </lido:inscriptions>
  </xsl:template>
  <!--********************************************************
  -->
  
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="institution.code">
    <xsl:value-of select="."/>
    <xsl:text>/</xsl:text>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="institution.code" mode="legalBodyID">
    <lido:legalBodyID>
      <xsl:attribute name="lido:type">local</xsl:attribute>
      <xsl:value-of select="."/>
    </lido:legalBodyID>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="institution.name">
    <xsl:attribute name="lido:source">
      <xsl:value-of select="name"/>
    </xsl:attribute>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="institution.name" mode="legalBody">
    <xsl:apply-templates select="../institution.code" mode="legalBodyID"/>
    <lido:legalBodyName>
      <lido:appellationValue>
        <xsl:value-of select="name"/>
      </lido:appellationValue>
    </lido:legalBodyName>
    <!--<lido:legalBodyWeblink>
    </lido:legalBodyWeblink>-->
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="institution.place">
    <lido:repositoryLocation>
      <lido:namePlaceSet>
        <lido:appellationValue>
          <xsl:value-of select="."/>
        </lido:appellationValue>
      </lido:namePlaceSet>
    </lido:repositoryLocation>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Material">
    <lido:eventMaterialsTech>
      <xsl:apply-templates select="material[. != '']"/>
      <xsl:apply-templates select="material.notes[. != '' and ../material = '']"/>
    </lido:eventMaterialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="material">
    <lido:materialsTech>
      <lido:termMaterialsTech>
        <xsl:attribute name="lido:type">material</xsl:attribute>
        <lido:term>
          <xsl:value-of select="term"/>
        </lido:term>
      </lido:termMaterialsTech>
      <xsl:apply-templates select="../material.part[. != '']"/>
    </lido:materialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="material.notes">
    <lido:displayMaterialsTech>
      <xsl:value-of select="."/>
    </lido:displayMaterialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="material.part">
    <lido:extentMaterialsTech>
      <xsl:value-of select="."/>
    </lido:extentMaterialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="oai_ID">
    <oai:identifier><xsl:value-of select="/adlibXML/recordList/record/object_number/."/></oai:identifier>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="object_category">
    <lido:classification>
      <xsl:attribute name="lido:type">object category</xsl:attribute>
      <lido:term>
        <xsl:value-of select="term"/>
      </lido:term>
    </lido:classification>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="object_name">
    <lido:objectWorkType>
      <lido:conceptID>
        <xsl:attribute name="lido:type">object name</xsl:attribute>
      </lido:conceptID>
      <lido:term>
        <xsl:value-of select="term"/>
        <!--<xsl:value-of select="value[@lang=$display_language or @lang='']" />-->
      </lido:term>
    </lido:objectWorkType>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="object_name" mode="titleWrap">
    <lido:titleSet>
      <lido:appellationValue>
        <xsl:value-of select="term"/>
        <!--<xsl:value-of select="value[@lang=$display_language or @lang='']" />-->
      </lido:appellationValue>
    </lido:titleSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  
  <!-- 
  *************************************************************
  -->
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="object_type">
    <lido:objectWorkType>
      <xsl:attribute name="lido:term">musical instruments</xsl:attribute>
    </lido:objectWorkType>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="physical_description">
    <lido:objectDescriptionSet>
      <xsl:attribute name="lido:type">physical description</xsl:attribute>
      <lido:descriptiveNoteValue>
        <xsl:value-of select="."/>
      </lido:descriptiveNoteValue>
    </lido:objectDescriptionSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Production">
    <xsl:apply-templates select="creator"/>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="production.period">
    <lido:periodName>
      <lido:term>
        <xsl:value-of select="term"/>
      </lido:term>
    </lido:periodName>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="production.place">
    <lido:eventPlace>
      <lido:place>
        <lido:namePlaceSet>
          <lido:appellationValue>
            <xsl:value-of select="term"/>
          </lido:appellationValue>
        </lido:namePlaceSet>
      </lido:place>
    </lido:eventPlace>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Production_date">
    <lido:eventDate>
      <lido:displayDate>
        <xsl:apply-templates select="../Production_date" mode="display"/>
      </lido:displayDate>
      <lido:date>
        <lido:earliestDate>
          <xsl:value-of select="production.date.start"/>
        </lido:earliestDate>
        <lido:latestDate>
          <xsl:value-of select="production.date.end"/>
        </lido:latestDate>
      </lido:date>
    </lido:eventDate>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Production_date" mode="display">
    <xsl:if test="position() > 1">
      <xsl:text> / </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="production.date.start.prec[. != '']"/>
    <xsl:value-of select="substring(production.date.start, 1, 4)"/>
    <xsl:if
      test="production.date.end and substring(production.date.start, 1, 4) != substring(production.date.end, 1, 4)">
      <xsl:choose>
        <xsl:when
          test="number(substring(production.date.end, 1, 4)) - number(substring(production.date.start, 1, 4)) = 1">
          <xsl:text>/</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> – </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="production.date.end.prec[. != '']"/>
      <xsl:value-of select="substring(production.date.end, 1, 4)"/>
    </xsl:if>
  </xsl:template>
  <!--
  ===========================================================================
  -->
  <!-- not currently used -->
  <xsl:template match="production.date.end.prec">
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
  </xsl:template>
  <!--
  ===========================================================================
  -->
  <!-- not currently used -->
  <xsl:template match="production.date.start.prec">
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Reproduction">
    <lido:resourceSet>
      <lido:resourceID>
        <xsl:attribute name="lido:type">local</xsl:attribute>
        <xsl:value-of select="reproduction.reference/reference_number"/>
      </lido:resourceID>
      <xsl:apply-templates select="reproduction.type[. != '']"/>
    </lido:resourceSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="reproduction.type">
    <lido:resourceType>
      <lido:term>
        <xsl:value-of select="."/>
      </lido:term>
    </lido:resourceType>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Rights">
    <lido:rightsWorkSet>
      <lido:rightsType>
        <lido:term>
          <xsl:value-of select="rights.type/term"/>
        </lido:term>
      </lido:rightsType>
      <xsl:apply-templates select="rights.holder[name != '']"/>
      <lido:creditLine>
        <xsl:value-of select="rights.notes"/>
      </lido:creditLine>
    </lido:rightsWorkSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="rights.holder">
    <lido:rightsHolder>
      <lido:legalBodyName>
        <lido:appellationValue>
          <xsl:value-of select="name"/>
        </lido:appellationValue>
      </lido:legalBodyName>
    </lido:rightsHolder>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="Technique">
    <lido:eventMaterialsTech>
      <xsl:apply-templates select="technique[. != '']"/>
      <xsl:apply-templates select="technique.notes[. != '' and ../technique = '']"/>
    </lido:eventMaterialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="technique">
    <lido:materialsTech>
      <lido:termMaterialsTech>
        <xsl:attribute name="lido:type">technique</xsl:attribute>
        <lido:term>
          <xsl:value-of select="term"/>
        </lido:term>
      </lido:termMaterialsTech>
      <xsl:apply-templates select="../technique.part[. != '']"/>
    </lido:materialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="technique.notes">
    <lido:displayMaterialsTech>
      <xsl:value-of select="."/>
    </lido:displayMaterialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="technique.part">
    <lido:extentMaterialsTech>
      <xsl:value-of select="."/>
    </lido:extentMaterialsTech>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="title">
    <lido:titleSet>
      <lido:appellationValue>
        <xsl:value-of select="."/>
        <!--<xsl:value-of select="value[@lang=$display_language or @lang='']" />-->
      </lido:appellationValue>
    </lido:titleSet>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
  <!-- not currently used -->
  <xsl:template match="title" mode="objectWorkTypeWrap">
    <lido:objectWorkType>
      <lido:conceptID>
        <xsl:attribute name="lido:type">title</xsl:attribute>
      </lido:conceptID>
      <lido:term>
        <xsl:value-of select="."/>
      </lido:term>
    </lido:objectWorkType>
  </xsl:template>
  <!-- 
  *************************************************************
  -->
</xsl:stylesheet>
