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

String targetUsername = request.getParameter("user");
if (targetUsername == null || targetUsername.trim().isEmpty()) {
    if (myEmail == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    targetUsername = (String) session.getAttribute("usernameValue");
}
targetUsername = targetUsername.trim();

String profileEmail = null;
String profileUsername = null;

try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT email, username FROM Users WHERE username = ?")) {
    ps.setString(1, targetUsername);
    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            profileEmail = rs.getString("email");
            profileUsername = rs.getString("username");
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

if (profileEmail == null) {
    response.sendRedirect(request.getContextPath() + "/listings");
    return;
}

boolean isOwnProfile = myEmail != null && myEmail.equals(profileEmail);
boolean isFollowing = false;
int followersCount = 0;
int followingCount = 0;
int listingCount = 0;

try (Connection con = Database.getConnection()) {
    try (PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) FROM Following WHERE user_email2 = ?")) {
        ps.setString(1, profileEmail);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) followersCount = rs.getInt(1);
        }
    }

    try (PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) FROM Following WHERE user_email1 = ?")) {
        ps.setString(1, profileEmail);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) followingCount = rs.getInt(1);
        }
    }

    try (PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) FROM Posts WHERE email = ? AND item_status = 'Available'")) {
        ps.setString(1, profileEmail);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) listingCount = rs.getInt(1);
        }
    }

    if (myEmail != null && !isOwnProfile) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT 1 FROM Following WHERE user_email1 = ? AND user_email2 = ?")) {
            ps.setString(1, myEmail);
            ps.setString(2, profileEmail);
            try (ResultSet rs = ps.executeQuery()) {
                isFollowing = rs.next();
            }
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

List<Map<String, String>> posts = new ArrayList<>();
String sql = "SELECT p.post_ID, p.title, p.price, p.picture, p.item_status, "
           + "m.meetup_location, c.category_name "
           + "FROM Posts p "
           + "JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
           + "JOIN Categories c ON p.category_id = c.category_id "
           + "WHERE p.email = ? AND p.item_status = 'Available' "
           + "ORDER BY p.post_ID DESC";
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, profileEmail);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> post = new HashMap<>();
            post.put("id", String.valueOf(rs.getInt("post_ID")));
            post.put("title", rs.getString("title"));
            post.put("price", rs.getBigDecimal("price").toPlainString());
            post.put("picture", rs.getString("picture"));
            post.put("meetupLocation", rs.getString("meetup_location"));
            String catName = rs.getString("category_name");
            post.put("categoryName", catName != null ? catName : "");
            posts.add(post);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

