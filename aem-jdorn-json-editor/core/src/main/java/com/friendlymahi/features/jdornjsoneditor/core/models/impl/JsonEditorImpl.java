package com.friendlymahi.features.jdornjsoneditor.core.models.impl;


import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.inject.Named;

import org.apache.commons.lang3.StringUtils;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.models.annotations.Default;
import org.apache.sling.models.annotations.DefaultInjectionStrategy;
import org.apache.sling.models.annotations.Exporter;
import org.apache.sling.models.annotations.ExporterOption;
import org.apache.sling.models.annotations.Model;
import org.apache.sling.models.annotations.injectorspecific.Self;
import org.apache.sling.models.annotations.injectorspecific.ValueMapValue;

import com.adobe.cq.export.json.ComponentExporter;
import com.adobe.cq.export.json.ExporterConstants;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonRawValue;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.friendlymahi.features.jdornjsoneditor.core.models.JsonEditor;

@Model(
	    adaptables = SlingHttpServletRequest.class,
		adapters= {ComponentExporter.class },
	    resourceType = {JsonEditorImpl.RESOURCE_TYPE},
	    defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL
	)
@Exporter(
			name = ExporterConstants.SLING_MODEL_EXPORTER_NAME,
			selector = ExporterConstants.SLING_MODEL_SELECTOR, // The default is 'model', this is just reiterating this.
			extensions = ExporterConstants.SLING_MODEL_EXTENSION,
			options = {   // options are optional... this just shows that it is possible...
			              /**
			               * Jackson options:
			               * - Mapper Features: http://static.javadoc.io/com.fasterxml.jackson.core/jackson-databind/2.8.5/com/fasterxml/jackson/databind/MapperFeature.html
			               * - Serialization Features: http://static.javadoc.io/com.fasterxml.jackson.core/jackson-databind/2.8.5/com/fasterxml/jackson/databind/SerializationFeature.html
			               */
			              @ExporterOption(name = "MapperFeature.SORT_PROPERTIES_ALPHABETICALLY", value = "true"),
			              @ExporterOption(name = "SerializationFeature.WRITE_DATES_AS_TIMESTAMPS", value="false")
			}
		)
public class JsonEditorImpl implements ComponentExporter, JsonEditor {

	// SuperType to handle all use cases
	protected static final String RESOURCE_TYPE = "aem-jdorn-json-editor/components/jsonEditorBase";

	@Inject
	private Resource currentResource;

	@Self
	private SlingHttpServletRequest request;
	
	@ValueMapValue
	private String jsonData;
	
	private String componentProperties;

	@PostConstruct
	public void init() {
		
		jsonData = StringUtils.trimToNull(jsonData);

		if(jsonData == null)
		{
			componentProperties = "{}";
		}
		else
		{
			JsonParser parser = new JsonParser();
			JsonObject json = parser.parse(jsonData).getAsJsonObject();
			
			Gson gson = new GsonBuilder().setPrettyPrinting().create();
			
			if(json.get("LocaleContent") != null)
				componentProperties = gson.toJson(json.getAsJsonObject());
		}				
	}

	@JsonRawValue  @JsonProperty(value="JsonData")
	public String getComponentProperties() {
		return componentProperties;
	}

	public String getExportedType() {
		// TODO Auto-generated method stub
		return currentResource.getResourceType();
	}
}
