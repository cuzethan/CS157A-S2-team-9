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

  String currentAdminEmail = (String) adminSession.getAttribute("emailValue");
  String formError = null;
  String formSuccess = null;
  
  // Sorting is controlled by URL params so header clicks can cycle asc -> desc -> unsorted.
  String sort = request.getParameter("sort");
  String dir = request.getParameter("dir");
  if (sort != null) sort = sort.toLowerCase();
  if (dir != null) dir = dir.toLowerCase();

  // Allowlist user-facing sort keys to known SQL expressions.
  // We never inject raw request values into ORDER BY.
  String sortColumn = null;
  if ("email".equals(sort)) {
    sortColumn = "u.email";
  } else if ("username".equals(sort)) {
    sortColumn = "u.username";
  } else if ("hasposts".equals(sort)) {
    sortColumn = "hasPosts";
  } else if ("isadmin".equals(sort)) {
    sortColumn = "isAdmin";
  } else {
    sort = null;
  }

  boolean validDirection = "asc".equals(dir) || "desc".equals(dir);
  if (sort == null || !validDirection) {
    sort = null;
    dir = null;
    sortColumn = null;
  }

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    String targetEmail = request.getParameter("targetEmail");

    if ("deleteUser".equals(action)) {
      if (targetEmail == null || targetEmail.trim().isEmpty()) {
        formError = "Missing target user account.";
      } else if (currentAdminEmail != null && currentAdminEmail.equalsIgnoreCase(targetEmail.trim())) {
        formError = "You cannot terminate your own account.";
      } else {
        Connection con = null;
        try {
          con = Database.getConnection();
          con.setAutoCommit(false);

          // Admin accounts are protected and cannot be terminated.
          boolean targetIsAdmin = false;
          try (PreparedStatement checkAdmin = con.prepareStatement(
                   "SELECT 1 FROM Administrators WHERE email = ?")) {
            checkAdmin.setString(1, targetEmail);
            try (ResultSet adminRs = checkAdmin.executeQuery()) {
              targetIsAdmin = adminRs.next();
            }
          }

          if (targetIsAdmin) {
            con.rollback();
            formError = "Admin accounts cannot be deleted.";
          } else {
            // Delete dependent posts first, then delete the user row in one transaction.
            // This keeps user/post data consistent if any statement fails.
            try (PreparedStatement deletePosts = con.prepareStatement("DELETE FROM Posts WHERE email = ?");
                 PreparedStatement deleteUser = con.prepareStatement("DELETE FROM Users WHERE email = ?")) {
              deletePosts.setString(1, targetEmail);
              deletePosts.executeUpdate();

              deleteUser.setString(1, targetEmail);
              int usersDeleted = deleteUser.executeUpdate();

              if (usersDeleted <= 0) {
                con.rollback();
                formError = "No user was deleted. The account may no longer exist.";
              } else {
                con.commit();
                formSuccess = "User account terminated successfully.";
              }
            }
          }
        } catch (SQLException e) {
          formError = "Failed to terminate account. Please try again.";
          if (con != null) {
            try {
              con.rollback();
            } catch (SQLException ignored) { }
          }
          e.printStackTrace();
        } finally {
          if (con != null) {
            try {
              con.setAutoCommit(true);
            } catch (SQLException ignored) { }
            try {
              con.close();
            } catch (SQLException ignored) { }
          }
        }
      }
    }
  }

  List<Map<String, Object>> users = new ArrayList<>();
  // Pull user basics and compute booleans from related tables without extra round trips.
  String usersSql =
      "SELECT u.email, u.username, "
    + "EXISTS (SELECT 1 FROM Posts p WHERE p.email = u.email) AS hasPosts, "
    + "EXISTS (SELECT 1 FROM Administrators a WHERE a.email = u.email) AS isAdmin "
    + "FROM Users u";
  // Apply ORDER BY only when a validated sort choice exists.
  // Secondary username sort keeps ordering stable when values tie.
  if (sortColumn != null) {
    usersSql += " ORDER BY " + sortColumn + " " + dir + ", u.username ASC";
  }

  try (Connection con = Database.getConnection();
       PreparedStatement ps = con.prepareStatement(usersSql);
       ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
      Map<String, Object> user = new HashMap<>();
      user.put("email", rs.getString("email"));
      user.put("username", rs.getString("username"));
      user.put("hasPosts", rs.getBoolean("hasPosts"));
      user.put("isAdmin", rs.getBoolean("isAdmin"));
      users.add(user);
    }
  } catch (SQLException e) {
    formError = "Unable to load user accounts right now.";
    e.printStackTrace();
  }
