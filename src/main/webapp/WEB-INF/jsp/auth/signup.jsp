<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.regex.Pattern" %>
<%!
private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]{3,20}$");
private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@sjsu\\.edu$");
private static final Pattern PASSWORD_UPPER = Pattern.compile(".*[A-Z].*");
private static final Pattern PASSWORD_LOWER = Pattern.compile(".*[a-z].*");
private static final Pattern PASSWORD_DIGIT = Pattern.compile(".*[0-9].*");
private static final Pattern PASSWORD_SYMBOL = Pattern.compile(".*[^A-Za-z0-9].*");

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

private static String validateSignup(String username, String email, String password) {
    if (username == null || !USERNAME_PATTERN.matcher(username).matches()) {
        return "Username must be 3–20 characters and contain only letters, numbers, or underscore (_).";
    }
    if (email == null || !EMAIL_PATTERN.matcher(email).matches()) {
        return "Email must be a valid SJSU email ending with @sjsu.edu.";
    }
    if (password == null || password.length() < 8) {
        return "Password must be at least 8 characters.";
    }
    if (!PASSWORD_UPPER.matcher(password).matches()
            || !PASSWORD_LOWER.matcher(password).matches()
            || !PASSWORD_DIGIT.matcher(password).matches()
            || !PASSWORD_SYMBOL.matcher(password).matches()) {
        return "Password must include at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 symbol.";
    }
    return null;
}

private static String trimToNull(String value) {
    if (value == null) return null;
    String trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
}
%>
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String username = trimToNull(request.getParameter("username"));
    String email = trimToNull(request.getParameter("email"));
    String password = request.getParameter("password");

    request.setAttribute("usernameValue", username);
    request.setAttribute("emailValue", email);

    String error = validateSignup(username, email, password);
    if (error != null) {
        request.setAttribute("formError", error);
    } else {
        String sqlCheck = "SELECT email FROM Users WHERE email = ? OR username = ?";
        String sqlInsert = "INSERT INTO Users (username, email, password) VALUES (?, ?, ?)";
        boolean done = false;
        try (Connection con = Database.getConnection()) {
            try (PreparedStatement check = con.prepareStatement(sqlCheck)) {
                check.setString(1, email);
                check.setString(2, username);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("formError", "That email or username is already in use.");
                        done = true;
                    }
                }
            }
            if (!done) {
                String passwordHash = hashPassword(password);
                try (PreparedStatement insert = con.prepareStatement(sqlInsert)) {
                    insert.setString(1, username);
                    insert.setString(2, email);
                    insert.setString(3, passwordHash);
                    insert.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("formError", "Database error: " + e.getMessage());
            done = true;
        }
        if (!done && request.getAttribute("formError") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
    }
}
%>
<%
  request.setAttribute("pageTitle", "Sign up - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-md bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Create account</h2>
  <p class="mt-1 text-sm text-slate-600">Join SJSUMarketplace in a few seconds.</p>

  <%
    String formError = (String) request.getAttribute("formError");
    if (formError != null) {
  %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <%
    }
    String emailValue = (String) request.getAttribute("emailValue");
    String usernameValue = (String) request.getAttribute("usernameValue");
  %>

  <div class="mt-4 rounded-xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-700">
    <p class="font-semibold text-slate-900">Requirements</p>
    <ul class="mt-2 space-y-1 list-disc pl-5">
      <li>Email must end with <span class="font-mono">@sjsu.edu</span></li>
      <li>Username: 3–20 characters, letters/numbers/underscore only</li>
      <li>Password: at least 8 characters with 1 uppercase, 1 lowercase, 1 number, and 1 symbol</li>
    </ul>
  </div>

  <form class="mt-6 space-y-4" method="post" action="<%= request.getContextPath() %>/signup">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="username">Username</label>
      <input id="username" name="username" type="text" autocomplete="username"
             value="<%= usernameValue != null ? usernameValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="email">Email</label>
      <input id="email" name="email" type="email" autocomplete="email"
             value="<%= emailValue != null ? emailValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="password">Password</label>
      <input id="password" name="password" type="password" autocomplete="new-password"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <button type="submit"
            class="w-full inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
      Sign up
    </button>

    <p class="text-center text-sm text-slate-600">
      Already have an account?
      <a class="font-semibold text-blue-700 hover:text-blue-800" href="<%= request.getContextPath() %>/login">Login</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