String safeUsername = profileUsername.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
request.setAttribute("pageTitle", safeUsername + " - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>
<%
String profileInitial = profileUsername.length() > 0 ? String.valueOf(profileUsername.charAt(0)).toUpperCase() : "";
%>

<div class="bg-white rounded-2xl shadow-sm p-8">
  <!-- Profile header -->
  <div class="flex flex-col sm:flex-row sm:items-center gap-6">
    <div class="flex h-20 w-20 items-center justify-center rounded-full bg-blue-600 text-white text-3xl font-bold flex-shrink-0">
      <%= profileInitial %>
    </div>
    <div class="flex-1">
      <h2 class="text-2xl font-bold tracking-tight text-slate-900"><%= safeUsername %></h2>
      <div class="mt-2 flex flex-wrap gap-4 text-sm text-slate-600">
        <a href="<%= ctx %>/following?user=<%= java.net.URLEncoder.encode(profileUsername, "UTF-8") %>&tab=followers" class="hover:text-blue-700 transition-colors">
          <span class="font-bold text-slate-900"><%= followersCount %></span> Followers
        </a>
        <a href="<%= ctx %>/following?user=<%= java.net.URLEncoder.encode(profileUsername, "UTF-8") %>&tab=following" class="hover:text-blue-700 transition-colors">
          <span class="font-bold text-slate-900"><%= followingCount %></span> Following
        </a>
        <span>
          <span class="font-bold text-slate-900"><%= listingCount %></span> Listings
        </span>
      </div>
      <div class="mt-4 flex flex-wrap gap-2">
        <% if (isOwnProfile) { %>
          <a href="<%= ctx %>/following"
             class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50 shadow-sm">
            My Followers &amp; Following
          </a>
        <% } else if (myEmail != null) { %>
          <button type="button" id="follow-btn" onclick="toggleFollow()"
                  class="inline-flex items-center justify-center rounded-lg px-4 py-2 text-sm font-semibold shadow-sm transition-colors
                         <%= isFollowing ? "border border-slate-300 bg-white text-slate-700 hover:bg-slate-50" : "bg-blue-600 text-white hover:bg-blue-700" %>">
            <%= isFollowing ? "Unfollow" : "Follow" %>
          </button>
          <a href="<%= ctx %>/messages?with=<%= java.net.URLEncoder.encode(profileEmail, "UTF-8") %>"
             class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50 shadow-sm">
            Message
          </a>
        <% } else { %>
          <a href="<%= ctx %>/login"
             class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 shadow-sm">
            Log in to Follow
          </a>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Listings -->
  <div class="mt-8">
    <h3 class="text-lg font-bold text-slate-900">Active Listings</h3>
    <% if (posts.isEmpty()) { %>
      <div class="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
        <p class="text-sm text-slate-600">
          <% if (isOwnProfile) { %>
            You don't have any active listings. <a href="<%= ctx %>/create-listing" class="font-semibold text-blue-700 hover:text-blue-800">Create one</a>.
          <% } else { %>
            This user has no active listings.
          <% } %>
        </p>
      </div>
    <% } else { %>
      <div class="mt-4 grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
        <% for (Map<String, String> post : posts) {
             String pic = post.get("picture");
        %>
          <div class="group cursor-pointer flex flex-col">
            <div class="relative aspect-square overflow-hidden rounded-lg bg-slate-100 flex-shrink-0">
              <% if (pic != null && !pic.isEmpty()) { %>
                <img src="<%= pic %>" alt="<%= post.get("title") %>"
                     class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
              <% } else { %>
                <div class="h-full w-full flex items-center justify-center">
                  <span class="text-slate-400 text-xs">No image</span>
                </div>
              <% } %>
            </div>
            <div class="mt-2 px-0.5 flex flex-col flex-1">
              <p class="text-sm font-bold text-slate-900">$<%= post.get("price") %></p>
              <p class="text-[13px] font-normal text-slate-800 line-clamp-2 leading-tight mt-0.5"><%= post.get("title") %></p>
              <% String pCat = post.get("categoryName");
                 if (pCat != null && !pCat.isEmpty()) { %>
                <p class="text-[11px] font-medium text-slate-500 truncate mt-0.5"><%= pCat %></p>
              <% } %>
              <p class="text-[12px] text-slate-500 truncate mt-1">
                <%= post.get("meetupLocation") != null ? post.get("meetupLocation") : "" %>
              </p>
            </div>
          </div>
        <% } %>
      </div>
    <% } %>
  </div>
</div>

<% if (myEmail != null && !isOwnProfile) { %>
<script>
var following = <%= isFollowing %>;
function toggleFollow() {
  fetch('<%= ctx %>/toggle-follow', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'targetEmail=<%= java.net.URLEncoder.encode(profileEmail, "UTF-8") %>'
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.error) return;
    following = data.following;
    var btn = document.getElementById('follow-btn');
    if (following) {
      btn.textContent = 'Unfollow';
      btn.className = 'inline-flex items-center justify-center rounded-lg px-4 py-2 text-sm font-semibold shadow-sm transition-colors border border-slate-300 bg-white text-slate-700 hover:bg-slate-50';
    } else {
      btn.textContent = 'Follow';
      btn.className = 'inline-flex items-center justify-center rounded-lg px-4 py-2 text-sm font-semibold shadow-sm transition-colors bg-blue-600 text-white hover:bg-blue-700';
    }
    // Update follower count on the page
    var links = document.querySelectorAll('a[href*="tab=followers"]');
    if (links.length > 0) {
      var span = links[0].querySelector('span');
      if (span) {
        var count = parseInt(span.textContent) + (following ? 1 : -1);
        span.textContent = count;
      }
    }
  });
}
</script>
<% } %>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
