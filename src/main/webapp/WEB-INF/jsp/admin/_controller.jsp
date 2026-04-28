<%!
private static String trimToNull(String value) {
  if (value == null) return null;
  String trimmed = value.trim();
  return trimmed.isEmpty() ? null : trimmed;
}

private static String validateAdminListing(String title, String priceStr, String description, String meetupId, String status) {
  if (title == null || title.isEmpty()) return "Item title is required.";
  if (title.length() > 45) return "Item title must be 45 characters or fewer.";
  if (priceStr == null || priceStr.isEmpty()) return "Price is required.";
  try {
    BigDecimal price = new BigDecimal(priceStr);
    if (price.compareTo(BigDecimal.ZERO) <= 0) return "Price must be greater than $0.00.";
  } catch (NumberFormatException e) {
    return "Price must be a valid number.";
  }
  if (description == null || description.isEmpty()) return "Description is required.";
  if (meetupId == null || meetupId.isEmpty()) return "Meetup location is required.";
  if (!"Available".equals(status) && !"Sold".equals(status)) return "Status must be Available or Sold.";
  return null;
}
%>
<%
  // Shared controller fragment for admin pages:
  // validates admin access, executes form actions, and prepares view data.
  javax.servlet.http.HttpSession adminSession = request.getSession();
  Boolean sessionIsAdmin = (Boolean) adminSession.getAttribute("isAdmin");
  if (!Boolean.TRUE.equals(sessionIsAdmin)) {
    response.sendError(javax.servlet.http.HttpServletResponse.SC_FORBIDDEN, "Admin access required.");
    return;
  }

  String currentAdminEmail = (String) adminSession.getAttribute("emailValue");
  String formError = null;
  String formSuccess = null;
  String postFormError = null;
  String postFormSuccess = null;

  String postStatusParam = trimToNull(request.getParameter("postStatus"));
  String postMessageParam = trimToNull(request.getParameter("postMessage"));
  if (postStatusParam != null && postMessageParam != null) {
    if ("success".equalsIgnoreCase(postStatusParam)) {
      postFormSuccess = postMessageParam;
    } else {
      postFormError = postMessageParam;
    }
  }

  String sort = request.getParameter("sort");
  String dir = request.getParameter("dir");
  if (sort != null) sort = sort.toLowerCase();
  if (dir != null) dir = dir.toLowerCase();

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

  String selectedUser = trimToNull(request.getParameter("selectedUser"));

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    // Handle mutating admin actions before rendering the page (PRG for post actions).
    String action = request.getParameter("action");
    String targetEmail = trimToNull(request.getParameter("targetEmail"));

    if ("deleteUser".equals(action)) {
      if (targetEmail == null) {
        formError = "Missing target user account.";
      } else if (currentAdminEmail != null && currentAdminEmail.equalsIgnoreCase(targetEmail)) {
        formError = "You cannot terminate your own account.";
      } else {
        Connection con = null;
        try {
          con = Database.getConnection();
          con.setAutoCommit(false);

          boolean targetIsAdmin = false;
          // Guardrail: check whether the target account is an admin before deletion.
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
            // Remove dependent records first, then remove the user in one transaction.
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
    } else if ("adminDeletePost".equals(action) || "adminUpdatePost".equals(action)) {
      if (targetEmail == null) {
        postFormError = "Missing target user for post action.";
      } else {
        String encodedTarget = URLEncoder.encode(targetEmail, StandardCharsets.UTF_8);
        String baseRedirect = request.getContextPath() + "/admin?selectedUser=" + encodedTarget;
        try {
          if ("adminDeletePost".equals(action)) {
            String postIdStr = trimToNull(request.getParameter("postId"));
            if (postIdStr == null) {
              response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
                  + URLEncoder.encode("Missing post id.", StandardCharsets.UTF_8));
              return;
            }

            int postId = Integer.parseInt(postIdStr);
            try (Connection con = Database.getConnection()) {
              // Remove favorites linked to the post to avoid FK conflicts.
              try (PreparedStatement deleteFav = con.prepareStatement("DELETE FROM Favorites WHERE post_ID = ?")) {
                deleteFav.setInt(1, postId);
                deleteFav.executeUpdate();
              }
              // Delete only if the post belongs to the selected user.
              try (PreparedStatement deletePost = con.prepareStatement("DELETE FROM Posts WHERE post_ID = ? AND email = ?")) {
                deletePost.setInt(1, postId);
                deletePost.setString(2, targetEmail);
                int rows = deletePost.executeUpdate();
                if (rows <= 0) {
                  response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
                      + URLEncoder.encode("Post was not found or does not belong to the selected user.", StandardCharsets.UTF_8));
                  return;
                }
              }
            }

            response.sendRedirect(baseRedirect + "&postStatus=success&postMessage="
                + URLEncoder.encode("Post deleted successfully.", StandardCharsets.UTF_8));
            return;
          }

          String postIdStr = trimToNull(request.getParameter("postId"));
          String title = trimToNull(request.getParameter("title"));
          String priceStr = trimToNull(request.getParameter("price"));
          String description = trimToNull(request.getParameter("description"));
          String picture = trimToNull(request.getParameter("picture"));
          String locationDetails = trimToNull(request.getParameter("locationDetails"));
          String meetupIdStr = trimToNull(request.getParameter("meetupId"));
          String status = trimToNull(request.getParameter("status"));

          if (postIdStr == null) {
            response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
                + URLEncoder.encode("Missing post id.", StandardCharsets.UTF_8));
            return;
          }

          String validationError = validateAdminListing(title, priceStr, description, meetupIdStr, status);
          if (validationError != null) {
            response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
                + URLEncoder.encode(validationError, StandardCharsets.UTF_8));
            return;
          }

          int postId = Integer.parseInt(postIdStr);
          BigDecimal price = new BigDecimal(priceStr);
          int meetupId = Integer.parseInt(meetupIdStr);
          // Update all editable post fields, scoped to the selected owner's email.
          String updateSql = "UPDATE Posts "
                           + "SET title = ?, price = ?, description = ?, picture = ?, "
                           + "location_details_specific = ?, meetup_id = ?, item_status = ? "
                           + "WHERE post_ID = ? AND email = ?";
          try (Connection con = Database.getConnection();
               PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setString(1, title);
            ps.setBigDecimal(2, price);
            ps.setString(3, description);
            ps.setString(4, picture);
            ps.setString(5, locationDetails);
            ps.setInt(6, meetupId);
            ps.setString(7, status);
            ps.setInt(8, postId);
            ps.setString(9, targetEmail);
            int updated = ps.executeUpdate();
            if (updated <= 0) {
              response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
                  + URLEncoder.encode("Post was not found or does not belong to the selected user.", StandardCharsets.UTF_8));
              return;
            }
          }

          response.sendRedirect(baseRedirect + "&postStatus=success&postMessage="
              + URLEncoder.encode("Post updated successfully.", StandardCharsets.UTF_8));
          return;
        } catch (NumberFormatException e) {
          response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
              + URLEncoder.encode("Invalid numeric value provided.", StandardCharsets.UTF_8));
          return;
        } catch (SQLException e) {
          e.printStackTrace();
          response.sendRedirect(baseRedirect + "&postStatus=error&postMessage="
              + URLEncoder.encode("Database error while managing post.", StandardCharsets.UTF_8));
          return;
        }
      }
    }
  }

  // Data for the "Manage User Accounts" table.
  List<Map<String, Object>> users = new ArrayList<>();
  // Load the admin table of all users plus derived flags for posts/admin role.
  String usersSql =
      "SELECT u.email, u.username, "
    + "EXISTS (SELECT 1 FROM Posts p WHERE p.email = u.email) AS hasPosts, "
    + "EXISTS (SELECT 1 FROM Administrators a WHERE a.email = u.email) AS isAdmin "
    + "FROM Users u";
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

  // Data for the selected user's post workspace.
  String selectedUserName = null;
  List<Map<String, String>> selectedUserPosts = new ArrayList<>();
  List<Map<String, String>> meetupLocations = new ArrayList<>();
  if (selectedUser != null) {
    try (Connection con = Database.getConnection()) {
      // Resolve selected user's display name; clear selection if email no longer exists.
      try (PreparedStatement userPs = con.prepareStatement("SELECT username FROM Users WHERE email = ?")) {
        userPs.setString(1, selectedUser);
        try (ResultSet rs = userPs.executeQuery()) {
          if (rs.next()) {
            selectedUserName = rs.getString("username");
          } else {
            selectedUser = null;
            postFormError = "Selected user account was not found.";
          }
        }
      }

      if (selectedUser != null) {
        // Load posts for the selected user with meetup location names for display.
        String postsSql =
            "SELECT p.post_ID, p.title, p.price, p.description, p.picture, p.item_status, "
          + "p.location_details_specific, p.meetup_id, m.meetup_location "
          + "FROM Posts p JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
          + "WHERE p.email = ? ORDER BY p.post_ID DESC";
        try (PreparedStatement postsPs = con.prepareStatement(postsSql)) {
          postsPs.setString(1, selectedUser);
          try (ResultSet rs = postsPs.executeQuery()) {
            while (rs.next()) {
              Map<String, String> post = new HashMap<>();
              post.put("id", String.valueOf(rs.getInt("post_ID")));
              post.put("title", rs.getString("title"));
              post.put("price", rs.getBigDecimal("price").toPlainString());
              post.put("description", rs.getString("description"));
              post.put("picture", rs.getString("picture"));
              post.put("status", rs.getString("item_status"));
              post.put("locationDetails", rs.getString("location_details_specific"));
              post.put("meetupId", String.valueOf(rs.getInt("meetup_id")));
              post.put("meetupLocation", rs.getString("meetup_location"));
              selectedUserPosts.add(post);
            }
          }
        }

        // Load meetup options used by the inline admin post edit forms.
        try (PreparedStatement locationPs = con.prepareStatement(
            "SELECT meetupID, meetup_location FROM MeetupLocation ORDER BY meetup_location");
             ResultSet rs = locationPs.executeQuery()) {
          while (rs.next()) {
            Map<String, String> loc = new HashMap<>();
            loc.put("id", String.valueOf(rs.getInt("meetupID")));
            loc.put("name", rs.getString("meetup_location"));
            meetupLocations.add(loc);
          }
        }
      }
    } catch (SQLException e) {
      postFormError = "Unable to load selected user's posts.";
      e.printStackTrace();
    }
  }

  String sortParams = "";
  if (sort != null && dir != null) {
    sortParams = "&sort=" + URLEncoder.encode(sort, StandardCharsets.UTF_8)
               + "&dir=" + URLEncoder.encode(dir, StandardCharsets.UTF_8);
  }
%>
