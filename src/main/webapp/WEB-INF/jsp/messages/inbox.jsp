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
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
String email = (String) userSession.getAttribute("emailValue");

// Fetch all conversations: the most recent message per conversation partner,
// plus an unread count for messages received by this user.
String sql =
	"SELECT " +
	    "  partner, " +
	    "  u.username AS partnerUsername, " +
	    "  lastBody, lastDate, unreadCount " +
	    "FROM ( " +
	    "  SELECT " +
	    "    CASE WHEN sender_email = ? THEN receiver_email ELSE sender_email END AS partner, " +
	    "    ANY_VALUE(SUBSTRING(body, 1, 80)) AS lastBody, " +
	    "    MAX(date_sent) AS lastDate, " +
	    "    SUM(CASE WHEN receiver_email = ? AND is_read = 0 THEN 1 ELSE 0 END) AS unreadCount " +
	    "  FROM Messages " +
	    "  WHERE sender_email = ? OR receiver_email = ? " +
	    "  GROUP BY partner " +
	    ") convo " +
	    "JOIN Users u ON u.email = convo.partner " +
	    "ORDER BY lastDate DESC";

List<Map<String, Object>> conversations = new ArrayList<>();
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, email);
    ps.setString(2, email);
    ps.setString(3, email);
    ps.setString(4, email);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, Object> conv = new HashMap<>();
            conv.put("partner", rs.getString("partner"));
            conv.put("partnerUsername", rs.getString("partnerUsername"));
            conv.put("lastBody", rs.getString("lastBody"));
            conv.put("lastDate", rs.getString("lastDate"));
            conv.put("unreadCount", rs.getInt("unreadCount"));
            conversations.add(conv);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

int totalUnread = conversations.stream()
    .mapToInt(c -> (int) c.get("unreadCount")).sum();

request.setAttribute("pageTitle", "Inbox - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
  <div>
    <h2 class="text-2xl font-bold tracking-tight text-slate-900">Inbox</h2>
    <p class="mt-1 text-sm text-slate-600">
      Your conversations with other Spartans.
      <% if (totalUnread > 0) { %>
        <span class="ml-1 inline-flex items-center rounded-full bg-blue-100 px-2 py-0.5 text-xs font-semibold text-blue-700">
          <%= totalUnread %> unread
        </span>
      <% } %>
    </p>
  </div>
</div>

<div class="mt-6 bg-white rounded-2xl shadow-sm overflow-hidden">
  <% if (conversations.isEmpty()) { %>
    <div class="p-10 text-center">
      <svg class="mx-auto h-10 w-10 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M8.625 12a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H8.25m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H12m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 01-2.555-.337A5.972 5.972 0 015.41 20.97a5.969 5.969 0 01-.474-.065 4.48 4.48 0 00.978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25z"/>
      </svg>
      <p class="mt-3 text-sm font-semibold text-slate-900">No messages yet</p>
      <p class="mt-1 text-sm text-slate-600">Browse listings and message a seller to get started.</p>
      <a href="<%= request.getContextPath() %>/listings"
         class="mt-4 inline-flex items-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
        Browse Listings
      </a>
    </div>
  <% } else { %>
    <ul class="divide-y divide-slate-100">
      <% for (Map<String, Object> conv : conversations) {
           int unread = (int) conv.get("unreadCount");
           String partner = (String) conv.get("partner");
      %>
        <li>
          <a href="<%= request.getContextPath() %>/messages?with=<%= java.net.URLEncoder.encode(partner, "UTF-8") %>"
             class="flex items-center gap-4 px-6 py-4 hover:bg-slate-50 transition-colors">
            <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-sm font-bold text-blue-700 uppercase">
              <%= ((String) conv.get("partnerUsername")).substring(0, 1) %>
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2">
                <p class="text-sm font-semibold text-slate-900 <%= unread > 0 ? "font-bold" : "" %>">
                  <%= conv.get("partnerUsername") %>
                </p>
                <% if (unread > 0) { %>
                  <span class="inline-flex items-center rounded-full bg-blue-600 px-1.5 py-0.5 text-[10px] font-bold text-white">
                    <%= unread %>
                  </span>
                <% } %>
              </div>
              <p class="mt-0.5 text-xs text-slate-500 truncate"><%= conv.get("lastBody") %></p>
            </div>
            <div class="flex-shrink-0 text-xs text-slate-400"><%= conv.get("lastDate") %></div>
          </a>
        </li>
      <% } %>
    </ul>
  <% } %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>