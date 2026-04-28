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

String email = (String) userSession.getAttribute("emailValue");


if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = trimToNull(request.getParameter("action"));
    String postIdStr = trimToNull(request.getParameter("postId"));

    if (action != null && postIdStr != null) {
        try {
            int postId = Integer.parseInt(postIdStr);

            if ("delete".equals(action)) {
                /* Delete favorites referencing this post first, then the post */
                String delFavSql = "DELETE FROM Favorites WHERE post_ID = ?";
                String delSql = "DELETE FROM Posts WHERE post_ID = ? AND email = ?";
                try (Connection con = Database.getConnection()) {
                    try (PreparedStatement ps = con.prepareStatement(delFavSql)) {
                        ps.setInt(1, postId);
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = con.prepareStatement(delSql)) {
                        ps.setInt(1, postId);
                        ps.setString(2, email);
                        ps.executeUpdate();
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    request.setAttribute("formError", "Could not delete listing.");
                }
            } else if ("mark_sold".equals(action)) {
                String sql = "UPDATE Posts SET item_status = 'Sold' WHERE post_ID = ? AND email = ?";
                try (Connection con = Database.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, postId);
                    ps.setString(2, email);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                    request.setAttribute("formError", "Could not update status.");
                }
            }
        } catch (NumberFormatException ignored) { }
    }

    /* PRG: redirect back after POST unless there was an error */
    if (request.getAttribute("formError") == null) {
        response.sendRedirect(request.getContextPath() + "/my-listings");
        return;
    }
}


String sql = "SELECT p.post_ID, p.title, p.price, p.description, p.picture, "
           + "p.item_status, m.meetup_location "
           + "FROM Posts p "
           + "JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
           + "WHERE p.email = ? "
           + "ORDER BY p.post_ID DESC";

List<Map<String, String>> posts = new ArrayList<>();

try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, email);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> post = new HashMap<>();
            post.put("id", String.valueOf(rs.getInt("post_ID")));
            post.put("title", rs.getString("title"));
            post.put("price", rs.getBigDecimal("price").toPlainString());
            post.put("description", rs.getString("description"));
            post.put("picture", rs.getString("picture"));
            post.put("status", rs.getString("item_status"));
            post.put("meetupLocation", rs.getString("meetup_location"));
            posts.add(post);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

request.setAttribute("myPosts", posts);
%>
<%
  request.setAttribute("pageTitle", "My Listings - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<%
  List<Map<String, String>> myPosts =
      (List<Map<String, String>>) request.getAttribute("myPosts");

  String formError = (String) request.getAttribute("formError");
%>

<%

  int totalCount  = (myPosts != null) ? myPosts.size() : 0;
  int activeCount = 0;
  int soldCount   = 0;
  if (myPosts != null) {
      for (Map<String, String> p : myPosts) {
          if ("Sold".equalsIgnoreCase(p.get("status"))) soldCount++;
          else activeCount++;
      }
  }
%>


<div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
  <div>
    <h2 class="text-2xl font-bold tracking-tight text-slate-900">My Listings Dashboard</h2>
    <p class="mt-1 text-sm text-slate-600">Manage and track your listings.</p>
  </div>
  <a href="<%= request.getContextPath() %>/create-listing"
     class="inline-flex items-center gap-2 justify-center rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-700 transition-colors">
    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15"/></svg>
    New Listing
  </a>
</div>


<div class="mt-6 grid grid-cols-3 gap-4">
  <div class="rounded-xl border border-slate-200 bg-slate-50 px-5 py-4 text-center">
    <p class="text-2xl font-bold text-slate-900"><%= totalCount %></p>
    <p class="mt-0.5 text-xs font-medium text-slate-500 uppercase tracking-wide">Total</p>
  </div>
  <div class="rounded-xl border border-green-200 bg-green-50 px-5 py-4 text-center">
    <p class="text-2xl font-bold text-green-700"><%= activeCount %></p>
    <p class="mt-0.5 text-xs font-medium text-green-600 uppercase tracking-wide">Active</p>
  </div>
  <div class="rounded-xl border border-amber-200 bg-amber-50 px-5 py-4 text-center">
    <p class="text-2xl font-bold text-amber-700"><%= soldCount %></p>
    <p class="mt-0.5 text-xs font-medium text-amber-600 uppercase tracking-wide">Sold</p>
  </div>
</div>

<% if (formError != null) { %>
  <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
    <%= formError %>
  </div>
<% } %>


<% if (myPosts == null || myPosts.isEmpty()) { %>
  <div class="mt-8 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
    <svg class="mx-auto h-10 w-10 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"/></svg>
    <p class="mt-3 text-sm font-semibold text-slate-900">No listings yet</p>
    <p class="mt-1 text-sm text-slate-600">
      <a href="<%= request.getContextPath() %>/create-listing" class="font-semibold text-blue-700 hover:text-blue-800">Create your first listing</a>
      to start selling to the SJSU community.
    </p>
  </div>
<% } else { %>


  <div class="mt-6 flex items-center gap-1 border-b border-slate-200" id="listing-tabs">
    <button type="button" data-tab="active"
            class="tab-btn px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px border-blue-600 text-blue-700">
      Active <span class="ml-1 text-xs font-normal text-slate-500">(<%= activeCount %>)</span>
    </button>
    <button type="button" data-tab="sold"
            class="tab-btn px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px border-transparent text-slate-500 hover:text-slate-700">
      Sold <span class="ml-1 text-xs font-normal text-slate-500">(<%= soldCount %>)</span>
    </button>
  </div>

  
  <div class="mt-5 space-y-4" id="listing-cards">
    <% for (Map<String, String> post : myPosts) {
         String pic = post.get("picture");
         String cardStatus = "Sold".equalsIgnoreCase(post.get("status")) ? "sold" : "active";
    %>
      <div data-status="<%= cardStatus %>">
        <%@ include file="/WEB-INF/jsp/listings/_listing-card.jsp" %>
      </div>
    <% } %>
  </div>


  <div id="tab-empty" class="hidden mt-6 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-8 text-center">
    <p class="text-sm font-semibold text-slate-900" id="tab-empty-msg"></p>
  </div>

  <script>
  (function() {
    var tabs = document.querySelectorAll('#listing-tabs .tab-btn');
    var cards = document.querySelectorAll('#listing-cards > [data-status]');
    var emptyEl = document.getElementById('tab-empty');
    var emptyMsg = document.getElementById('tab-empty-msg');

    function activate(filter) {
      var visibleCount = 0;
      tabs.forEach(function(t) {
        var isActive = t.getAttribute('data-tab') === filter;
        t.className = 'tab-btn px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px '
          + (isActive ? 'border-blue-600 text-blue-700' : 'border-transparent text-slate-500 hover:text-slate-700');
      });
      cards.forEach(function(c) {
        var show = c.getAttribute('data-status') === filter;
        c.style.display = show ? '' : 'none';
        if (show) visibleCount++;
      });
      if (visibleCount === 0) {
        emptyEl.classList.remove('hidden');
        emptyMsg.textContent = filter === 'active'
          ? 'No active listings. All your items have been sold!'
          : 'No sold listings yet.';
      } else {
        emptyEl.classList.add('hidden');
      }
    }

    tabs.forEach(function(t) {
      t.addEventListener('click', function() { activate(t.getAttribute('data-tab')); });
    });

    activate('active');
  })();
  </script>

<% } %>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

