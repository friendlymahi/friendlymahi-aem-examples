<%
   %><%@ include file="/libs/granite/ui/global.jsp" %><%
   %><%@ page import="org.apache.commons.lang3.StringUtils,
   org.apache.sling.api.resource.Resource,
   org.apache.sling.api.resource.ResourceResolver,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Field,
                  com.adobe.granite.ui.components.Tag,
                  com.day.cq.i18n.I18n" %><%--###
   JSONEditor
   ==========

   .. granite:servercomponent:: /apps/spa-poc/components/dialog/jsonEditor
      :supertype: /libs/granite/ui/components/coral/foundation/form/field
   
      A field that allows user to map JSON schema and save valid JSON Data.
   
      It extends :granite:servercomponent:`Field </libs/granite/ui/components/coral/foundation/form/field>` component.

      It has the following content structure:
   
      .. gnd:gnd::
   
         [granite:FormDatePicker] > granite:FormField
   
         /**
          * The name that identifies the field when submitting the form.
          *
          * The `SlingPostServlet @TypeHint <http://sling.apache.org/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html#typehint>`_ hidden input with value ``Date`` is also generated based on the name.
          */
         - name (String)

         /**
          * The value of the field.
          */
         - value (StringEL)
   
         /**
          * A hint to the user of what can be entered in the field.
          */
         - emptyText (String) i18n
   
         /**
          * Indicates if the field is in disabled state.
          */
         - disabled (Boolean)
   
         /**
          * Indicates if the field is mandatory to be filled.
          */
         - required (Boolean)
   
         /**
          * The name of the validator to be applied. E.g. ``foundation.jcr.name``.
          * See :doc:`validation </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/validation/index>` in Granite UI.
          */
         - validation (String) multiple
   
   ###--%><%
   Config cfg = cmp.getConfig();
   ValueMap vm = (ValueMap) request.getAttribute(Field.class.getName());
   Field field = new Field(cfg);
   
   boolean isMixed = field.isMixed(cmp.getValue());

   String name = cfg.get("name", String.class);
   String typeHint = cfg.get("typeHint", "String");
   
   Tag tag = cmp.consumeTag();
   AttrBuilder attrs = tag.getAttrs();
   cmp.populateCommonAttrs(attrs);
   
   if (isMixed) {
       attrs.addClass("foundation-field-mixed");
   }

   attrs.add("name", name);
   attrs.addDisabled(cfg.get("disabled", false));
   
   String fieldLabel = cfg.get("fieldLabel", String.class);
   String fieldDesc = cfg.get("fieldDescription", String.class);
   String labelledBy = null;
   
   if (fieldLabel != null && fieldDesc != null) {
       labelledBy = vm.get("labelId", String.class) + " " + vm.get("descriptionId", String.class);
   } else if (fieldLabel != null) {
       labelledBy = vm.get("labelId", String.class);
   } else if (fieldDesc != null) {
       labelledBy = vm.get("descriptionId", String.class);
   }
   
   if (StringUtils.isNotBlank(labelledBy)) {
       attrs.add("labelledby", labelledBy);
   }
   
   
   
   /*if (isMixed) {
       attrs.add("placeholder", i18n.get("<Mixed Entries>")); // TODO Maybe define this String somewhere
       } else {*/
//attrs.add("value", vm.get("value", String.class));
       attrs.add("placeholder", i18n.getVar(cfg.get("emptyText", String.class)));
   /*}*/
   
   attrs.addBoolean("required", cfg.get("required", false));
   
   String validation = StringUtils.join(cfg.get("validation", new String[0]), " ");
   attrs.add("data-foundation-validation", validation);
   attrs.add("data-validation", validation); // Compatibility

/*
   String path = (String) request.getAttribute(com.adobe.granite.ui.components.Value.CONTENTPATH_ATTRIBUTE);
 Resource cqComponent1 = resourceResolver.getResource(path);

String cqComponentType1 = (cqComponent1!=null)?cqComponent1.getResourceType():resource.getResourceType();
out.println("YYYYY"+cqComponentType1);
out.println("ZZZZ"+(String) request.getParameter("resourceType"));



Resource cqComponentTypeResource = resourceResolver.getResource('/mnt/overlay'+cqComponentType1+"/style-schema.json");
out.println("AAAAA"+cqComponentTypeResource.getPath());
//String cqComponentSuperType = cqComponentTypeResource.getResourceSuperType();
*/

String cqComponentType = (String) request.getParameter("resourceType");
cqComponentType=StringUtils.startsWithAny(cqComponentType,new String[]{"/apps/","/libs/"})?cqComponentType:"/apps/"+cqComponentType;


   attrs.add("data-containingComponentPath", cqComponentType); // Compatibility


   // TODO - Enable inheritance for default schema either by checking existence of schema from actual resource type, and then its parent resource type, and so on

   %>

<%
    String jsonEditorInstanceId = StringUtils.substring(name, 2);
%>


<coral-alert data-error-type="schema_error" style="width: -webkit-fill-available;" variant="error">
  <coral-alert-header>ERROR</coral-alert-header>
  <coral-alert-content>Error loading schema. Ensure that a valid schema exists !</coral-alert-content>
</coral-alert>
<coral-tabview class="json-editor-granite">
  <coral-tablist target="coral-demo-panel-<%=jsonEditorInstanceId%>">
    <coral-tab>JSON Editor</coral-tab>
      <coral-tab>JSON Schema</coral-tab>
    <coral-tab>Final JSON</coral-tab>
  </coral-tablist>
  <coral-panelstack id="coral-demo-panel-<%=jsonEditorInstanceId%>">
    <coral-panel class="coral-Well" id="jsonEditorPanel_<%=jsonEditorInstanceId%>">
        <coral-alert style="display:none;" variant="warning">
  <coral-alert-header>WARNING</coral-alert-header>
  <coral-alert-content>JSON modified since the time it is loaded. Please review and save it !</coral-alert-content>
</coral-alert>

        <div data-area='editor' id="jsonEditor_<%=jsonEditorInstanceId%>"></div>       
    </coral-panel>
          <coral-panel class="coral-Well">
      <textarea is="coral-textarea" data-area='schema' class="activeSchema" style="margin: 0px 20px 6px 0px; height: 501px;font-size: 1.0rem;width: 100%;" readonly>
</textarea>
    </coral-panel>
    <coral-panel class="coral-Well">
      <textarea is="coral-textarea" data-area='json' <%= attrs %> style="margin: 0px 20px 6px 0px; height: 501px;font-size: 1.0rem;" readonly>
        <%=vm.get("value", String.class)%>
</textarea>
        <%
            if (!StringUtils.isBlank(name)) {
        AttrBuilder typeAttrs = new AttrBuilder(request, xssAPI);
        typeAttrs.addClass("foundation-field-related");
        typeAttrs.add("type", "hidden");
        typeAttrs.add("value", "String");
        typeAttrs.add("name", name + "@TypeHint");

        %><input <%= typeAttrs %>><%
    }
%>
    </coral-panel>
  </coral-panelstack>
</coral-tabview>