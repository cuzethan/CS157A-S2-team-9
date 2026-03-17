import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.regex.Pattern;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SignupServlet extends HttpServlet {
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]{3,20}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@sjsu\\.edu$");
    private static final Pattern PASSWORD_UPPER = Pattern.compile(".*[A-Z].*");
    private static final Pattern PASSWORD_LOWER = Pattern.compile(".*[a-z].*");
    private static final Pattern PASSWORD_DIGIT = Pattern.compile(".*[0-9].*");
    private static final Pattern PASSWORD_SYMBOL = Pattern.compile(".*[^A-Za-z0-9].*");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/auth/signup.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = trimToNull(request.getParameter("username"));
        String email = trimToNull(request.getParameter("email"));
        String password = request.getParameter("password");

        request.setAttribute("usernameValue", username);
        request.setAttribute("emailValue", email);

        String error = validate(username, email, password);
        if (error != null) {
            request.setAttribute("formError", error);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/auth/signup.jsp");
            dispatcher.forward(request, response);
            return;
        }

        String sqlCheck = "SELECT email FROM Users WHERE email = ? OR username = ?";
        String sqlInsert = "INSERT INTO Users (username, email, password) VALUES (?, ?, ?)";
        try {
            try (Connection con = Database.getConnection()) {

                // Check for existing user
                try (PreparedStatement check = con.prepareStatement(sqlCheck)) {
                    check.setString(1, email);
                    check.setString(2, username);
                    try (ResultSet rs = check.executeQuery()) {
                        if (rs.next()) {
                            request.setAttribute("formError", "That email or username is already in use.");
                            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/auth/signup.jsp");
                            dispatcher.forward(request, response);
                            return;
                        }
                    }
                }

                // Insert new user with hashed password
                String passwordHash = hashPassword(password);
                try (PreparedStatement insert = con.prepareStatement(sqlInsert)) {
                    insert.setString(1, username);
                    insert.setString(2, email);
                    insert.setString(3, passwordHash);
                    insert.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Also show the message on the page so we can see it
            request.setAttribute("formError", "Database error: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/auth/signup.jsp");
            dispatcher.forward(request, response);
            return;
        }

        // Success: send user to login
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private static String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Unable to hash password", e);
        }
    }

    private static String validate(String username, String email, String password) {
        if (username == null || !USERNAME_PATTERN.matcher(username).matches()) {
            return "Username must be 3–20 characters and contain only letters, numbers, or underscore (_).";
        }
        if (email == null || !EMAIL_PATTERN.matcher(email).matches()) {
            return "Email must be a valid SJSU email ending with @sjsu.edu.";
        }
        if (password == null || password.length() < 8) {
            return "Password must be at least 8 characters.";
        }
        if (!PASSWORD_UPPER.matcher(password).matches()
                || !PASSWORD_LOWER.matcher(password).matches()
                || !PASSWORD_DIGIT.matcher(password).matches()
                || !PASSWORD_SYMBOL.matcher(password).matches()) {
            return "Password must include at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 symbol.";
        }
        return null;
    }

    private static String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}