%>
<%
  request.setAttribute("pageTitle", "Admin - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="space-y-6">
  <section class="bg-white rounded-2xl shadow-sm p-8">
    <h2 class="text-3xl font-bold tracking-tight text-slate-900">Admin Dashboard</h2>
    <p class="mt-2 text-sm text-slate-600">Manage user accounts and posts here!</p>
  </section>

  <section class="bg-white rounded-2xl shadow-sm p-8">
    <div class="flex items-center justify-between">
      <h3 class="text-xl font-semibold text-slate-900">Manage User Accounts</h3>
      <span class="rounded-lg bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">
        <%= users.size() %> users
      </span>
    </div>
    <div class="mt-4">
      <label for="userSearch" class="sr-only">Search users</label>
      <input
        id="userSearch"
        type="search"
        placeholder="Search by email or username"
        class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-800 placeholder:text-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200"
      />
    </div>

    <% if (formError != null) { %>
      <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
        <%= formError %>
      </div>
    <% } %>

    <% if (formSuccess != null) { %>
      <div class="mt-4 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
        <%= formSuccess %>
      </div>
    <% } %>

    <div class="mt-6 overflow-hidden rounded-xl border border-slate-200">
      <div class="grid grid-cols-5 gap-4 border-b border-slate-200 bg-slate-50 px-4 py-3 text-xs font-semibold uppercase tracking-wide text-slate-600">
        <div>
          <a href="<%= request.getContextPath() %>/admin<%= "email".equals(sort) ? ("asc".equals(dir) ? "?sort=email&dir=desc" : ("desc".equals(dir) ? "" : "?sort=email&dir=asc")) : "?sort=email&dir=asc" %>"
             class="inline-flex items-center gap-1 hover:text-slate-900">
            Email
            <%= "email".equals(sort) ? ("asc".equals(dir) ? "↑" : "↓") : "" %>
          </a>
        </div>
        <div>
          <a href="<%= request.getContextPath() %>/admin<%= "username".equals(sort) ? ("asc".equals(dir) ? "?sort=username&dir=desc" : ("desc".equals(dir) ? "" : "?sort=username&dir=asc")) : "?sort=username&dir=asc" %>"
             class="inline-flex items-center gap-1 hover:text-slate-900">
            Username
            <%= "username".equals(sort) ? ("asc".equals(dir) ? "↑" : "↓") : "" %>
          </a>
        </div>
        <div>
          <a href="<%= request.getContextPath() %>/admin<%= "hasposts".equals(sort) ? ("asc".equals(dir) ? "?sort=hasPosts&dir=desc" : ("desc".equals(dir) ? "" : "?sort=hasPosts&dir=asc")) : "?sort=hasPosts&dir=asc" %>"
             class="inline-flex items-center gap-1 hover:text-slate-900">
            Has Posts
            <%= "hasposts".equals(sort) ? ("asc".equals(dir) ? "↑" : "↓") : "" %>
          </a>
        </div>
        <div>
          <a href="<%= request.getContextPath() %>/admin<%= "isadmin".equals(sort) ? ("asc".equals(dir) ? "?sort=isAdmin&dir=desc" : ("desc".equals(dir) ? "" : "?sort=isAdmin&dir=asc")) : "?sort=isAdmin&dir=asc" %>"
             class="inline-flex items-center gap-1 hover:text-slate-900">
            Is Admin
            <%= "isadmin".equals(sort) ? ("asc".equals(dir) ? "↑" : "↓") : "" %>
          </a>
        </div>
        <div>Action</div>
      </div>

      <div class="max-h-[520px] overflow-y-auto divide-y divide-slate-100">
        <% if (users.isEmpty()) { %>
          <div class="px-4 py-10 text-center text-sm text-slate-600">No users found.</div>
        <% } else { %>
          <% for (Map<String, Object> user : users) {
               String email = (String) user.get("email");
               String username = (String) user.get("username");
               boolean hasPosts = Boolean.TRUE.equals(user.get("hasPosts"));
               boolean isAdminUser = Boolean.TRUE.equals(user.get("isAdmin"));
               boolean isCurrentAccount = currentAdminEmail != null && currentAdminEmail.equalsIgnoreCase(email);
          %>
            <div class="user-row grid grid-cols-5 items-center gap-4 px-4 py-3 text-sm"
                 data-email="<%= email.toLowerCase() %>"
                 data-username="<%= username.toLowerCase() %>">
              <div class="truncate text-slate-800"><%= email %></div>
              <div class="truncate font-medium text-slate-900"><%= username %></div>
              <div class="<%= hasPosts ? "text-emerald-600" : "text-slate-400" %>"><%= hasPosts ? "✓" : "—" %></div>
              <div class="<%= isAdminUser ? "text-indigo-600" : "text-slate-400" %>"><%= isAdminUser ? "✓" : "—" %></div>
              <div>
                <% if (isCurrentAccount) { %>
                  <button type="button" disabled
                          class="inline-flex cursor-not-allowed items-center justify-center rounded-lg border border-slate-200 bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-400">
                    Current account
                  </button>
                <% } else if (isAdminUser) { %>
                  <button type="button" disabled
                          class="inline-flex cursor-not-allowed items-center justify-center rounded-lg border border-slate-200 bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-400">
                    Admin protected
                  </button>
                <% } else { %>
                  <form method="post" action="<%= request.getContextPath() %>/admin" class="inline">
                    <input type="hidden" name="action" value="deleteUser" />
                    <input type="hidden" name="targetEmail" value="<%= email %>" />
                    <button type="submit"
                            class="inline-flex items-center justify-center rounded-lg border border-red-200 bg-red-50 px-3 py-1.5 text-xs font-semibold text-red-700 hover:bg-red-100">
                      Delete
                    </button>
                  </form>
                <% } %>
              </div>
            </div>
          <% } %>
        <% } %>
      </div>
    </div>
  </section>
</div>

<script>
  // Simpled search function for user accounts (I felt like sql would be overkill for this)
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

