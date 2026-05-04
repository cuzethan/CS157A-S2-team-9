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

if (myEmail == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

List<Map<String, String>> favPosts = new ArrayList<>();

String sql = "SELECT p.post_ID, p.title, p.price, p.description, p.picture, "
           + "p.item_status, p.email, m.meetup_location, f.saved_at "
           + "FROM Favorites f "
           + "JOIN Posts p ON f.post_ID = p.post_ID "
           + "JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
           + "WHERE f.email = ? "
           + "ORDER BY f.saved_at DESC";

try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, myEmail);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> post = new HashMap<>();
            post.put("id", String.valueOf(rs.getInt("post_ID")));
            post.put("title", rs.getString("title"));
            post.put("price", rs.getBigDecimal("price").toPlainString());
            post.put("description", rs.getString("description"));
            post.put("picture", rs.getString("picture"));
            post.put("status", rs.getString("item_status"));
            post.put("email", rs.getString("email"));
            post.put("meetupLocation", rs.getString("meetup_location"));
            favPosts.add(post);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

request.setAttribute("favPosts", favPosts);
%>
<%
  request.setAttribute("pageTitle", "Favorites - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<%
  List<Map<String, String>> posts = (List<Map<String, String>>) request.getAttribute("favPosts");
%>

<div class="bg-white rounded-2xl shadow-sm p-8">
  <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
    <div>
      <h2 class="text-2xl font-bold tracking-tight text-slate-900">Favorites</h2>
      <p class="mt-1 text-sm text-slate-600">Items you've saved for later.</p>
    </div>
    <a href="<%= request.getContextPath() %>/listings"
       class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50 shadow-sm">
      Browse Listings
    </a>
  </div>

  <% if (posts == null || posts.isEmpty()) { %>
    <div class="mt-8 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
      <svg class="mx-auto h-10 w-10 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.562.562 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.562.562 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/>
      </svg>
      <p class="mt-3 text-sm font-semibold text-slate-900">No favorites yet</p>
      <p class="mt-1 text-sm text-slate-600">
        Star items on the <a href="<%= request.getContextPath() %>/listings" class="font-semibold text-blue-700 hover:text-blue-800">listings page</a> to save them here.
      </p>
    </div>
  <% } else { %>
    <div class="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
      <% for (Map<String, String> post : posts) {
           String pic = post.get("picture");
           int pid = Integer.parseInt(post.get("id"));
           boolean isSold = "Sold".equalsIgnoreCase(post.get("status"));
      %>
        <div class="group cursor-pointer flex flex-col <%= isSold ? "opacity-70" : "" %>" id="fav-card-<%= pid %>">
          <div class="relative aspect-square overflow-hidden rounded-lg bg-slate-100 flex-shrink-0">
            <% if (pic != null && !pic.isEmpty()) { %>
              <img src="<%= pic %>" alt="<%= post.get("title") %>"
                   class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
            <% } else { %>
              <div class="h-full w-full flex items-center justify-center">
                <span class="text-slate-400 text-xs">No image</span>
              </div>
            <% } %>
            <% if (isSold) { %>
              <div class="absolute top-1.5 left-1.5 rounded-full bg-amber-100 px-2 py-0.5 text-[10px] font-semibold text-amber-800">Sold</div>
            <% } %>
            <button type="button" onclick="toggleFav(this, <%= pid %>)" data-fav="true"
                    class="absolute top-1.5 right-1.5 flex items-center justify-center h-8 w-8 rounded-full bg-white/80 backdrop-blur shadow hover:bg-white transition-colors"
                    title="Remove from favorites">
              <svg class="h-5 w-5 text-yellow-400" fill="currentColor" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.562.562 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.562.562 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/>
              </svg>
            </button>
          </div>
          <div class="mt-2 px-0.5 flex flex-col flex-1">
            <p class="text-sm font-bold text-slate-900">$<%= post.get("price") %></p>
            <p class="text-[13px] font-normal text-slate-800 line-clamp-2 leading-tight mt-0.5"><%= post.get("title") %></p>
            <p class="text-[12px] text-slate-500 truncate mt-1">
              <%= post.get("meetupLocation") != null ? post.get("meetupLocation") : "" %>
            </p>
            <% if (loggedIn && myEmail != null && !myEmail.equals(post.get("email")) && !isSold) { %>
              <a href="<%= request.getContextPath() %>/messages?with=<%= java.net.URLEncoder.encode(post.get("email"), "UTF-8") %>"
                 class="mt-2 inline-flex items-center justify-center rounded-lg bg-blue-50 border border-blue-200 px-2.5 py-1 text-[11px] font-semibold text-blue-700 hover:bg-blue-100">
                Message Seller
              </a>
            <% } %>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</div>

<script>
function toggleFav(btn, postId) {
  fetch('<%= request.getContextPath() %>/toggle-favorite', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'postId=' + postId
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.error) return;
    if (!data.favorited) {
      var card = document.getElementById('fav-card-' + postId);
      if (card) {
        card.style.transition = 'opacity 0.3s, transform 0.3s';
        card.style.opacity = '0';
        card.style.transform = 'scale(0.95)';
        setTimeout(function() {
          card.remove();
          var grid = document.querySelector('.grid');
          if (grid && grid.children.length === 0) location.reload();
        }, 300);
      }
    }
  });
}
</script>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
