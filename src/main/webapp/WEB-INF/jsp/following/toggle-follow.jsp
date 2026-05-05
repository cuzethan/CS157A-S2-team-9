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

String targetEmail = request.getParameter("targetEmail");
if (targetEmail == null || targetEmail.trim().isEmpty()) {
    response.setStatus(400);
    out.print("{\"error\":\"Missing targetEmail\"}");
    return;
}
targetEmail = targetEmail.trim();
String myEmail = String.valueOf(emailAttr).trim();

if (myEmail.equals(targetEmail)) {
    response.setStatus(400);
    out.print("{\"error\":\"Cannot follow yourself\"}");
    return;
}

boolean nowFollowing = false;

try (Connection con = Database.getConnection()) {
    boolean exists = false;
    try (PreparedStatement ps = con.prepareStatement(
            "SELECT 1 FROM Following WHERE user_email1 = ? AND user_email2 = ?")) {
        ps.setString(1, myEmail);
        ps.setString(2, targetEmail);
        try (ResultSet rs = ps.executeQuery()) {
            exists = rs.next();
        }
    }

    if (exists) {
        try (PreparedStatement ps = con.prepareStatement(
                "DELETE FROM Following WHERE user_email1 = ? AND user_email2 = ?")) {
            ps.setString(1, myEmail);
            ps.setString(2, targetEmail);
            ps.executeUpdate();
        }
        nowFollowing = false;
    } else {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO Following (user_email1, user_email2) VALUES (?, ?)")) {
            ps.setString(1, myEmail);
            ps.setString(2, targetEmail);
            ps.executeUpdate();
        }
        nowFollowing = true;
    }
} catch (SQLException e) {
    e.printStackTrace();
    response.setStatus(500);
    out.print("{\"error\":\"Database error\"}");
    return;
}

out.print("{\"following\":" + nowFollowing + "}");
%>
