<%@ page import="org.mskcc.cbio.portal.servlet.QueryBuilder" %>
<%@ page import="org.mskcc.cbio.portal.servlet.ServletXssUtil" %>
<%@ page import="org.mskcc.cbio.portal.util.GlobalProperties" %>

<%
    String siteTitle = GlobalProperties.getTitle();
    request.setAttribute(QueryBuilder.HTML_TITLE, siteTitle);

    // Get priority settings
    Integer dataPriority;
    try {
        dataPriority
                = Integer.parseInt(request.getParameter(QueryBuilder.DATA_PRIORITY).trim());
    } catch (Exception e) {
        dataPriority = 0;
    }
    ServletXssUtil servletXssUtil = ServletXssUtil.getInstance();
    String geneList = servletXssUtil.getCleanInput(request, QueryBuilder.GENE_LIST).replaceAll("\n", " ");
%>

<jsp:include page="global/header.jsp" flush="true"/>

<!-- for now, let's include these guys here and prevent clashes with the rest of the portal -->
<script type="text/javascript" src="js/src/mutation_model.js"></script>
<script type="text/javascript" src="js/src/crosscancer.js"></script>
<link href="css/data_table_ColVis.css" type="text/css" rel="stylesheet" />
<link href="css/data_table_jui.css" type="text/css" rel="stylesheet" />
<link href="css/crosscancer.css" type="text/css" rel="stylesheet" />

<%
    // Means that user landed on this page with the old way.
    if(geneList != null) {
%>

<script type="text/javascript">
    window.location.hash = "crosscancer/overview/<%=dataPriority%>/<%=geneList%>";
</script>

<%
    }
%>

<table>
    <tr>
        <td>

            <div id="results_container">
                <p><a href=""
                      title="Modify your original query.  Recommended over hitting your browser's back button."
                      id="toggle_query_form">
                    <span class='query-toggle ui-icon ui-icon-triangle-1-e'
                          style='float:left;'></span>
                    <span class='query-toggle ui-icon ui-icon-triangle-1-s'
                          style='float:left; display:none;'></span><b>Modify Query</b></a>

                <p/>

                <div style="margin-left:5px;display:none;" id="query_form_on_results_page">
                    <%@ include file="query_form.jsp" %>
                </div>

                <div id="crosscancer-container">
                </div>
            </div>
            <!-- end results container -->
        </td>
    </tr>
</table>


<!-- Crosscancer templates -->
<script type="text/template" id="cross-cancer-main-tmpl">
    <div id="tabs">
        <ul>
            <li>
                <a href="#cc-overview">Overview</a>
            </li>
            <li>
                <a href="#cc-mutations">Mutations</a>
            </li>
        </ul>
        <div class="section" id="cc-overview">
            <div id="cctitlecontainer"></div>
            <div id="cchistogram">
                <img src="images/ajax-loader.gif"/>
            </div>
        </div>

        <div class="section" id="cc-mutations">
            <div id="mutation_details" class="mutation-details-content">
                <img src="images/ajax-loader.gif"/>
            </div>
        </div>

        <div id="studies-with-no-data"></div>
    </div>
</script>

<script type="text/template" id="studies-with-no-data-item-tmpl">
    <li>{{name}}</li>
</script>

<script type="text/template" id="study-link-tmpl">
    <a href="index.do?tab_index=tab_visualize&cancer_study_id={{studyId}}&genetic_profile_ids_PROFILE_MUTATION_EXTENDED={{mutationProfile}}&genetic_profile_ids_PROFILE_COPY_NUMBER_ALTERATION={{cnaProfile}}&Z_SCORE_THRESHOLD=2.0&case_set_id={{caseSetId}}&case_ids=&gene_list={{genes}}&gene_set_choice=user-defined-list&Action=Submit" target="_blank">
        view details &raquo;
    </a>
</script>

<script type="text/template" id="study-tip-tmpl">
    <div>
        <div class="cc-study-tip">
            <b class="cc-tip-header">{{name}}</b><br>
            <p>
                Gene set altered in {{allFrequency}}% of {{caseSetLength}} cases. <br>({{studyLink}})
            </p>
            <table class="cc-tip-table">
                <thead>
                    <tr>
                        <th>Alteration</th>
                        <th>Frequency</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Mutation</td>
                        <td>{{mutationFrequency}}% ({{mutationCount}})</td>
                    </tr>
                    <tr>
                        <td>Deletion</td>
                        <td>{{deletionFrequency}}% ({{deletionCount}})</td>
                    </tr>
                    <tr>
                        <td>Amplification</td>
                        <td>{{amplificationFrequency}}% ({{amplificationCount}})</td>
                    </tr>
                    <tr>
                        <td>Multiple alterations</td>
                        <td>{{multipleFrequency}}% ({{multipleCount}})</td>
                    </tr>
                </tbody>
            </table>

        </div>
    </div>
</script>

<script type="text/template" id="studies-with-no-data-tmpl">
    <div class="ui-state-highlight ui-corner-all">
        <p>
            <span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em; margin-left: .3em"></span>
            Since the data priority was set to '{{ priority == 1 ? "Only Mutation" : "Only CNA" }}', the following
            <b>{{hiddenStudies.length}} cancer studies</b>
            that do not have {{ priority == 1 ? "mutation" : "CNA" }} data were excluded from this view: <br>
        </p>
        <ul id="not-shown-studies">
        </ul>
        <p></p>
    </div>
</script>

<script type="text/template" id="crosscancer-title-tmpl">
    <b class="cctitle">
        Cross-cancer alteration summary for {{genes}} ({{numOfStudies}} studies / {{numOfGenes}} gene{{numOfGenes > 1 ? "s" : ""}})
    </b>
    <form style="display:inline-block"
          action='svgtopdf.do'
          method='post'
          class='svg-to-pdf-form'>
        <input type='hidden' name='svgelement'>
        <input type='hidden' name='filetype' value='pdf'>
        <input type='hidden' name='filename' value='crosscancerhistogram.pdf'>
    </form>
    <form style="display:inline-block"
          action='svgtopdf.do'
          method='post'
          class='svg-to-file-form'>
        <input type='hidden' name='svgelement'>
        <input type='hidden' name='filetype' value='svg'>
        <input type='hidden' name='filename' value='crosscancerhistogram.svg'>
    </form>
    <button id="histogram-download-pdf" class='diagram-to-pdf'>PDF</button>
    <button id="histogram-download-svg" class='diagram-to-svg'>SVG</button>
</script>

<!-- Mutation views -->
<jsp:include page="mutation_views.jsp" flush="true"/>
<!-- mutation views end -->

<script type="text/template" id="cross-cancer-main-empty-tmpl">
    <h1>Default cross-cancer view</h1>
</script>



</div>
</td>
</tr>
<tr>
    <td colspan="3">
        <jsp:include page="global/footer.jsp" flush="true"/>
    </td>
</tr>
</table>
</center>
</div>



<jsp:include page="global/xdebug.jsp" flush="true"/>


</body>
</html>