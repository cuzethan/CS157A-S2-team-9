<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%-- Loads admin auth, actions, and data used by the view fragments below. --%>
<%@ include file="/WEB-INF/jsp/admin/_controller.jsp" %>
<%
  request.setAttribute("pageTitle", "Admin - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="space-y-6">
  <section class="bg-white rounded-2xl shadow-sm p-8">
    <h2 class="text-3xl font-bold tracking-tight text-slate-900">Admin Dashboard</h2>
    <p class="mt-2 text-sm text-slate-600">Manage user accounts and posts here!</p>
  </section>

  <%-- Renders the user table and, when selected, the inline post workspace. --%>
  <%@ include file="/WEB-INF/jsp/admin/_user-accounts-section.jsp" %>
</div>

<script>
  (function () {
    const searchInput = document.getElementById("userSearch");
    if (!searchInput) return;

    const userRows = Array.from(document.querySelectorAll(".user-row"));
    searchInput.addEventListener("input", function () {
      const query = searchInput.value.trim().toLowerCase();
      userRows.forEach(function (row) {
        const email = row.getAttribute("data-email") || "";
        const username = row.getAttribute("data-username") || "";
        const matches = !query || email.includes(query) || username.includes(query);
        row.style.display = matches ? "" : "none";
      });
    });
  })();
</script>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
