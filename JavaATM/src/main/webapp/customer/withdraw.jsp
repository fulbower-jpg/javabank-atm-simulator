<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Customer)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Please+login.");
        return;
    }
    Customer customer = (Customer) user;
    
    // Load latest account details
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
    <title>JavaBank - Withdraw Cash</title>
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

    <div class="content-area" style="max-width: 600px; margin: 0 auto;">
        <a href="dashboard.jsp" style="text-decoration: none; color: var(--accent-blue); font-size: 0.9rem; font-weight: 500; display: inline-block; margin-bottom: 1.5rem;">&larr; Back to Dashboard</a>

        <div class="card">
            <h3 class="card-title">💸 Withdraw Cash Reserve</h3>
            
            <%
                String error = request.getParameter("error");
                if (error != null) {
            %>
                <div class="alert alert-error" id="errorFlash"><%= error %></div>
            <%
                }
            %>

            <% if (targetAccount != null) { %>
                <div style="background-color: #f8fafc; border: 1px dashed var(--card-border); padding: 1rem; border-radius: 6px; margin-bottom: 1.5rem;">
                    <p style="font-size: 0.85rem; color: var(--text-light);">Available balance in ledger:</p>
                    <p style="font-size: 1.25rem; font-weight: 600; color: var(--text-dark); font-family: var(--font-mono);">
                        PKR <%= String.format("%,.2f", targetAccount.getBalance()) %>
                    </p>
                </div>

                <form action="../CustomerServlet" method="POST" onsubmit="return confirmWithdrawal()">
                    <input type="hidden" name="action" value="withdraw">

                    <div class="form-group">
                        <label for="amount">Withdrawal Amount (PKR)</label>
                        <input type="number" id="amount" name="amount" min="1" placeholder="Enter amount to withdraw" required autocomplete="off">
                        <span style="font-size: 0.75rem; color: var(--text-light);">Amount must be less than or equal to your ledger balance.</span>
                    </div>

                    <div style="display: flex; gap: 1rem; margin-top: 1rem;">
                        <button type="submit" class="btn" style="flex: 1; background-color: #0284c7;">Confirm Withdrawal</button>
                        <a href="dashboard.jsp" class="btn btn-secondary" style="flex: 1;">Cancel</a>
                    </div>
                </form>
            <% } else { %>
                <div class="alert alert-error">No banking account linked with this User ID.</div>
            <% } %>
        </div>
    </div>
    
    <script>
        function confirmWithdrawal() {
            var amountVal = parseFloat(document.getElementById('amount').value);
            if (isNaN(amountVal) || amountVal <= 0) {
                alert('Please enter a valid numeric withdrawal amount.');
                return false;
            }
            
            // Over PKR 10,000 demands verification dialog to satisfy UX requirements
            if (amountVal > 10000) {
                return window.confirm('Security Warning: You are about to make a large cash withdrawal of PKR ' + amountVal.toLocaleString() + '. Do you wish to proceed?');
            }
            return true;
        }

        setTimeout(function() {
            var errorF = document.getElementById('errorFlash');
            if(errorF) errorF.style.display = 'none';
        }, 3000);
    </script>
</body>
</html>
