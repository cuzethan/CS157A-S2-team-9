<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%!
private static String hashPassword(String password) {
    try {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(password.getBytes());
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException("Unable to hash password", e);
    }
}

private static String trimToNull(String value) {
    if (value == null) return null;
    String trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
}
%>
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    javax.servlet.http.HttpSession userSession = request.getSession();
    String username = trimToNull(request.getParameter("username"));
    String password = request.getParameter("password");

    if (username == null || password == null || password.isEmpty()) {
        request.setAttribute("formError", "Invalid username or password.");
        request.setAttribute("usernameValue", username != null ? username : "");
    } else {
        String passwordHash = hashPassword(password);
        String sql = "SELECT email FROM Users WHERE username = ? AND password = ?";
        String email = null;
        boolean failed = false;

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    request.setAttribute("formError", "Invalid username or password.");
                    request.setAttribute("usernameValue", username);
                    failed = true;
                } else {
                    email = rs.getString("email");
                    userSession.setAttribute("emailValue", email);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("formError", "Invalid username or password.");
            request.setAttribute("usernameValue", username);
            failed = true;
        }

        if (!failed && email != null) {
            userSession.setAttribute("usernameValue", username);
            String adminSql = "SELECT email FROM Administrators WHERE email = ?";
            try (Connection con = Database.getConnection();
                 PreparedStatement ps = con.prepareStatement(adminSql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userSession.setAttribute("isAdmin", true);
                        response.sendRedirect(request.getContextPath() + "/admin");
                        return;
                    } else {
                        userSession.setAttribute("isAdmin", false);
                        response.sendRedirect(request.getContextPath() + "/listings");
                        return;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("formError", "Invalid username or password.");
                request.setAttribute("usernameValue", username);
            }
        }
    }
}
%>
<%
  request.setAttribute("pageTitle", "Login - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-md bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Login</h2>
  <p class="mt-1 text-sm text-slate-600">Welcome back. Sign in to continue.</p>

  <%
    String formError = (String) request.getAttribute("formError");
    String usernameValue = (String) request.getAttribute("usernameValue");
    if (formError != null) {
  %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <%
    }
  %>

  <form class="mt-6 space-y-4" method="post" action="<%= request.getContextPath() %>/login">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="username">Username</label>
      <input id="username" name="username" type="text" autocomplete="username"
             value="<%= usernameValue != null ? usernameValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="password">Password</label>
      <input id="password" name="password" type="password" autocomplete="current-password"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <button type="submit"
            class="w-full inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
      Login
    </button>

    <p class="text-center text-sm text-slate-600">
      Don’t have an account?
      <a class="font-semibold text-blue-700 hover:text-blue-800" href="<%= request.getContextPath() %>/signup">Sign up</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

