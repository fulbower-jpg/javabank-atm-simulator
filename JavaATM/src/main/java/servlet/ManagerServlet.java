package servlet;

import model.*;
import util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * OOP Demo: POLYMORPHISM, ABSTRACTION, ENCAPSULATION
 * - POLYMORPHISM: Dynamic dispatch for class performance overrides under Manager constraints.
 * - ABSTRACTION: Direct implementation of the StaffAction interface.
 * - ENCAPSULATION: Hides PIN and account configurations securely behind transactional model states.
 */
@WebServlet("/ManagerServlet")
public class ManagerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionValidator.validateSession(request, response, "Manager")) {
            return;
        }

        HttpSession session = request.getSession(false);
        Manager manager = (Manager) session.getAttribute("loggedUser");
        String action = request.getParameter("action");

        List<User> users = FileManager.loadUsers();
        List<Account> accounts = FileManager.loadAccounts();

        if ("create".equalsIgnoreCase(action)) {
            String name = request.getParameter("name");
            String userId = request.getParameter("userId");
            String pin = request.getParameter("pin");
            String balanceStr = request.getParameter("balance");
            String accountType = request.getParameter("accountType");

            if (name == null || userId == null || pin == null || balanceStr == null || accountType == null ||
                name.isEmpty() || userId.isEmpty() || pin.isEmpty() || balanceStr.isEmpty()) {
                response.sendRedirect("staff/manager.jsp?error=All+fields+are+required+for+creation");
                return;
            }

            userId = userId.trim();
            for (User u : users) {
                if (u.getUserId().equalsIgnoreCase(userId)) {
                    response.sendRedirect("staff/manager.jsp?error=User+ID+already+exists");
                    return;
                }
            }

            try {
                double balance = Double.parseDouble(balanceStr);
                if (balance < 0) {
                    response.sendRedirect("staff/manager.jsp?error=Initial+balance+cannot+be+negative");
                    return;
                }

                String hashedPin = PinHasher.hashPin(pin);
                Customer newCust = new Customer(userId, name, hashedPin, false);
                users.add(newCust);
                FileManager.saveUsers(users);

                String accountId = "ACT" + (10000 + accounts.size() + 1);
                Account newAcc = new Account(accountId, userId, accountType, balance);
                accounts.add(newAcc);
                FileManager.saveAccounts(accounts);

                FileManager.appendTransaction(accountId, "ACCOUNT_CREATION", balance, "Created by Manager " + manager.getName());

                String msg = manager.performAction(userId, "CREATE");
                session.setAttribute("managerLogs", msg);

                response.sendRedirect("staff/manager.jsp?msg=Account+created+successfully!+User+ID:+[" + userId + "],+Temp+PIN:+[" + pin + "],+Account+ID:+[" + accountId + "]");
            } catch (NumberFormatException e) {
                response.sendRedirect("staff/manager.jsp?error=Balance+must+be+numeric");
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            String targetUserId = request.getParameter("customerId");
            if (targetUserId == null || targetUserId.trim().isEmpty()) {
                response.sendRedirect("staff/manager.jsp?error=Customer+ID+is+required+to+delete");
                return;
            }

            targetUserId = targetUserId.trim();
            User deleteUser = null;
            for (User u : users) {
                if (u.getUserId().equalsIgnoreCase(targetUserId) && u instanceof Customer) {
                    deleteUser = u;
                    break;
                }
            }

            if (deleteUser == null) {
                response.sendRedirect("staff/manager.jsp?error=Customer+account+not+found");
                return;
            }

            users.remove(deleteUser);
            FileManager.saveUsers(users);

            Account associatedAccount = null;
            for (Account acc : accounts) {
                if (acc.getOwnerUserId().equalsIgnoreCase(targetUserId)) {
                    associatedAccount = acc;
                    break;
                }
            }

            if (associatedAccount != null) {
                accounts.remove(associatedAccount);
                FileManager.saveAccounts(accounts);
                FileManager.appendTransaction(associatedAccount.getAccountId(), "ACCOUNT_DELETION", 0, "Account deleted by Manager " + manager.getName());
            }

            String msg = manager.performAction(targetUserId, "DELETE");
            session.setAttribute("managerLogs", msg);

            response.sendRedirect("staff/manager.jsp?msg=Account+for+" + targetUserId + "+deleted+successfully.");
        } else if ("override".equalsIgnoreCase(action)) {
            String targetUserId = request.getParameter("customerId");
            String newPin = request.getParameter("newPin");
            String lockStatus = request.getParameter("lockStatus");

            if (targetUserId == null || targetUserId.trim().isEmpty()) {
                response.sendRedirect("staff/manager.jsp?error=Customer+ID+is+required+for+override");
                return;
            }

            targetUserId = targetUserId.trim();
            Customer customer = null;
            for (User u : users) {
                if (u.getUserId().equalsIgnoreCase(targetUserId) && u instanceof Customer) {
                    customer = (Customer) u;
                    break;
                }
            }

            if (customer == null) {
                response.sendRedirect("staff/manager.jsp?error=Customer+account+not+found");
                return;
            }

            StringBuilder changeNotes = new StringBuilder();

            if (lockStatus != null) {
                boolean targetLock = Boolean.parseBoolean(lockStatus);
                if (customer.isLocked() != targetLock) {
                    customer.setLocked(targetLock);
                    changeNotes.append("Locked=").append(targetLock).append(" ");
                }
            }

            if (newPin != null && !newPin.trim().isEmpty()) {
                if (newPin.matches("\\d{4,6}")) {
                    customer.updatePin(PinHasher.hashPin(newPin.trim()));
                    changeNotes.append("PinModified ");
                } else {
                    response.sendRedirect("staff/manager.jsp?error=PIN+must+be+4+to+6+digits");
                    return;
                }
            }

            FileManager.saveUsers(users);

            String msg = manager.performAction(targetUserId, "OVERRIDE");
            session.setAttribute("managerLogs", msg);

            String accountId = "UNKNOWN";
            for (Account acc : accounts) {
                if (acc.getOwnerUserId().equalsIgnoreCase(targetUserId)) {
                    accountId = acc.getAccountId();
                    break;
                }
            }
            FileManager.appendTransaction(accountId, "OVERRIDE", 0, "Override detail: " + changeNotes.toString());

            response.sendRedirect("staff/manager.jsp?msg=System+override+applied+successfully+on+Customer+[" + targetUserId + "]");
        } else {
            response.sendRedirect("staff/manager.jsp");
        }
    }
}
