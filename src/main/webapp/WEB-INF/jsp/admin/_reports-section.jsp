<%-- Admin: view and resolve user reports --%>
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
// Handle report status update via POST (called from admin-reports.jsp)
String reportActionStatus = null;
String reportActionError  = null;
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String reportAction = request.getParameter("reportAction");
    String reportIdStr  = request.getParameter("reportId");
    if ("resolve".equals(reportAction) && reportIdStr != null) {
        try {
            int reportId = Integer.parseInt(reportIdStr);
            String adminEmail = (String) request.getSession().getAttribute("emailValue");
            try (Connection con = Database.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "UPDATE Reports SET status = 'Resolved', admin_email = ? WHERE report_id = ?")) {
                ps.setString(1, adminEmail);
                ps.setInt(2, reportId);
                ps.executeUpdate();
            }
            reportActionStatus = "Report marked as resolved.";
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            reportActionError = "Failed to update report.";
        }
    } else if ("review".equals(reportAction) && reportIdStr != null) {
        try {
            int reportId = Integer.parseInt(reportIdStr);
            String adminEmail = (String) request.getSession().getAttribute("emailValue");
            try (Connection con = Database.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "UPDATE Reports SET status = 'Under Review', admin_email = ? WHERE report_id = ?")) {
                ps.setString(1, adminEmail);
                ps.setInt(2, reportId);
                ps.executeUpdate();
            }
            reportActionStatus = "Report marked as Under Review.";
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            reportActionError = "Failed to update report.";
        }
    }
}

// Load all reports
List<Map<String, Object>> reports = new ArrayList<>();
String reportsSql =
    "SELECT r.report_id, r.category, r.description, r.status, r.created_at, "
  + "r.user_email, u.username AS reporter_username, r.admin_email "
  + "FROM Reports r "
  + "LEFT JOIN Users u ON u.email = r.user_email "
  + "ORDER BY r.created_at DESC";
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(reportsSql);
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        Map<String, Object> rep = new HashMap<>();
        rep.put("id", rs.getInt("report_id"));
        rep.put("category", rs.getString("category"));
        rep.put("description", rs.getString("description"));
        rep.put("status", rs.getString("status"));
        rep.put("createdAt", rs.getString("created_at"));
        rep.put("userEmail", rs.getString("user_email"));
        rep.put("reporterUsername", rs.getString("reporter_username"));
        rep.put("adminEmail", rs.getString("admin_email"));
        reports.add(rep);
    }
} catch (SQLException e) {
    e.printStackTrace();
}

long pendingCount = reports.stream()
    .filter(r -> "Pending".equals(r.get("status"))).count();
%>

<section class="bg-white rounded-2xl shadow-sm p-8 mt-6">
  <div class="flex items-center justify-between">
    <h3 class="text-xl font-semibold text-slate-900">User Reports</h3>
    <div class="flex items-center gap-2">
      <% if (pendingCount > 0) { %>
        <span class="rounded-full bg-red-100 px-3 py-1 text-sm font-semibold text-red-700">
          <%= pendingCount %> pending
        </span>
      <% } %>
      <span class="rounded-lg bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">
        <%= reports.size() %> total
      </span>
    </div>
  </div>

  <% if (reportActionStatus != null) { %>
    <div class="mt-4 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
      <%= reportActionStatus %>
    </div>
  <% } %>
  <% if (reportActionError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= reportActionError %>
    </div>
  <% } %>

  <% if (reports.isEmpty()) { %>
    <div class="mt-6 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-8 text-center text-sm text-slate-600">
      No reports yet.
    </div>
  <% } else { %>
    <div class="mt-6 space-y-3">
      <% for (Map<String, Object> rep : reports) {
           String status = (String) rep.get("status");
           String badgeClass = "bg-slate-100 text-slate-700";
           if ("Pending".equals(status)) badgeClass = "bg-red-100 text-red-700";
           else if ("Under Review".equals(status)) badgeClass = "bg-amber-100 text-amber-700";
           else if ("Resolved".equals(status)) badgeClass = "bg-green-100 text-green-700";
      %>
        <details class="rounded-xl border border-slate-200 bg-slate-50 p-4">
          <summary class="cursor-pointer list-none">
            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div class="flex items-center gap-3">
                <span class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold <%= badgeClass %>">
                  <%= status %>
                </span>
                <p class="text-sm font-semibold text-slate-900"><%= rep.get("category") %></p>
              </div>
              <div class="text-xs text-slate-500">
                By <span class="font-medium"><%= rep.get("reporterUsername") != null ? rep.get("reporterUsername") : rep.get("userEmail") %></span>
                &middot; <%= rep.get("createdAt") %>
              </div>
            </div>
          </summary>

          <div class="mt-3 space-y-3">
            <p class="text-sm text-slate-700 whitespace-pre-wrap"><%= rep.get("description") %></p>
            <% if (rep.get("adminEmail") != null) { %>
              <p class="text-xs text-slate-500">Handled by: <span class="font-mono"><%= rep.get("adminEmail") %></span></p>
            <% } %>

            <% if (!"Resolved".equals(status)) { %>
              <div class="flex gap-2">
                <% if (!"Under Review".equals(status)) { %>
                  <form method="post" action="<%= request.getContextPath() %>/admin-reports" class="inline">
                    <input type="hidden" name="reportAction" value="review" />
                    <input type="hidden" name="reportId" value="<%= rep.get("id") %>" />
                    <button type="submit"
                            class="inline-flex items-center justify-center rounded-lg border border-amber-300 bg-amber-50 px-3 py-1.5 text-xs font-semibold text-amber-700 hover:bg-amber-100">
                      Mark Under Review
                    </button>
                  </form>
                <% } %>
                <form method="post" action="<%= request.getContextPath() %>/admin-reports" class="inline">
                  <input type="hidden" name="reportAction" value="resolve" />
                  <input type="hidden" name="reportId" value="<%= rep.get("id") %>" />
                  <button type="submit"
                          class="inline-flex items-center justify-center rounded-lg border border-green-300 bg-green-50 px-3 py-1.5 text-xs font-semibold text-green-700 hover:bg-green-100">
                    Mark Resolved
                  </button>
                </form>
              </div>
            <% } %>
          </div>
        </details>
      <% } %>
    </div>
  <% } %>
</section>