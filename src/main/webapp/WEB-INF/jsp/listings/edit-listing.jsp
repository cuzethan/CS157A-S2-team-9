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

private static String validateListing(String title, String priceStr, String description, String meetupId) {
    if (title == null || title.isEmpty()) {
        return "Item title is required.";
    }
    if (title.length() > 45) {
        return "Item title must be 45 characters or fewer.";
    }
    if (priceStr == null || priceStr.isEmpty()) {
        return "Price is required.";
    }
    try {
        BigDecimal price = new BigDecimal(priceStr);
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            return "Price must be greater than $0.00.";
        }
    } catch (NumberFormatException e) {
        return "Price must be a valid number.";
    }
    if (description == null || description.isEmpty()) {
        return "Description is required.";
    }
    if (meetupId == null || meetupId.isEmpty()) {
        return "Meetup location is required.";
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
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

String email = (String) userSession.getAttribute("emailValue");
String postIdStr = trimToNull(request.getParameter("id"));

if (postIdStr == null) {
    response.sendRedirect(request.getContextPath() + "/my-listings");
    return;
}

int postId;
try {
    postId = Integer.parseInt(postIdStr);
} catch (NumberFormatException e) {
    response.sendRedirect(request.getContextPath() + "/my-listings");
    return;
}


if ("POST".equalsIgnoreCase(request.getMethod())) {
    String title = trimToNull(request.getParameter("title"));
    String priceStr = trimToNull(request.getParameter("price"));
    String description = trimToNull(request.getParameter("description"));
    String picture = trimToNull(request.getParameter("picture"));
    String locationDetails = trimToNull(request.getParameter("locationDetails"));
    String meetupIdStr = trimToNull(request.getParameter("meetupId"));

    request.setAttribute("titleValue", title);
    request.setAttribute("priceValue", priceStr);
    request.setAttribute("descriptionValue", description);
    request.setAttribute("pictureValue", picture);
    request.setAttribute("locationValue", locationDetails);
    request.setAttribute("meetupValue", meetupIdStr);

    String error = validateListing(title, priceStr, description, meetupIdStr);
    if (error != null) {
        request.setAttribute("formError", error);
        loadMeetupLocations(request);
    } else {
        BigDecimal price = new BigDecimal(priceStr);
        int meetupId = Integer.parseInt(meetupIdStr);
        String sql = "UPDATE Posts SET title = ?, price = ?, description = ?, picture = ?, "
                   + "location_details_specific = ?, meetup_id = ? "
                   + "WHERE post_ID = ? AND email = ?";

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setBigDecimal(2, price);
            ps.setString(3, description);
            ps.setString(4, picture);
            ps.setString(5, locationDetails);
            ps.setInt(6, meetupId);
            ps.setInt(7, postId);
            ps.setString(8, email);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                request.setAttribute("formError", "Listing not found or you do not have permission to edit it.");
                loadMeetupLocations(request);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("formError", "Database error: " + e.getMessage());
            loadMeetupLocations(request);
        }

        if (request.getAttribute("formError") == null) {
            response.sendRedirect(request.getContextPath() + "/my-listings");
            return;
        }
    }
} else {

    String sql = "SELECT p.title, p.price, p.description, p.picture, "
               + "p.location_details_specific, p.meetup_id "
               + "FROM Posts p WHERE p.post_ID = ? AND p.email = ?";

    try (Connection con = Database.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, postId);
        ps.setString(2, email);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                request.setAttribute("titleValue", rs.getString("title"));
                request.setAttribute("priceValue", rs.getBigDecimal("price").toPlainString());
                request.setAttribute("descriptionValue", rs.getString("description"));
                request.setAttribute("pictureValue", rs.getString("picture"));
                request.setAttribute("locationValue", rs.getString("location_details_specific"));
                int meetupId = rs.getInt("meetup_id");
                request.setAttribute("meetupValue", meetupId > 0 ? String.valueOf(meetupId) : null);
            } else {
                response.sendRedirect(request.getContextPath() + "/my-listings");
                return;
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/my-listings");
        return;
    }

    loadMeetupLocations(request);
}
%>
<%
  request.setAttribute("pageTitle", "Edit Listing - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<%
  String formError = (String) request.getAttribute("formError");

  String titleValue = (String) request.getAttribute("titleValue");
  String priceValue = (String) request.getAttribute("priceValue");
  String descriptionValue = (String) request.getAttribute("descriptionValue");
  String pictureValue = (String) request.getAttribute("pictureValue");
  String locationValue = (String) request.getAttribute("locationValue");
  String meetupValue = (String) request.getAttribute("meetupValue");

  List<Map<String, String>> meetupLocations =
      (List<Map<String, String>>) request.getAttribute("meetupLocations");
%>

<div class="mx-auto w-full max-w-lg bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Edit Listing</h2>
  <p class="mt-1 text-sm text-slate-600">Update your listing details below.</p>

  <% if (formError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <% } %>

  <form class="mt-6 space-y-4" method="post" action="<%= request.getContextPath() %>/edit-listing?id=<%= postId %>">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="title">Item Title <span class="text-red-500">*</span></label>
      <input id="title" name="title" type="text" required
             value="<%= titleValue != null ? titleValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="price">Price ($) <span class="text-red-500">*</span></label>
      <input id="price" name="price" type="number" step="0.01" min="0.01" required
             value="<%= priceValue != null ? priceValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="description">Description <span class="text-red-500">*</span></label>
      <textarea id="description" name="description" rows="4" required
                class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"><%= descriptionValue != null ? descriptionValue : "" %></textarea>
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="meetupId">Meetup Location <span class="text-red-500">*</span></label>
      <select id="meetupId" name="meetupId" required
              class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20">
        <option value="">Select a location</option>
        <% if (meetupLocations != null) {
             for (Map<String, String> loc : meetupLocations) {
               String selected = loc.get("id").equals(meetupValue) ? "selected" : "";
        %>
          <option value="<%= loc.get("id") %>" <%= selected %>><%= loc.get("name") %></option>
        <%   }
           }
        %>
      </select>
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="locationDetails">Location Details (specific spot, room #, etc.)</label>
      <input id="locationDetails" name="locationDetails" type="text"
             value="<%= locationValue != null ? locationValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="pictureFile">Picture</label>
      <input id="pictureFile" type="file" accept="image/*"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm file:mr-3 file:rounded-md file:border-0 file:bg-blue-50 file:px-3 file:py-1 file:text-sm file:font-semibold file:text-blue-700 hover:file:bg-blue-100 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
      <input id="picture" name="picture" type="hidden"
             value="<%= pictureValue != null ? pictureValue : "" %>" />
      <p id="pictureError" class="mt-1 text-sm text-red-600 hidden"></p>
      <img id="picturePreview" src="<%= pictureValue != null ? pictureValue : "" %>"
           alt="Preview"
           class="mt-2 h-32 w-32 rounded-lg object-cover border border-slate-200 <%= pictureValue != null ? "" : "hidden" %>" />
    </div>

    <script>
      document.getElementById('pictureFile').addEventListener('change', function(e) {
        var file = e.target.files[0];
        var hidden = document.getElementById('picture');
        var preview = document.getElementById('picturePreview');
        var error = document.getElementById('pictureError');
        error.classList.add('hidden');

        if (!file) {
          hidden.value = '';
          preview.classList.add('hidden');
          return;
        }

        if (file.size > 2 * 1024 * 1024) {
          error.textContent = 'Image must be under 2 MB.';
          error.classList.remove('hidden');
          e.target.value = '';
          hidden.value = '';
          preview.classList.add('hidden');
          return;
        }

        var reader = new FileReader();
        reader.onload = function(ev) {
          hidden.value = ev.target.result;
          preview.src = ev.target.result;
          preview.classList.remove('hidden');
        };
        reader.readAsDataURL(file);
      });
    </script>

    <div class="flex gap-3">
      <button type="submit"
              class="flex-1 inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
        Save Changes
      </button>
      <a href="<%= request.getContextPath() %>/my-listings"
         class="flex-1 inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">
        Cancel
      </a>
    </div>

    <p class="text-center text-sm text-slate-600">
      <a class="font-semibold text-blue-700 hover:text-blue-800" href="<%= request.getContextPath() %>/my-listings">&larr; Back to My Listings</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
