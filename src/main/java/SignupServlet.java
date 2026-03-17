import java.io.IOException;
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

        // TODO: Insert user into DB, then redirect to login.
        response.sendRedirect(request.getContextPath() + "/login");
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

