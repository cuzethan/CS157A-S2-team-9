<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
javax.servlet.http.HttpSession adminSession = request.getSession();
Boolean sessionIsAdmin = (Boolean) adminSession.getAttribute("isAdmin");
if (!Boolean.TRUE.equals(sessionIsAdmin)) {
    response.sendError(javax.servlet.http.HttpServletResponse.SC_FORBIDDEN, "Admin access required.");
    return;
}
request.setAttribute("pageTitle", "Reports - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="space-y-6">
  <section class="bg-white rounded-2xl shadow-sm p-8">
    <h2 class="text-3xl font-bold tracking-tight text-slate-900">Reports Dashboard</h2>
    <p class="mt-2 text-sm text-slate-600">Review and resolve user-submitted reports.</p>
  </section>

  <%@ include file="/WEB-INF/jsp/admin/_reports-section.jsp" %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>