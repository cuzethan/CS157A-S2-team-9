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
<%!
private static String trimToNull(String value) {
    if (value == null) return null;
    String trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
}
%>
<%
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
String myEmail = (String) userSession.getAttribute("emailValue");
String withEmail = trimToNull(request.getParameter("with"));

if (withEmail == null) {
    response.sendRedirect(request.getContextPath() + "/inbox");
    return;
}

// Verify the partner exists
String partnerUsername = null;
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT username FROM Users WHERE email = ?")) {
    ps.setString(1, withEmail);
    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) partnerUsername = rs.getString("username");
    }
} catch (SQLException e) { e.printStackTrace(); }

if (partnerUsername == null) {
    response.sendRedirect(request.getContextPath() + "/inbox");
    return;
}

String formError = null;

// Handle sending a new message (POST)
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = trimToNull(request.getParameter("action"));
    String body   = trimToNull(request.getParameter("body"));
    String msgIdStr = trimToNull(request.getParameter("messageId"));

    if ("send".equals(action)) {
        if (body == null) {
            formError = "Message cannot be empty.";
        } else if (body.length() > 2000) {
            formError = "Message must be 2000 characters or fewer.";
        } else {
            try (Connection con = Database.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO Messages (sender_email, receiver_email, body) VALUES (?, ?, ?)")) {
                ps.setString(1, myEmail);
                ps.setString(2, withEmail);
                ps.setString(3, body);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
                formError = "Failed to send message. Please try again.";
            }
            if (formError == null) {
                response.sendRedirect(request.getContextPath()
                    + "/messages?with=" + java.net.URLEncoder.encode(withEmail, "UTF-8"));
                return;
            }
        }
    } else if ("report".equals(action) && msgIdStr != null) {
        try {
            int msgId = Integer.parseInt(msgIdStr);
            Connection con = Database.getConnection();
            try {
                con.setAutoCommit(false);

                // Mark the message as reported
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Messages SET is_reported = 1 WHERE message_id = ? AND receiver_email = ?")) {
                    ps.setInt(1, msgId);
                    ps.setString(2, myEmail);
                    ps.executeUpdate();
                }

                // Also create a Reports entry so admins can see it
                String reportDesc = "Reported message (ID: " + msgId + ") from user: "
                                  + withEmail + " to: " + myEmail;
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO Reports (category, description, status, created_at, user_email) "
                      + "VALUES ('Inappropriate Language/Hate Speech', ?, 'Pending', NOW(), ?)")) {
                    ps.setString(1, reportDesc);
                    ps.setString(2, myEmail);
                    ps.executeUpdate();
                }

                con.commit();
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
            } finally {
                con.setAutoCommit(true);
                con.close();
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath()
            + "/messages?with=" + java.net.URLEncoder.encode(withEmail, "UTF-8") + "&reported=1");
        return;
    }
}

// Mark messages from partner as read
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "UPDATE Messages SET is_read = 1 "
       + "WHERE sender_email = ? AND receiver_email = ? AND is_read = 0")) {
    ps.setString(1, withEmail);
    ps.setString(2, myEmail);
    ps.executeUpdate();
} catch (SQLException e) { e.printStackTrace(); }

// Load all messages in this conversation
List<Map<String, Object>> messages = new ArrayList<>();
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT message_id, sender_email, body, date_sent, is_reported "
       + "FROM Messages "
       + "WHERE (sender_email = ? AND receiver_email = ?) "
       + "   OR (sender_email = ? AND receiver_email = ?) "
       + "ORDER BY date_sent ASC")) {
    ps.setString(1, myEmail);   ps.setString(2, withEmail);
    ps.setString(3, withEmail); ps.setString(4, myEmail);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, Object> msg = new HashMap<>();
            msg.put("id", rs.getInt("message_id"));
            msg.put("sender", rs.getString("sender_email"));
            msg.put("body", rs.getString("body"));
            msg.put("date", rs.getString("date_sent"));
            msg.put("reported", rs.getBoolean("is_reported"));
            messages.add(msg);
        }
    }
} catch (SQLException e) { e.printStackTrace(); }

