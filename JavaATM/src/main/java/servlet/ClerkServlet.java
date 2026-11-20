package servlet;

import model.*;
import util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * OOP Demo: POLYMORPHISM, ABSTRACTION
 * - POLYMORPHISM: Leverages dynamic dispatch on Clerk subclass and performAction() signatures.
 * - ABSTRACTION: Operates on abstract BankStaff models and the StaffAction contract interface.
 */
@WebServlet("/ClerkServlet")
public class ClerkServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionValidator.validateSession(request, response, "Clerk")) {
            return;
        }

        HttpSession session = request.getSession(false);
        Clerk clerk = (Clerk) session.getAttribute("loggedUser");
        String action = request.getParameter("action");
        String customerId = request.getParameter("customerId");

        if (customerId == null || customerId.trim().isEmpty()) {
            response.sendRedirect("staff/clerk.jsp?error=Customer+ID+is+required");
            return;
        }

        customerId = customerId.trim();
        List<User> users = FileManager.loadUsers();
        Customer targetCustomer = null;
        for (User u : users) {
            if (u.getUserId().equalsIgnoreCase(customerId) && u instanceof Customer) {
                targetCustomer = (Customer) u;
                break;
            }
        }

        if (targetCustomer == null) {
            response.sendRedirect("staff/clerk.jsp?error=Customer+not+found");
            return;
        }

        if ("unlock".equalsIgnoreCase(action)) {
            targetCustomer.setLocked(false);
            FileManager.saveUsers(users);

            // Log action polymorphicly
            String resultMsg = clerk.performAction(customerId, "UNLOCK");
            FileManager.appendTransaction("CLERK_ACTION", "UNLOCK", 0, "Clerk " + clerk.getName() + " unlocked " + customerId);

            @SuppressWarnings("unchecked")
            List<String> auditLogs = (List<String>) session.getAttribute("clerkLogs");
            if (auditLogs == null) {
                auditLogs = new java.util.ArrayList<>();
            }
            auditLogs.add(resultMsg);
            session.setAttribute("clerkLogs", auditLogs);

            response.sendRedirect("staff/clerk.jsp?msg=Account+" + customerId + "+unlocked+successfully.");
        } else if ("reset_attempts".equalsIgnoreCase(action)) {
            session.removeAttribute("failedAttempts_" + customerId);

            String resultMsg = clerk.performAction(customerId, "RESET_ATTEMPTS");
            FileManager.appendTransaction("CLERK_ACTION", "RESET_ATTEMPTS", 0, "Clerk " + clerk.getName() + " reset attempts for " + customerId);

            @SuppressWarnings("unchecked")
            List<String> auditLogs = (List<String>) session.getAttribute("clerkLogs");
            if (auditLogs == null) {
                auditLogs = new java.util.ArrayList<>();
            }
            auditLogs.add(resultMsg);
            session.setAttribute("clerkLogs", auditLogs);

            response.sendRedirect("staff/clerk.jsp?msg=Attempts+cleared+for+user+" + customerId);
        } else {
            response.sendRedirect("staff/clerk.jsp");
        }
    }
}
