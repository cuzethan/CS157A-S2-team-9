<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%!
private static void loadMeetupLocations(javax.servlet.http.HttpServletRequest request) {
    List<Map<String, String>> locations = new ArrayList<>();
    String sql = "SELECT meetupID, meetup_location FROM MeetupLocation ORDER BY meetup_location";
    try (Connection con = Database.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> loc = new HashMap<>();
            loc.put("id", String.valueOf(rs.getInt("meetupID")));
            loc.put("name", rs.getString("meetup_location"));
            locations.add(loc);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    request.setAttribute("meetupLocations", locations);
}

private static String trimToEmpty(String value) {
    return value == null ? "" : value.trim();
}
%>
<%
if ("GET".equalsIgnoreCase(request.getMethod())) {
    String q        = trimToEmpty(request.getParameter("q"));
    String location = trimToEmpty(request.getParameter("location"));
    String minPrice = trimToEmpty(request.getParameter("minPrice"));
    String maxPrice = trimToEmpty(request.getParameter("maxPrice"));
    String sort     = trimToEmpty(request.getParameter("sort"));

    StringBuilder sql = new StringBuilder(
        "SELECT p.post_ID, p.title, p.price, p.description, p.picture, "
      + "p.item_status, p.email, m.meetup_location "
      + "FROM Posts p "
      + "LEFT JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
      + "WHERE p.item_status = 'Available'"
    );
    List<Object> params = new ArrayList<>();

    if (!q.isEmpty()) {
        sql.append(" AND (p.title LIKE ? OR p.description LIKE ?)");
        params.add("%" + q + "%");
        params.add("%" + q + "%");
    }

    if (!location.isEmpty()) {
        try {
            int locId = Integer.parseInt(location);
            sql.append(" AND p.meetup_id = ?");
            params.add(locId);
        } catch (NumberFormatException ignored) { }
    }

    if (!minPrice.isEmpty()) {
        try {
            BigDecimal min = new BigDecimal(minPrice);
            sql.append(" AND p.price >= ?");
            params.add(min);
        } catch (NumberFormatException ignored) { }
    }

    if (!maxPrice.isEmpty()) {
        try {
            BigDecimal max = new BigDecimal(maxPrice);
            sql.append(" AND p.price <= ?");
            params.add(max);
        } catch (NumberFormatException ignored) { }
    }

    if ("price_asc".equals(sort)) {
        sql.append(" ORDER BY p.price ASC");
    } else if ("price_desc".equals(sort)) {
        sql.append(" ORDER BY p.price DESC");
    } else {
        sql.append(" ORDER BY p.post_ID DESC");
    }

    List<Map<String, String>> posts = new ArrayList<>();

    try (Connection con = Database.getConnection();
         PreparedStatement ps = con.prepareStatement(sql.toString())) {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof BigDecimal) {
                ps.setBigDecimal(i + 1, (BigDecimal) param);
            } else if (param instanceof Integer) {
                ps.setInt(i + 1, (Integer) param);
            } else {
                ps.setString(i + 1, param.toString());
            }
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> post = new HashMap<>();
                post.put("id", String.valueOf(rs.getInt("post_ID")));
                post.put("title", rs.getString("title"));
                post.put("price", rs.getBigDecimal("price").toPlainString());
                post.put("description", rs.getString("description"));
                post.put("picture", rs.getString("picture"));
                post.put("meetupLocation", rs.getString("meetup_location"));
                post.put("email", rs.getString("email"));
                posts.add(post);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    loadMeetupLocations(request);
    request.setAttribute("posts", posts);
    request.setAttribute("filterQ", q);
    request.setAttribute("filterLocation", location);
    request.setAttribute("filterMinPrice", minPrice);
    request.setAttribute("filterMaxPrice", maxPrice);
    request.setAttribute("filterSort", sort);
}
%>
<%
  request.setAttribute("pageTitle", "Listings - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<%
  List<Map<String, String>> posts =
      (List<Map<String, String>>) request.getAttribute("posts");

  List<Map<String, String>> meetupLocations =
      (List<Map<String, String>>) request.getAttribute("meetupLocations");

  String filterQ        = (String) request.getAttribute("filterQ");
  String filterLocation = (String) request.getAttribute("filterLocation");
  String filterMinPrice = (String) request.getAttribute("filterMinPrice");
  String filterMaxPrice = (String) request.getAttribute("filterMaxPrice");
  String filterSort     = (String) request.getAttribute("filterSort");

  if (filterQ == null)        filterQ = "";
  if (filterLocation == null) filterLocation = "";
  if (filterMinPrice == null) filterMinPrice = "";
  if (filterMaxPrice == null) filterMaxPrice = "";
  if (filterSort == null)     filterSort = "";
%>

<div class="bg-white rounded-2xl shadow-sm p-8">
  <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
    <div>
      <h2 class="text-2xl font-bold tracking-tight text-slate-900">Listings</h2>
      <p class="mt-1 text-sm text-slate-600">Browse items posted by students.</p>
    </div>
    <a href="<%= request.getContextPath() %>/create-listing"
       class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
      Create listing
    </a>
  </div>

  <!-- ── Search & Filters ──────────────────────────────────────── -->
  <form method="get" action="<%= request.getContextPath() %>/listings" class="mt-6">
    <!-- Search bar -->
    <div class="relative">
      <span class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400">
        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m0 0A7.5 7.5 0 1 0 5.1 5.1a7.5 7.5 0 0 0 11.55 11.55z"/>
        </svg>
      </span>
      <input id="search-input" name="q" type="text" placeholder="Search items..."
             value="<%= filterQ %>"
             class="w-full rounded-lg border border-slate-300 bg-white py-2.5 pl-10 pr-4 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <!-- Filter row -->
    <div class="mt-3 flex flex-wrap items-end gap-3">
      <!-- Location -->
      <div class="flex-1 min-w-[140px]">
        <label class="block text-xs font-medium text-slate-500 mb-1" for="filter-location">Location</label>
        <select id="filter-location" name="location"
                class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20">
          <option value="">All locations</option>
          <% if (meetupLocations != null) {
               for (Map<String, String> loc : meetupLocations) {
                 String sel = loc.get("id").equals(filterLocation) ? "selected" : "";
          %>
            <option value="<%= loc.get("id") %>" <%= sel %>><%= loc.get("name") %></option>
          <%   }
             }
          %>
        </select>
      </div>

      <!-- Min price -->
      <div class="w-28">
        <label class="block text-xs font-medium text-slate-500 mb-1" for="filter-min-price">Min $</label>
        <input id="filter-min-price" name="minPrice" type="number" step="0.01" min="0"
               value="<%= filterMinPrice %>" placeholder="0"
               class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
      </div>

      <!-- Max price -->
      <div class="w-28">
        <label class="block text-xs font-medium text-slate-500 mb-1" for="filter-max-price">Max $</label>
        <input id="filter-max-price" name="maxPrice" type="number" step="0.01" min="0"
               value="<%= filterMaxPrice %>" placeholder="Any"
               class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
      </div>

      <!-- Sort -->
      <div class="w-40">
        <label class="block text-xs font-medium text-slate-500 mb-1" for="filter-sort">Sort by</label>
        <select id="filter-sort" name="sort"
                class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20">
          <option value="" <%= filterSort.isEmpty() ? "selected" : "" %>>Newest first</option>
          <option value="price_asc" <%= "price_asc".equals(filterSort) ? "selected" : "" %>>Price: Low to High</option>
          <option value="price_desc" <%= "price_desc".equals(filterSort) ? "selected" : "" %>>Price: High to Low</option>
        </select>
      </div>

      <!-- Buttons -->
      <div class="flex items-end gap-2">
        <button type="submit"
                class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 shadow-sm">
          Apply
        </button>
        <a href="<%= request.getContextPath() %>/listings"
           class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 shadow-sm">
          Clear
        </a>
      </div>
    </div>
  </form>

  <% if (posts == null || posts.isEmpty()) { %>
    <div class="mt-8 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
      <p class="text-sm font-semibold text-slate-900">No listings found</p>
      <p class="mt-2 text-sm text-slate-600">
        <% if (!filterQ.isEmpty() || !filterLocation.isEmpty() || !filterMinPrice.isEmpty() || !filterMaxPrice.isEmpty()) { %>
          Try adjusting your filters or <a href="<%= request.getContextPath() %>/listings" class="font-semibold text-blue-700 hover:text-blue-800">clear all filters</a>.
        <% } else { %>
          Be the first to post an item for sale!
        <% } %>
      </p>
    </div>
  <% } else { %>
    <div class="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
      <% for (Map<String, String> post : posts) {
           String pic = post.get("picture");
      %>
        <div class="group cursor-pointer flex flex-col">
          <div class="aspect-square overflow-hidden rounded-lg bg-slate-100 flex-shrink-0">
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
            <p class="text-[12px] text-slate-500 truncate mt-1">
              <%= post.get("meetupLocation") != null ? post.get("meetupLocation") : "" %>
            </p>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