boolean reported = "1".equals(request.getParameter("reported"));

request.setAttribute("pageTitle", "Message - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="flex flex-col h-[calc(100vh-12rem)] max-w-2xl mx-auto bg-white rounded-2xl shadow-sm overflow-hidden">

  <!-- Header -->
  <div class="flex items-center gap-3 border-b border-slate-200 px-6 py-4 flex-shrink-0">
    <a href="<%= request.getContextPath() %>/inbox"
       class="text-slate-400 hover:text-slate-700">
      <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18"/>
      </svg>
    </a>
    <div class="flex h-9 w-9 items-center justify-center rounded-full bg-blue-100 text-sm font-bold text-blue-700 uppercase flex-shrink-0">
      <%= partnerUsername.substring(0, 1) %>
    </div>
    <div>
      <p class="text-sm font-semibold text-slate-900"><%= partnerUsername %></p>
      <p class="text-xs text-slate-500"><%= withEmail %></p>
    </div>
  </div>

  <!-- Messages -->
  <div class="flex-1 overflow-y-auto px-6 py-4 space-y-3" id="msg-scroll">
    <% if (reported) { %>
      <div class="rounded-lg border border-green-200 bg-green-50 px-4 py-2 text-sm text-green-800 text-center">
        Message reported. Our admins will review it.
      </div>
    <% } %>
    <% if (formError != null) { %>
      <div class="rounded-lg border border-red-200 bg-red-50 px-4 py-2 text-sm text-red-800">
        <%= formError %>
      </div>
    <% } %>
    <% if (messages.isEmpty()) { %>
      <div class="text-center text-sm text-slate-400 py-10">No messages yet. Say hello!</div>
    <% } %>
    <% for (Map<String, Object> msg : messages) {
         boolean mine = myEmail.equals(msg.get("sender"));
         boolean isReported = (boolean) msg.get("reported");
    %>
      <div class="flex <%= mine ? "justify-end" : "justify-start" %>">
        <div class="max-w-[75%]">
          <div class="rounded-2xl px-4 py-2.5 text-sm
                      <%= mine
                          ? "bg-blue-600 text-white rounded-br-sm"
                          : "bg-slate-100 text-slate-900 rounded-bl-sm" %>">
            <%= msg.get("body") %>
          </div>
          <div class="mt-1 flex items-center gap-2 <%= mine ? "justify-end" : "justify-start" %>">
            <span class="text-[10px] text-slate-400"><%= msg.get("date") %></span>
            <% if (!mine && !isReported) { %>
              <form method="post"
                    action="<%= request.getContextPath() %>/messages?with=<%= java.net.URLEncoder.encode(withEmail, "UTF-8") %>"
                    class="inline">
                <input type="hidden" name="action" value="report" />
                <input type="hidden" name="messageId" value="<%= msg.get("id") %>" />
                <button type="submit"
                        class="text-[10px] text-slate-400 hover:text-red-500 underline"
                        onclick="return confirm('Report this message for inappropriate content?')">
                  Report
                </button>
              </form>
            <% } else if (!mine && isReported) { %>
              <span class="text-[10px] text-amber-500">Reported</span>
            <% } %>
          </div>
        </div>
      </div>
    <% } %>
  </div>

  <!-- Compose -->
  <div class="border-t border-slate-200 px-6 py-4 flex-shrink-0">
    <form method="post"
          action="<%= request.getContextPath() %>/messages?with=<%= java.net.URLEncoder.encode(withEmail, "UTF-8") %>"
          class="flex items-end gap-3">
      <input type="hidden" name="action" value="send" />
      <textarea name="body" rows="2" required maxlength="2000"
                placeholder="Type a message..."
                class="flex-1 rounded-xl border border-slate-300 px-3 py-2 text-sm text-slate-900 shadow-sm resize-none focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"></textarea>
      <button type="submit"
              class="flex-shrink-0 inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-white hover:bg-blue-700">
        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5"/>
        </svg>
      </button>
    </form>
  </div>
</div>

<script>
  // Auto-scroll to bottom on load
  var el = document.getElementById('msg-scroll');
  if (el) el.scrollTop = el.scrollHeight;
</script>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>