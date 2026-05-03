<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>

<%
String _trim = request.getParameter("category"); // placeholder to open scriptlet

//Define inline instead of as static methods
final List<String> REPORT_CATEGORIES = java.util.Arrays.asList(
 "Scam/Fraud",
 "Inappropriate Language/Hate Speech",
 "Counterfeit Item",
 "Prohibited Item",
 "Harassment",
 "No-Show",
 "Incorrect Category",
 "Spam",
 "Stolen Property",
 "Broken Link/Image",
 "Other"
);
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
String userEmail = (String) userSession.getAttribute("emailValue");

if ("POST".equalsIgnoreCase(request.getMethod())) {
	String category = request.getParameter("category");
	if (category != null) category = category.trim();
	if (category != null && category.isEmpty()) category = null;
	String description = request.getParameter("description");
	if (description != null) description = description.trim();
	if (description != null && description.isEmpty()) description = null;

    if (category == null || !REPORT_CATEGORIES.contains(category)) {
        request.setAttribute("formError", "Please select a valid report category.");
    } else if (description == null) {
        request.setAttribute("formError", "Description is required.");
    } else if (description.length() > 1000) {
        request.setAttribute("formError", "Description must be 1000 characters or fewer.");
    } else {
        String sql = "INSERT INTO Reports (category, description, status, created_at, user_email) "
                   + "VALUES (?, ?, 'Pending', NOW(), ?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setString(2, description);
            ps.setString(3, userEmail);
            ps.executeUpdate();
            response.sendRedirect(request.getContextPath() + "/submit-report?success=1");
            return;
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("formError", "Failed to submit report. Please try again.");
        }
    }
    request.setAttribute("catValue", category);
    request.setAttribute("descValue", description);
}

request.setAttribute("pageTitle", "Submit Report - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-lg bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Submit a Report</h2>
  <p class="mt-1 text-sm text-slate-600">
    Report a listing, user, or message that violates our community guidelines.
    Our admin team will review it promptly.
  </p>

  <% if ("1".equals(request.getParameter("success"))) { %>
    <div class="mt-4 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
      Your report has been submitted. Thank you for helping keep SJSUMarketplace safe.
    </div>
  <% } %>

  <% String formError = (String) request.getAttribute("formError"); %>
  <% if (formError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <% } %>

  <form class="mt-6 space-y-4" method="post"
        action="<%= request.getContextPath() %>/submit-report">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="category">
        Report Category <span class="text-red-500">*</span>
      </label>
      <select id="category" name="category" required
              class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20">
        <option value="">Select a category</option>
        <% String catValue = (String) request.getAttribute("catValue"); %>
        <% for (String cat : REPORT_CATEGORIES) { %>
          <option value="<%= cat %>" <%= cat.equals(catValue) ? "selected" : "" %>><%= cat %></option>
        <% } %>
      </select>
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="description">
        Description <span class="text-red-500">*</span>
      </label>
      <p class="mt-0.5 text-xs text-slate-500">
        Please be specific. Include post IDs, usernames, or message details if relevant.
      </p>
      <textarea id="description" name="description" rows="5" required maxlength="1000"
                class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"><%= request.getAttribute("descValue") != null ? request.getAttribute("descValue") : "" %></textarea>
    </div>

    <button type="submit"
            class="w-full inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
      Submit Report
    </button>

    <p class="text-center text-sm text-slate-600">
      <a class="font-semibold text-blue-700 hover:text-blue-800"
         href="<%= request.getContextPath() %>/listings">&larr; Back to Listings</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>