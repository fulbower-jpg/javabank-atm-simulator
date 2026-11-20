package util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

/**
 * OOP Demo: ENCAPSULATION
 * Encapsulates the details of validating security session bounds and role clearances.
 */
public class SessionValidator {
    
    public static boolean validateSession(HttpServletRequest request, HttpServletResponse response, String requiredRole) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=No+active+session.+Please+login.");
            return false;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=No+active+session.+Please+login.");
            return false;
        }

        if (requiredRole != null && !user.getRole().equalsIgnoreCase(requiredRole)) {
            response.sendRedirect(request.getContextPath() + "/error/unauthorized.jsp?error=Unauthorized+access+attempt.");
            return false;
        }
        return true;
    }
}
