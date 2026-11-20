<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Customer)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Please+login.");
        return;
    }
    Customer customer = (Customer) user;
    
    // Load account detail
    List<Account> accounts = FileManager.loadAccounts();
    Account targetAccount = null;
    for (Account acc : accounts) {
        if (acc.getOwnerUserId().equalsIgnoreCase(customer.getUserId())) {
            targetAccount = acc;
            break;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank - Transaction History</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <header>
        <div class="logo-section">
            <h1>🏦 JavaBank ATM <span>Customer Portal</span></h1>
        </div>
        <div class="user-controls">
            <div class="user-info">
                <p>Welcome, <strong><%= customer.getName() %></strong></p>
                <span>Card Number: <%= customer.getUserId() %></span>
            </div>
            <a href="../LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </header>

    <div class="content-area" style="max-width: 900px; margin: 0 auto;">
        <a href="dashboard.jsp" style="text-decoration: none; color: var(--accent-blue); font-size: 0.9rem; font-weight: 500; display: inline-block; margin-bottom: 1.5rem;">&larr; Back to Dashboard</a>

        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <h3 class="card-title" style="margin-bottom: 0;">📋 Transaction History Ledger</h3>
                
                <% if (targetAccount != null) { %>
                    <a href="../CustomerServlet?action=download" class="btn" style="background-color: #8b5cf6; padding: 0.5rem 1rem; font-size: 0.85rem;">📥 Download History (.txt)</a>
                <% } %>
            </div>

            <% if (targetAccount != null) { %>
                <div style="background-color: #f1f5f9; padding: 0.75rem 1rem; border-radius: 6px; font-size: 0.85rem; color: var(--text-dark); margin-bottom: 1.5rem; display: flex; justify-content: space-between; align-items: center;">
                    <span>Linked Account: <strong class="mono"><%= targetAccount.getAccountId() %></strong> (<%= targetAccount.getAccountType() %>)</span>
                    <span>Current balance: <strong class="mono">PKR <%= String.format("%,.2f", targetAccount.getBalance()) %></strong></span>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Transaction Timestamp</th>
                            <th>TX ID</th>
                            <th>Type</th>
                            <th>Amount (PKR)</th>
                            <th>Notes / Memo Reference</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Transaction> txs = FileManager.loadTransactions();
                            int totalCount = 0;
                            // Display last 20 transactions by default matching academic rules
                            for (int i = txs.size() - 1; i >= 0; i--) {
                                Transaction t = txs.get(i);
                                if (t.getAccountId().equalsIgnoreCase(targetAccount.getAccountId())) {
                                    totalCount++;
                        %>
                                    <tr>
                                        <td class="mono"><%= t.getTimestamp() %></td>
                                        <td class="mono" style="font-weight: 500;"><%= t.getTxnId() %></td>
                                        <td>
                                            <span class="mono" style="font-weight:600; color:<%= t.getType().equals("DEPOSIT") ? "var(--success-green)" : "var(--error-red)" %>;">
                                                <%= t.getType() %>
                                            </span>
                                        </td>
                                        <td class="mono" style="font-weight: 600;">
                                            PKR <%= String.format("%,.2f", t.getAmount()) %>
                                        </td>
                                        <td style="color:#475569;"><%= t.getNotes() %></td>
                                    </tr>
                        <%
                                    if (totalCount >= 20) break;
                                }
                            }
                            if (totalCount == 0) {
                        %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: var(--text-light); padding: 2rem 0;">No logs are recorded on your transaction ledger.</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                <p style="font-size:0.75rem; color:var(--text-light); text-align:center; margin-top:1.5rem;">
                    Showing last <%= totalCount %> transaction entries from <span class="mono">transactions.csv</span>.
                </p>
            <% } else { %>
                <div class="alert alert-error">No active account linked found in memory.</div>
            <% } %>
        </div>
    </div>
</body>
</html>
