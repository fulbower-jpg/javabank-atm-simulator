package servlet;

import model.*;
import util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * OOP Demo: POLYMORPHISM, ABSTRACTION, ENCAPSULATION
 * - POLYMORPHISM: Accesses performance actions dynamically through inheritance.
 * - ABSTRACTION: Complies with behavior declared inside StaffAction.
 * - ENCAPSULATION: Restricts physical refill accesses within private local limits.
 */
@WebServlet("/TechnicianServlet")
public class TechnicianServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionValidator.validateSession(request, response, "Technician")) {
            return;
        }

        HttpSession session = request.getSession(false);
        Technician tech = (Technician) session.getAttribute("loggedUser");
        String action = request.getParameter("action");

        if ("refill".equalsIgnoreCase(action)) {
            String amountStr = request.getParameter("amount");
            if (amountStr == null || amountStr.trim().isEmpty()) {
                response.sendRedirect("staff/technician.jsp?error=Refill+amount+is+required");
                return;
            }

            try {
                double amount = Double.parseDouble(amountStr);
                if (amount < 1000) {
                    response.sendRedirect("staff/technician.jsp?error=Minimum+refill+amount+is+PKR+1000");
                    return;
                }

                String data = FileManager.getAtmInventoryString();
                String[] parts = data.split(",");
                double curCash = Double.parseDouble(parts[0]);
                int txCount = Integer.parseInt(parts[2].trim());

                double newCash = curCash + amount;
                String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

                FileManager.saveAtmInventory(newCash, timestamp, txCount);
                FileManager.appendTransaction("ATM_RESERVOIR", "REFILL", amount, "Refill by Tech " + tech.getName());

                String techLog = tech.performAction(String.valueOf(amount), "REFILL");
                session.setAttribute("techLogs", techLog);

                response.sendRedirect("staff/technician.jsp?msg=ATM+refilled+successfully.+New+cash+level:+PKR+" + String.format("%,.2f", newCash));
            } catch (NumberFormatException e) {
                response.sendRedirect("staff/technician.jsp?error=Amount+must+be+numeric");
            }
        } else {
            response.sendRedirect("staff/technician.jsp");
        }
    }
}
