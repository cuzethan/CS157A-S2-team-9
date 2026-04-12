import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String username = trimToNull(request.getParameter("username"));
        String password = request.getParameter("password");

        if (username == null || password == null || password.isEmpty()) {
            setInvalidLogin(request, response, username);
            return;
        }

        String passwordHash = hashPassword(password);
        String sql = "SELECT email FROM Users WHERE username = ? AND password = ?";
        String email = null;

        //check for user & if password is correct
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    setInvalidLogin(request, response, username);
                    return;
                }
                email = rs.getString("email");
                session.setAttribute("emailValue", email);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            setInvalidLogin(request, response, username);
            return;
        }

        session.setAttribute("usernameValue", username);

        String adminSql = "SELECT email FROM Administrators WHERE email = ?";

        //check for admin and redirect based on that
        try (Connection con = Database.getConnection(); 
            PreparedStatement ps = con.prepareStatement(adminSql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    session.setAttribute("isAdmin", true);
                    response.sendRedirect(request.getContextPath() + "/admin");
                } else {
                    session.setAttribute("isAdmin", false);
                    response.sendRedirect(request.getContextPath() + "/listings");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            setInvalidLogin(request, response, username);
            return;
        }
    }

    private static void setInvalidLogin(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        request.setAttribute("formError", "Invalid username or password.");
        request.setAttribute("usernameValue", username != null ? username : "");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp");
        dispatcher.forward(request, response);
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

    private static String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}

