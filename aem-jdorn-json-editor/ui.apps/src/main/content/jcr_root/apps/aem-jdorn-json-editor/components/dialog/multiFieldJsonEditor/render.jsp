<%
   %><%@ include file="/libs/granite/ui/global.jsp" %><%
	%><%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%><%
   %><%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%
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

   .. granite:servercomponent:: /apps/spa-poc/components/dialog/multiFieldJsonEditor
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
   
   ###--%><%
   Config cfg = cmp.getConfig();
 ValueMap vm = (ValueMap) request.getAttribute(Field.class.getName());
 Field field = new Field(cfg);

 boolean isMixed = field.isMixed(cmp.getValue());

 String name = cfg.get("name", String.class);
 request.setAttribute("multifieldName", name);
 String schemaPath = cfg.get("schemaPath", "multifield-schema.json");
 request.setAttribute("schemaPath", schemaPath);
 String cqComponentType = (String) request.getParameter("resourceType");
 cqComponentType = StringUtils.startsWithAny(cqComponentType, new String[] {
     "/apps/",
     "/libs/"
 }) ? cqComponentType : "/apps/" + cqComponentType;
 request.setAttribute("cqComponentType", cqComponentType); // Compatibility


 String typeHint = cfg.get("typeHint", "String");

 Tag tag = cmp.consumeTag();
 AttrBuilder attrs = tag.getAttrs();
 cmp.populateCommonAttrs(attrs);

 if (isMixed) {
     attrs.addClass("foundation-field-mixed");
 }

 String jsonEditorInstanceId = StringUtils.substring(name, 2);
 request.setAttribute("jsonEditorInstanceId", "multifieldJson_" + jsonEditorInstanceId);

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

 attrs.addBoolean("required", cfg.get("required", false));

 String validation = StringUtils.join(cfg.get("validation", new String[0]), " ");
 attrs.add("data-foundation-validation", validation);
 attrs.add("data-validation", validation); // Compatibility
             
%>
                 
<coral-alert data-error-type="schema_error" style="width: -webkit-fill-available;" variant="error">
    <coral-alert-header>ERROR</coral-alert-header>
    <coral-alert-content>Error loading schema. Ensure that a valid schema exists !</coral-alert-content>
</coral-alert>
<coral-tabview class="json-editor-multifield-noncomposite-granite">
    <coral-tablist target="coral-demo-panel-${requestScope.jsonEditorInstanceId}">
        <coral-tab>JSON Editor</coral-tab>
        <coral-tab>JSON Schema</coral-tab>
        <coral-tab>Final JSON</coral-tab>
    </coral-tablist>
    <coral-panelstack id="coral-demo-panel-${requestScope.jsonEditorInstanceId}">
        <coral-panel class="coral-Well" id="jsonEditorPanel_${requestScope.jsonEditorInstanceId}">
            <coral-alert style="float:right;display:none;" variant="warning">
                <coral-alert-header>WARNING</coral-alert-header>
                <coral-alert-content>JSON modified since the time it is loaded. Please review and save it !</coral-alert-content>
            </coral-alert>
            <div data-area='editor' id="jsonEditor_${requestScope.jsonEditorInstanceId}"></div>
        </coral-panel>
        <coral-panel class="coral-Well">
            <textarea is="coral-textarea" data-area='schema' class="activeSchema" style="margin: 0px 20px 6px 0px; height: 501px;font-size: 1.0rem;width: 100%;" readonly> </textarea>
        </coral-panel>
        <coral-panel class="coral-Well">
            <section id="${requestScope.jsonEditorInstanceId}" data-area="json" data-fieldname="${requestScope.multifieldName}">
                <c:forEach items="${requestScope.multiFieldValues}" var="multiFieldValue" varStatus="stat">
                    <input name="${requestScope.multifieldName}" type="text" value="${fn:escapeXml(multiFieldValue)}" /> </c:forEach>
                <input type="hidden" name="${requestScope.multifieldName}@Delete" /> </section>
            <c:set var="finalJson" value="${fn:join(requestScope.multiFieldValues,',')}" />
            <textarea is="coral-textarea" <%=attrs%> data-containingComponentPath="${requestScope.cqComponentType}" data-schemapath="${requestScope.schemaPath}" data-area='json' style="margin: 0px 20px 6px 0px; height: 501px;font-size: 1.0rem;" readonly>
                <c:out value="[${finalJson}]" /> 
            </textarea>
        </coral-panel>
    </coral-panelstack>
</coral-tabview>