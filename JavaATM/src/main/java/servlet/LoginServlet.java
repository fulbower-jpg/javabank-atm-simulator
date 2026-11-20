package servlet;

import model.*;
import util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * OOP Demo: POLYMORPHISM, ENCAPSULATION
 * - POLYMORPHISM: User login instances checked dynamically and routed polymorphically based on subclasses.
 * - ENCAPSULATION: Hides security pin matching and attempts verification from outer layers.
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final int MAX_ATTEMPTS = 3;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String pin = request.getParameter("pin");

        if (userId == null || userId.trim().isEmpty() || pin == null || pin.trim().isEmpty()) {
            response.sendRedirect("index.jsp?error=UserID+and+PIN+cannot+be+empty");
            return;
        }

        List<User> users = FileManager.loadUsers();
        User matchedUser = null;
        for (User u : users) {
            if (u.getUserId().equalsIgnoreCase(userId.trim())) {
                matchedUser = u;
                break;
            }
        }

        if (matchedUser == null) {
            response.sendRedirect("index.jsp?error=User+not+found");
            return;
        }

        HttpSession session = request.getSession(true);

        if (matchedUser instanceof Customer) {
            Customer customer = (Customer) matchedUser;
            if (customer.isLocked()) {
                response.sendRedirect("index.jsp?error=Your+card+is+locked.+Please+visit+a+bank+clerk.");
                return;
            }

            Integer attempts = (Integer) session.getAttribute("failedAttempts_" + userId);
            if (attempts == null) attempts = 0;

            String hashed = PinHasher.hashPin(pin);
            if (customer.verifyPin(hashed)) {
                session.removeAttribute("failedAttempts_" + userId);
                session.setAttribute("loggedUser", customer);
                session.setMaxInactiveInterval(15 * 60); // 15 mins
                response.sendRedirect("customer/dashboard.jsp");
            } else {
                attempts++;
                session.setAttribute("failedAttempts_" + userId, attempts);
                int remaining = MAX_ATTEMPTS - attempts;
                
                if (attempts >= MAX_ATTEMPTS) {
                    customer.setLocked(true);
                    FileManager.saveUsers(users);
                    // Append transaction log of lockout
                    FileManager.appendTransaction("SYSTEM", "LOCKOUT", 0, "Account " + customer.getUserId() + " locked after 3 wrong PIN attempts");
                    response.sendRedirect("index.jsp?error=Your+card+is+locked.+Please+visit+a+bank+clerk.");
                } else {
                    response.sendRedirect("index.jsp?error=Invalid+PIN.+" + remaining + "+attempts+remaining");
                }
            }
        } else {
            String hashed = PinHasher.hashPin(pin);
            if (matchedUser.verifyPin(hashed)) {
                session.setAttribute("loggedUser", matchedUser);
                session.setMaxInactiveInterval(15 * 60); // 15 mins
                if (matchedUser instanceof Clerk) {
                    response.sendRedirect("staff/clerk.jsp");
                } else if (matchedUser instanceof Technician) {
                    response.sendRedirect("staff/technician.jsp");
                } else if (matchedUser instanceof Manager) {
                    response.sendRedirect("staff/manager.jsp");
                }
            } else {
                response.sendRedirect("index.jsp?error=Invalid+staff+credentials");
            }
        }
    }
}
