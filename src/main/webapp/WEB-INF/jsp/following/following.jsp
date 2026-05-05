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
Object _emailAttr = session.getAttribute("emailValue");
String myEmail = (_emailAttr != null && !String.valueOf(_emailAttr).trim().isEmpty())
                 ? (String) _emailAttr : null;

if (myEmail == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

String myUsername = (String) session.getAttribute("usernameValue");

String viewUser = request.getParameter("user");
String viewEmail = myEmail;
String viewUsername = myUsername;
boolean isOwnPage = true;

if (viewUser != null && !viewUser.trim().isEmpty()) {
    try (Connection con = Database.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT email, username FROM Users WHERE username = ?")) {
        ps.setString(1, viewUser.trim());
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                viewEmail = rs.getString("email");
                viewUsername = rs.getString("username");
                isOwnPage = myEmail.equals(viewEmail);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
}

String activeTab = request.getParameter("tab");
if (!"following".equals(activeTab)) activeTab = "followers";

List<Map<String, String>> followers = new ArrayList<>();
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT u.username, u.email FROM Following f "
       + "JOIN Users u ON u.email = f.user_email1 "
       + "WHERE f.user_email2 = ? ORDER BY u.username")) {
    ps.setString(1, viewEmail);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> u = new HashMap<>();
            u.put("username", rs.getString("username"));
            u.put("email", rs.getString("email"));
            followers.add(u);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

List<Map<String, String>> following = new ArrayList<>();
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT u.username, u.email FROM Following f "
       + "JOIN Users u ON u.email = f.user_email2 "
       + "WHERE f.user_email1 = ? ORDER BY u.username")) {
    ps.setString(1, viewEmail);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> u = new HashMap<>();
            u.put("username", rs.getString("username"));
            u.put("email", rs.getString("email"));
            following.add(u);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

String safeViewUsername = viewUsername.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
request.setAttribute("pageTitle", (isOwnPage ? "My" : safeViewUsername + "'s") + " Followers & Following - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="bg-white rounded-2xl shadow-sm p-8">
  <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
    <div>
      <h2 class="text-2xl font-bold tracking-tight text-slate-900">
        <% if (isOwnPage) { %>
          My Followers &amp; Following
        <% } else { %>
          <a href="<%= ctx %>/profile?user=<%= java.net.URLEncoder.encode(viewUsername, "UTF-8") %>" class="hover:text-blue-700"><%= safeViewUsername %></a>'s Followers &amp; Following
        <% } %>
      </h2>
    </div>
    <a href="<%= ctx %>/profile?user=<%= java.net.URLEncoder.encode(viewUsername, "UTF-8") %>"
       class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50 shadow-sm">
      View Profile
    </a>
  </div>

  <!-- Tabs -->
  <div class="mt-6 flex border-b border-slate-200">
    <a href="<%= ctx %>/following?user=<%= java.net.URLEncoder.encode(viewUsername, "UTF-8") %>&tab=followers"
       class="px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors
              <%= "followers".equals(activeTab) ? "border-blue-600 text-blue-600" : "border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300" %>">
      Followers <span class="ml-1 text-xs font-normal text-slate-400">(<%= followers.size() %>)</span>
    </a>
    <a href="<%= ctx %>/following?user=<%= java.net.URLEncoder.encode(viewUsername, "UTF-8") %>&tab=following"
       class="px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors
              <%= "following".equals(activeTab) ? "border-blue-600 text-blue-600" : "border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300" %>">
      Following <span class="ml-1 text-xs font-normal text-slate-400">(<%= following.size() %>)</span>
    </a>
  </div>

  <%
    List<Map<String, String>> displayList = "following".equals(activeTab) ? following : followers;
  %>

  <% if (displayList.isEmpty()) { %>
    <div class="mt-6 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
      <svg class="mx-auto h-10 w-10 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z"/>
      </svg>
      <p class="mt-3 text-sm font-semibold text-slate-900">
        <% if ("following".equals(activeTab)) { %>
          <% if (isOwnPage) { %>Not following anyone yet<% } else { %><%= safeViewUsername %> isn't following anyone yet<% } %>
        <% } else { %>
          <% if (isOwnPage) { %>No followers yet<% } else { %><%= safeViewUsername %> has no followers yet<% } %>
        <% } %>
      </p>
      <p class="mt-1 text-sm text-slate-600">
        Browse <a href="<%= ctx %>/listings" class="font-semibold text-blue-700 hover:text-blue-800">listings</a> to discover users to follow.
      </p>
    </div>
  <% } else { %>
    <div class="mt-4 divide-y divide-slate-100">
      <% for (Map<String, String> user : displayList) {
           String uName = user.get("username");
           String uEmail = user.get("email");
           String uInitial = uName.length() > 0 ? String.valueOf(uName.charAt(0)).toUpperCase() : "";
           String safeUName = uName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
      %>
        <div class="flex items-center gap-4 py-3" id="user-row-<%= safeUName %>">
          <a href="<%= ctx %>/profile?user=<%= java.net.URLEncoder.encode(uName, "UTF-8") %>"
             class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-white text-sm font-bold flex-shrink-0 hover:bg-blue-700 transition-colors">
            <%= uInitial %>
          </a>
          <div class="flex-1 min-w-0">
            <a href="<%= ctx %>/profile?user=<%= java.net.URLEncoder.encode(uName, "UTF-8") %>"
               class="text-sm font-semibold text-slate-900 hover:text-blue-700 transition-colors">
              <%= safeUName %>
            </a>
          </div>
          <% if (!myEmail.equals(uEmail)) { %>
            <a href="<%= ctx %>/profile?user=<%= java.net.URLEncoder.encode(uName, "UTF-8") %>"
               class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-50 shadow-sm">
              View Profile
            </a>
          <% } %>
        </div>
      <% } %>
    </div>
  <% } %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
