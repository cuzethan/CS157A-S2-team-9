<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
Object emailAttr = session.getAttribute("emailValue");
boolean loggedIn = emailAttr != null && !String.valueOf(emailAttr).trim().isEmpty();

if (!loggedIn) {
    response.setStatus(401);
    out.print("{\"error\":\"Not logged in\"}");
    return;
}

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.setStatus(405);
    out.print("{\"error\":\"Method not allowed\"}");
    return;
}

String postIdParam = request.getParameter("postId");
if (postIdParam == null || postIdParam.trim().isEmpty()) {
    response.setStatus(400);
    out.print("{\"error\":\"Missing postId\"}");
    return;
}

int postId;
try {
    postId = Integer.parseInt(postIdParam.trim());
} catch (NumberFormatException e) {
    response.setStatus(400);
    out.print("{\"error\":\"Invalid postId\"}");
    return;
}

String email = String.valueOf(emailAttr).trim();
boolean nowFavorited = false;

try (Connection con = Database.getConnection()) {
    boolean exists = false;
    try (PreparedStatement ps = con.prepareStatement(
            "SELECT 1 FROM Favorites WHERE email = ? AND post_ID = ?")) {
        ps.setString(1, email);
        ps.setInt(2, postId);
        try (ResultSet rs = ps.executeQuery()) {
            exists = rs.next();
        }
    }

    if (exists) {
        try (PreparedStatement ps = con.prepareStatement(
                "DELETE FROM Favorites WHERE email = ? AND post_ID = ?")) {
            ps.setString(1, email);
            ps.setInt(2, postId);
            ps.executeUpdate();
        }
        nowFavorited = false;
    } else {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO Favorites (email, post_ID) VALUES (?, ?)")) {
            ps.setString(1, email);
            ps.setInt(2, postId);
            ps.executeUpdate();
        }
        nowFavorited = true;
    }
} catch (SQLException e) {
    e.printStackTrace();
    response.setStatus(500);
    out.print("{\"error\":\"Database error\"}");
    return;
}

out.print("{\"favorited\":" + nowFavorited + "}");
%>
