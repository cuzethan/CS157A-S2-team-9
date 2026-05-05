<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
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

private static void loadCategories(javax.servlet.http.HttpServletRequest request) {
    List<Map<String, String>> categories = new ArrayList<>();
    String sql = "SELECT category_id, category_name FROM Categories ORDER BY category_name";
    try (Connection con = Database.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, String> cat = new HashMap<>();
            cat.put("id", String.valueOf(rs.getInt("category_id")));
            cat.put("name", rs.getString("category_name"));
            categories.add(cat);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    request.setAttribute("listingCategories", categories);
}

private static String trimToEmpty(String value) {
    return value == null ? "" : value.trim();
}
%>
<%
Object _emailAttr = session.getAttribute("emailValue");
String myEmail = (_emailAttr != null && !String.valueOf(_emailAttr).trim().isEmpty())
                 ? (String) _emailAttr : null;
if ("GET".equalsIgnoreCase(request.getMethod())) {
    String q        = trimToEmpty(request.getParameter("q"));
    String location = trimToEmpty(request.getParameter("location"));
    String minPrice = trimToEmpty(request.getParameter("minPrice"));
    String maxPrice = trimToEmpty(request.getParameter("maxPrice"));
    String sort     = trimToEmpty(request.getParameter("sort"));

    Set<Integer> categoryFilterIds = new LinkedHashSet<>();
    String[] categoryParams = request.getParameterValues("category");
    if (categoryParams != null) {
        for (String s : categoryParams) {
            if (s == null) continue;
            String t = s.trim();
            if (t.isEmpty()) continue;
            try {
                int cid = Integer.parseInt(t);
                if (cid > 0) categoryFilterIds.add(cid);
            } catch (NumberFormatException ignored) { }
        }
    }

    StringBuilder sql = new StringBuilder(
        "SELECT p.post_ID, p.title, p.price, p.description, p.picture, "
      + "p.item_status, p.email, m.meetup_location, c.category_name "
      + "FROM Posts p "
      + "JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
      + "INNER JOIN Categories c ON p.category_id = c.category_id "
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

    if (!categoryFilterIds.isEmpty()) {
        sql.append(" AND p.category_id IN (");
        int ci = 0;
        for (Integer cid : categoryFilterIds) {
            if (ci++ > 0) sql.append(",");
            sql.append("?");
            params.add(cid);
        }
        sql.append(")");
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
                String catName = rs.getString("category_name");
                post.put("categoryName", catName != null ? catName : "");
                posts.add(post);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    Set<Integer> favIds = new HashSet<>();
    if (myEmail != null) {
        try (Connection con2 = Database.getConnection();
             PreparedStatement ps2 = con2.prepareStatement(
                 "SELECT post_ID FROM Favorites WHERE email = ?")) {
            ps2.setString(1, myEmail);
            try (ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) favIds.add(rs2.getInt("post_ID"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    loadMeetupLocations(request);
    loadCategories(request);
    Set<String> selectedCategoryIds = new HashSet<>();
    for (Integer cid : categoryFilterIds) {
        selectedCategoryIds.add(String.valueOf(cid));
    }
    request.setAttribute("posts", posts);
    request.setAttribute("favIds", favIds);
    request.setAttribute("filterQ", q);
    request.setAttribute("filterLocation", location);
    request.setAttribute("filterMinPrice", minPrice);
    request.setAttribute("filterMaxPrice", maxPrice);
    request.setAttribute("filterSort", sort);
    request.setAttribute("selectedCategoryIds", selectedCategoryIds);
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
  List<Map<String, String>> listingCategories =
      (List<Map<String, String>>) request.getAttribute("listingCategories");

  String filterQ        = (String) request.getAttribute("filterQ");
  String filterLocation = (String) request.getAttribute("filterLocation");
  String filterMinPrice = (String) request.getAttribute("filterMinPrice");
  String filterMaxPrice = (String) request.getAttribute("filterMaxPrice");
  String filterSort     = (String) request.getAttribute("filterSort");

  Set<Integer> favIds = (Set<Integer>) request.getAttribute("favIds");
  if (favIds == null) favIds = new HashSet<>();

  Set<String> selectedCategoryIds = new HashSet<>();
  Object selCatAttr = request.getAttribute("selectedCategoryIds");
  if (selCatAttr instanceof Set) {
    for (Object o : (Set<?>) selCatAttr) {
      if (o != null) selectedCategoryIds.add(String.valueOf(o));
    }
  }

  if (filterQ == null)        filterQ = "";
  if (filterLocation == null) filterLocation = "";
  if (filterMinPrice == null) filterMinPrice = "";
  if (filterMaxPrice == null) filterMaxPrice = "";
  if (filterSort == null)     filterSort = "";

  String catDropdownSummary = "All categories";
  if (listingCategories != null && selectedCategoryIds != null && !selectedCategoryIds.isEmpty()) {
    List<String> selNames = new ArrayList<>();
    for (Map<String, String> cat : listingCategories) {
      if (selectedCategoryIds.contains(cat.get("id"))) selNames.add(cat.get("name"));
    }
    int n = selNames.size();
    if (n == 1) catDropdownSummary = selNames.get(0);
    else if (n == 2) catDropdownSummary = selNames.get(0) + ", " + selNames.get(1);
    else if (n > 2) catDropdownSummary = selNames.get(0) + ", " + selNames.get(1) + " +" + (n - 2) + " more";
  }
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

      <!-- Categories: compact trigger + dropdown panel (multi-select via checkboxes) -->
      <div class="relative flex-1 min-w-[160px] max-w-[260px]" id="cat-filter-wrap">
        <span class="block text-xs font-medium text-slate-500 mb-1">Categories</span>
        <% if (listingCategories != null && !listingCategories.isEmpty()) { %>
        <button type="button" id="cat-dropdown-trigger"
                class="w-full flex items-center justify-between gap-2 rounded-lg border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-900 shadow-sm hover:border-slate-400 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"
                aria-expanded="false" aria-haspopup="listbox" aria-controls="cat-dropdown-panel">
          <span id="cat-dropdown-label" class="truncate min-w-0"><%= catDropdownSummary %></span>
          <svg id="cat-dropdown-chevron" class="h-4 w-4 flex-shrink-0 text-slate-400 transition-transform" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
          </svg>
        </button>
        <div id="cat-dropdown-panel" role="listbox" aria-multiselectable="true"
             class="hidden absolute left-0 right-0 z-30 mt-1 max-h-52 overflow-y-auto rounded-lg border border-slate-200 bg-white py-1.5 shadow-lg ring-1 ring-black/5">
          <% for (Map<String, String> cat : listingCategories) {
               String cid = cat.get("id");
               boolean catSel = selectedCategoryIds.contains(cid);
          %>
            <label class="flex cursor-pointer items-center gap-2 px-3 py-1.5 text-sm text-slate-800 hover:bg-slate-50">
              <input type="checkbox" name="category" value="<%= cid %>"
                     <%= catSel ? "checked" : "" %>
                     class="rounded border-slate-300 text-blue-600 focus:ring-blue-600/30" />
              <span class="cat-label-text select-none"><%= cat.get("name") %></span>
            </label>
          <% } %>
        </div>
        <% } else { %>
        <div class="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-400 cursor-not-allowed">No categories</div>
        <% } %>
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
        <% if (!filterQ.isEmpty() || !filterLocation.isEmpty() || !selectedCategoryIds.isEmpty()
               || !filterMinPrice.isEmpty() || !filterMaxPrice.isEmpty()) { %>
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
           int pid = Integer.parseInt(post.get("id"));
           boolean isFav = favIds.contains(pid);
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
            <% if (loggedIn) { %>
            <button type="button" onclick="toggleFav(this, <%= pid %>)" data-fav="<%= isFav %>"
                    class="absolute top-1.5 right-1.5 flex items-center justify-center h-8 w-8 rounded-full bg-white/80 backdrop-blur shadow hover:bg-white transition-colors"
                    title="<%= isFav ? "Remove from favorites" : "Add to favorites" %>">
              <svg class="h-5 w-5 <%= isFav ? "text-yellow-400" : "text-slate-400" %>" fill="<%= isFav ? "currentColor" : "none" %>" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.562.562 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.562.562 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/>
              </svg>
            </button>
            <% } %>
          </div>
          <div class="mt-2 px-0.5 flex flex-col flex-1">
            <p class="text-sm font-bold text-slate-900">$<%= post.get("price") %></p>
            <p class="text-[13px] font-normal text-slate-800 line-clamp-2 leading-tight mt-0.5"><%= post.get("title") %></p>
            <% String browseCat = post.get("categoryName");
               if (browseCat != null && !browseCat.isEmpty()) { %>
              <p class="text-[11px] font-medium text-slate-500 truncate mt-0.5"><%= browseCat %></p>
            <% } %>
            <p class="text-[12px] text-slate-500 truncate mt-1">
              <%= post.get("meetupLocation") != null ? post.get("meetupLocation") : "" %>
            </p>
            <% if (loggedIn && myEmail != null && !myEmail.equals(post.get("email"))) { %>
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
//UI script for visual dropdown
(function () {
  var wrap = document.getElementById('cat-filter-wrap');
  var btn = document.getElementById('cat-dropdown-trigger');
  var panel = document.getElementById('cat-dropdown-panel');
  var labelEl = document.getElementById('cat-dropdown-label');
  var chevron = document.getElementById('cat-dropdown-chevron');
  if (!wrap || !btn || !panel || !labelEl) return;

  function formatSummary(names) {
    if (!names.length) return 'All categories';
    if (names.length === 1) return names[0];
    if (names.length === 2) return names[0] + ', ' + names[1];
    return names[0] + ', ' + names[1] + ' +' + (names.length - 2) + ' more';
  }

  function updateCatDropdownLabel() {
    var names = [];
    panel.querySelectorAll('input[name="category"]:checked').forEach(function (cb) {
      var row = cb.closest('label');
      var txt = row ? row.querySelector('.cat-label-text') : null;
      if (txt) names.push(txt.textContent.trim());
    });
    labelEl.textContent = formatSummary(names);
  }

  function setOpen(open) {
    if (open) {
      panel.classList.remove('hidden');
      btn.setAttribute('aria-expanded', 'true');
      if (chevron) chevron.classList.add('rotate-180');
    } else {
      panel.classList.add('hidden');
      btn.setAttribute('aria-expanded', 'false');
      if (chevron) chevron.classList.remove('rotate-180');
    }
  }

  btn.addEventListener('click', function (e) {
    e.preventDefault();
    e.stopPropagation();
    setOpen(panel.classList.contains('hidden'));
  });

  document.addEventListener('click', function (e) {
    if (!panel.classList.contains('hidden') && !wrap.contains(e.target)) {
      setOpen(false);
    }
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !panel.classList.contains('hidden')) {
      setOpen(false);
    }
  });

  panel.querySelectorAll('input[name="category"]').forEach(function (cb) {
    cb.addEventListener('change', updateCatDropdownLabel);
  });
})();

function toggleFav(btn, postId) {
  fetch('<%= request.getContextPath() %>/toggle-favorite', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'postId=' + postId
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.error) return;
    var svg = btn.querySelector('svg');
    if (data.favorited) {
      svg.setAttribute('fill', 'currentColor');
      svg.classList.remove('text-slate-400');
      svg.classList.add('text-yellow-400');
      btn.setAttribute('data-fav', 'true');
      btn.title = 'Remove from favorites';
    } else {
      svg.setAttribute('fill', 'none');
      svg.classList.remove('text-yellow-400');
      svg.classList.add('text-slate-400');
      btn.setAttribute('data-fav', 'false');
      btn.title = 'Add to favorites';
    }
  });
}
</script>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
