package servlet;

import model.*;
import util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * OOP Demo: POLYMORPHISM, ENCAPSULATION, ABSTRACTION
 * - POLYMORPHISM: Dynamically calls overloaded account deposit methods based on client notes.
 * - ENCAPSULATION: Business rules (bounds, withdrawals limits, session validation) are encapsulated.
 * - ABSTRACTION: Implements operations on the Transactable account interface.
 */
@WebServlet("/CustomerServlet")
public class CustomerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionValidator.validateSession(request, response, "Customer")) {
            return;
        }

        HttpSession session = request.getSession(false);
        Customer customer = (Customer) session.getAttribute("loggedUser");
        String action = request.getParameter("action");

        List<Account> accounts = FileManager.loadAccounts();
        Account targetAccount = null;
        for (Account acc : accounts) {
            if (acc.getOwnerUserId().equalsIgnoreCase(customer.getUserId())) {
                targetAccount = acc;
                break;
            }
        }

        if (targetAccount == null) {
            response.sendRedirect("customer/dashboard.jsp?error=No+account+found+for+this+customer.");
            return;
        }

        if ("deposit".equalsIgnoreCase(action)) {
            String amountStr = request.getParameter("amount");
            String note = request.getParameter("note");

            if (amountStr == null || amountStr.isEmpty()) {
                response.sendRedirect("customer/deposit.jsp?error=Invalid+amount");
                return;
            }

            try {
                double amount = Double.parseDouble(amountStr);
                if (amount < 1) {
                    response.sendRedirect("customer/deposit.jsp?error=Minimum+deposit+is+PKR+1");
                    return;
                }

                // Polymorphic demonstration: Method Overloading
                if (note != null && !note.trim().isEmpty()) {
                    targetAccount.deposit(amount, note); // Overloaded method
                    FileManager.appendTransaction(targetAccount.getAccountId(), "DEPOSIT", amount, note.trim());
                } else {
                    targetAccount.deposit(amount); // Zero-note standard deposit
                    FileManager.appendTransaction(targetAccount.getAccountId(), "DEPOSIT", amount, "Cash Deposit");
                }

                FileManager.saveAccounts(accounts);
                response.sendRedirect("customer/dashboard.jsp?msg=PKR+" + String.format("%,.2f", amount) + "+deposited+successfully.+New+balance:+PKR+" + String.format("%,.2f", targetAccount.getBalance()));
            } catch (NumberFormatException e) {
                response.sendRedirect("customer/deposit.jsp?error=Amount+must+be+numeric");
            }
        } else if ("withdraw".equalsIgnoreCase(action)) {
            String amountStr = request.getParameter("amount");

            if (amountStr == null || amountStr.isEmpty()) {
                response.sendRedirect("customer/withdraw.jsp?error=Invalid+amount");
                return;
            }

            try {
                double amount = Double.parseDouble(amountStr);
                if (amount < 1) {
                    response.sendRedirect("customer/withdraw.jsp?error=Minimum+withdrawal+is+PKR+1");
                    return;
                }

                // Check cash reservoir in ATM
                String atmData = FileManager.getAtmInventoryString();
                double atmCash = Double.parseDouble(atmData.split(",")[0]);
                if (amount > atmCash) {
                    response.sendRedirect("customer/withdraw.jsp?error=ATM+has+insufficient+cash+reserve.+Maximum+allowed:+PKR+" + String.format("%,.2f", atmCash));
                    return;
                }

                boolean success = targetAccount.withdraw(amount);
                if (success) {
                    FileManager.saveAccounts(accounts);
                    FileManager.appendTransaction(targetAccount.getAccountId(), "WITHDRAWAL", amount, "Cash Withdrawal");
                    response.sendRedirect("customer/dashboard.jsp?msg=PKR+" + String.format("%,.2f", amount) + "+withdrawn.+Remaining+balance:+PKR+" + String.format("%,.2f", targetAccount.getBalance()));
                } else {
                    response.sendRedirect("customer/withdraw.jsp?error=Insufficient+funds.+Available+balance:+PKR+" + String.format("%,.2f", targetAccount.getBalance()));
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("customer/withdraw.jsp?error=Amount+must+be+numeric");
            }
        } else if ("changepin".equalsIgnoreCase(action)) {
            String currentPin = request.getParameter("currentPin");
            String newPin = request.getParameter("newPin");
            String confirmNewPin = request.getParameter("confirmNewPin");

            if (currentPin == null || newPin == null || confirmNewPin == null ||
                currentPin.isEmpty() || newPin.isEmpty() || confirmNewPin.isEmpty()) {
                response.sendRedirect("customer/changepin.jsp?error=All+fields+are+required");
                return;
            }

            if (!newPin.equals(confirmNewPin)) {
                response.sendRedirect("customer/changepin.jsp?error=New+PINs+do+not+match");
                return;
            }

            if (!newPin.matches("\\d{4,6}")) {
                response.sendRedirect("customer/changepin.jsp?error=New+PIN+must+be+4+to+6+digits");
                return;
            }

            List<User> users = FileManager.loadUsers();
            Customer foundCust = null;
            for (User u : users) {
                if (u.getUserId().equalsIgnoreCase(customer.getUserId())) {
                    foundCust = (Customer) u;
                    break;
                }
            }

            if (foundCust != null) {
                String hashedCurrent = PinHasher.hashPin(currentPin);
                if (foundCust.verifyPin(hashedCurrent)) {
                    String hashedNew = PinHasher.hashPin(newPin);
                    foundCust.updatePin(hashedNew);
                    FileManager.saveUsers(users);
                    
                    // Keep session state in sync
                    session.setAttribute("loggedUser", foundCust);
                    FileManager.appendTransaction(targetAccount.getAccountId(), "PIN_CHANGE", 0, "PIN successfully updated");
                    response.sendRedirect("customer/dashboard.jsp?msg=PIN+changed+successfully.");
                } else {
                    response.sendRedirect("customer/changepin.jsp?error=Current+PIN+is+incorrect");
                }
            } else {
                response.sendRedirect("customer/changepin.jsp?error=User+session+invalid");
            }
        } else {
            response.sendRedirect("customer/dashboard.jsp");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!SessionValidator.validateSession(request, response, "Customer")) {
            return;
        }

        String action = request.getParameter("action");
        if ("download".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            Customer customer = (Customer) session.getAttribute("loggedUser");

            List<Account> accounts = FileManager.loadAccounts();
            Account targetAccount = null;
            for (Account acc : accounts) {
                if (acc.getOwnerUserId().equalsIgnoreCase(customer.getUserId())) {
                    targetAccount = acc;
                    break;
                }
            }

            if (targetAccount == null) {
                response.sendError(404, "No Account Details Found.");
                return;
            }

            response.setContentType("text/plain");
            response.setHeader("Content-Disposition", "attachment;filename=transaction_history_" + targetAccount.getAccountId() + ".txt");

            try (PrintWriter out = response.getWriter()) {
                out.println("=========================================================");
                out.println("              JAVABANK TRANSACTION HISTORY               ");
                out.println("=========================================================");
                out.println("Account ID   : " + targetAccount.getAccountId());
                out.println("Customer     : " + customer.getName());
                out.println("Current Bal. : PKR " + String.format("%,.2f", targetAccount.getBalance()));
                out.println("Generated At : " + java.time.LocalDateTime.now());
                out.println("=========================================================");
                out.println(String.format("%-20s | %-12s | %-11s | %-25s", "Timestamp", "Type", "Amount", "Notes"));
                out.println("---------------------------------------------------------");

                List<Transaction> txs = FileManager.loadTransactions();
                for (Transaction t : txs) {
                    if (t.getAccountId().equalsIgnoreCase(targetAccount.getAccountId())) {
                        out.println(String.format("%-20s | %-12s | PKR %-7.2f | %-25s",
                                t.getTimestamp(), t.getType(), t.getAmount(), t.getNotes()));
                    }
                }
                out.println("=========================================================");
            }
        } else {
            response.sendRedirect("customer/dashboard.jsp");
        }
    }
}
