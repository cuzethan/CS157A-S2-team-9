<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%!
private static String hashPassword(String password) {
    try {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(password.getBytes());
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) sb.append(String.format("%02x", b));
        return sb.toString();
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException("Unable to hash password", e);
    }
}
%>
<%
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

String email = (String) userSession.getAttribute("emailValue");


if (Boolean.TRUE.equals(userSession.getAttribute("isAdmin"))) {
    request.setAttribute("formError", "Admin accounts cannot be deleted through this page.");
}

if ("POST".equalsIgnoreCase(request.getMethod()) && !Boolean.TRUE.equals(userSession.getAttribute("isAdmin"))) {
    String password = request.getParameter("password");
    String confirm  = request.getParameter("confirm");

    if (password == null || password.isEmpty()) {
        request.setAttribute("formError", "Password is required to confirm deletion.");
    } else if (!"DELETE".equals(confirm)) {
        request.setAttribute("formError", "Please type DELETE to confirm account deletion.");
    } else {
        // Verify password first
        String hash = hashPassword(password);
        boolean passwordOk = false;
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT email FROM Users WHERE email = ? AND password = ?")) {
            ps.setString(1, email);
            ps.setString(2, hash);
            try (ResultSet rs = ps.executeQuery()) {
                passwordOk = rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("formError", "Database error. Please try again.");
        }

        if (request.getAttribute("formError") == null) {
            if (!passwordOk) {
                request.setAttribute("formError", "Incorrect password. Account not deleted.");
            } else {
                // Delete in dependency order inside a transaction
                Connection con = null;
                try {
                    con = Database.getConnection();
                    con.setAutoCommit(false);

                    // Favorites referencing this user's saved posts
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Favorites WHERE email = ?")) {
                        ps.setString(1, email); ps.executeUpdate();
                    }
                    // Favorites saved by others pointing at this user's posts
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Favorites WHERE post_ID IN "
                          + "(SELECT post_ID FROM Posts WHERE email = ?)")) {
                        ps.setString(1, email); ps.executeUpdate();
                    }
                    // Posts
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Posts WHERE email = ?")) {
                        ps.setString(1, email); ps.executeUpdate();
                    }
                    // Friends
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Friends WHERE user_email1 = ? OR user_email2 = ?")) {
                        ps.setString(1, email); ps.setString(2, email); ps.executeUpdate();
                    }
                    // Reports filed by this user (admin_email FK left intact)
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Reports WHERE user_email = ?")) {
                        ps.setString(1, email); ps.executeUpdate();
                    }
                    // Messages
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Messages WHERE sender_email = ? OR receiver_email = ?")) {
                        ps.setString(1, email); ps.setString(2, email); ps.executeUpdate();
                    }
                    // Transactions
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Transactions WHERE buyer_email = ? OR seller_email = ?")) {
                        ps.setString(1, email); ps.setString(2, email); ps.executeUpdate();
                    }
                    // User record itself
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM Users WHERE email = ?")) {
                        ps.setString(1, email); ps.executeUpdate();
                    }

                    con.commit();
                    userSession.invalidate();
                    response.sendRedirect(request.getContextPath() + "/home?deleted=1");
                    return;

                } catch (SQLException e) {
                    if (con != null) { try { con.rollback(); } catch (SQLException ignored) {} }
                    e.printStackTrace();
                    request.setAttribute("formError", "Failed to delete account. Please try again.");
                } finally {
                    if (con != null) {
                        try { con.setAutoCommit(true); } catch (SQLException ignored) {}
                        try { con.close(); } catch (SQLException ignored) {}
                    }
                }
            }
        }
    }
}
%>
<%
  request.setAttribute("pageTitle", "Delete Account - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-md bg-white rounded-2xl shadow-sm p-8">
  <div class="flex items-center gap-3 mb-2">
    <div class="flex h-10 w-10 items-center justify-center rounded-full bg-red-100">
      <svg class="h-5 w-5 text-red-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"/>
      </svg>
    </div>
    <h2 class="text-2xl font-bold tracking-tight text-slate-900">Delete Account</h2>
  </div>
  <p class="mt-1 text-sm text-slate-600">
    This action is <span class="font-semibold text-red-600">permanent and irreversible</span>.
    All your listings, messages, favorites, and account data will be deleted.
  </p>

  <% String formError = (String) request.getAttribute("formError"); %>
  <% if (formError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <% } %>

  <% if (!Boolean.TRUE.equals(userSession.getAttribute("isAdmin"))) { %>
  <form class="mt-6 space-y-4" method="post"
        action="<%= request.getContextPath() %>/delete-account"
        onsubmit="return confirm('Are you absolutely sure? This cannot be undone.');">

    <div class="rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800 space-y-1">
      <p class="font-semibold">What will be deleted:</p>
      <ul class="list-disc pl-5 space-y-0.5">
        <li>Your user account</li>
        <li>All your listings and their favorites</li>
        <li>All your messages</li>
        <li>All your reports</li>
        <li>All transaction records involving you</li>
      </ul>
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="password">
        Confirm your password <span class="text-red-500">*</span>
      </label>
      <input id="password" name="password" type="password" required autocomplete="current-password"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-500/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="confirm">
        Type <span class="font-mono font-bold">DELETE</span> to confirm <span class="text-red-500">*</span>
      </label>
      <input id="confirm" name="confirm" type="text" required placeholder="DELETE"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-500/20" />
    </div>

    <div class="flex gap-3">
      <button type="submit"
              class="flex-1 inline-flex items-center justify-center rounded-lg bg-red-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-red-700">
        Delete My Account
      </button>
      <a href="<%= request.getContextPath() %>/my-listings"
         class="flex-1 inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">
        Cancel
      </a>
    </div>
  </form>
  <% } %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>