<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List, java.util.Date, java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Customer)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Please+login.");
        return;
    }

    Customer customer = (Customer) user;
    
    // Load up latest transaction data from flat files
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
    <title>JavaBank - Customer Dashboard</title>
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

    <div class="content-area" style="max-width: 1000px; margin: 0 auto;">
        <%
            String error = request.getParameter("error");
            String msg = request.getParameter("msg");
            if (error != null) {
        %>
            <div class="alert alert-error" id="errorFlash"><%= error %></div>
        <%
            }
            if (msg != null) {
        %>
            <div class="alert alert-success" id="successFlash"><%= msg %></div>
        <%
            }
        %>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <h2>Customer Account Dashboard</h2>
            <span style="color: var(--text-light); font-size: 0.9rem; font-weight: 500;">
                📅 <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()) %> (PKT)
            </span>
        </div>

        <% if (targetAccount != null) { %>
            <div class="stats-grid">
                <div class="stat-card" style="border-left: 4px solid var(--accent-blue);">
                    <div class="stat-label">Account Number</div>
                    <div class="stat-value" style="font-size: 1.25rem;"><%= targetAccount.getAccountId() %></div>
                </div>
                <div class="stat-card" style="border-left: 4px solid #10b981;">
                    <div class="stat-label">Account Type</div>
                    <div class="stat-value" style="font-size: 1.25rem;"><%= targetAccount.getAccountType() %></div>
                </div>
                <div class="stat-card" style="border-left: 4px solid #f59e0b;">
                    <div class="stat-label">Available Balance</div>
                    <div class="stat-value">PKR <%= String.format("%,.2f", targetAccount.getBalance()) %></div>
                </div>
            </div>

            <!-- ATM Option Triggers -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
                <button id="btnCheckBal" class="btn" onclick="toggleSection('balance_section')" style="background-color: #475569;">🔍 Check Balance</button>
                <a href="deposit.jsp" class="btn">💵 Deposit Cash</a>
                <a href="withdraw.jsp" class="btn" style="background-color: #0284c7;">💸 Withdraw Cash</a>
                <a href="history.jsp" class="btn" style="background-color: #8b5cf6;">📋 Trans. History</a>
                <a href="changepin.jsp" class="btn" style="background-color: #10b981;">🔑 Change PIN</a>
            </div>

            <!-- check balance sheet overlay -->
            <div id="balance_section" class="card" style="display: none; animation: fadeIn 0.3s ease-out; border: 2px solid var(--accent-blue);">
                <h3 class="card-title">Check Balance View</h3>
                <div style="text-align: center; padding: 1.5rem 0;">
                    <p style="font-size: 1rem; color: var(--text-light); margin-bottom: 0.5rem;">Current Ledger Balance</p>
                    <p style="font-size: 2.5rem; font-weight: 700; color: var(--navy-header); font-family: var(--font-mono);">
                        PKR <%= String.format("%,.2f", targetAccount.getBalance()) %>
                    </p>
                    <p style="font-size: 0.75rem; color: var(--text-light); margin-top: 1rem;">
                        Balance Last Synchronized: <span class="mono"><%= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()) %></span>
                    </p>
                </div>
                <div style="text-align: right;">
                    <button class="btn btn-secondary" onclick="toggleSection('balance_section')">Close Frame</button>
                </div>
            </div>

            <!-- short table activity -->
            <div class="card">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                    <h3 class="card-title" style="margin-bottom:0;">Recent Activity Summary</h3>
                    <a href="history.jsp" class="btn btn-secondary" style="font-size:0.8rem; padding: 0.4rem 0.8rem;">View Full Ledger &rarr;</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>DateTime</th>
                            <th>TX ID</th>
                            <th>Type</th>
                            <th>Amount</th>
                            <th>Reference Detail</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Transaction> txs = FileManager.loadTransactions();
                            int count = 0;
                            for (int i = txs.size() - 1; i >= 0; i--) {
                                Transaction t = txs.get(i);
                                if (t.getAccountId().equalsIgnoreCase(targetAccount.getAccountId())) {
                                    count++;
                        %>
                                <tr>
                                    <td class="mono"><%= t.getTimestamp() %></td>
                                    <td class="mono" style="font-weight: 500;"><%= t.getTxnId() %></td>
                                    <td>
                                        <span class="mono" style="font-weight:600; color:<%= t.getType().equals("DEPOSIT") ? "var(--success-green)" : "var(--error-red)" %>;">
                                            <%= t.getType() %>
                                        </span>
                                    </td>
                                    <td class="mono">PKR <%= String.format("%,.2f", t.getAmount()) %></td>
                                    <td><%= t.getNotes() %></td>
                                </tr>
                        <%
                                    if (count >= 5) break; 
                                }
                            }
                            if (count == 0) {
                        %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: var(--text-light);">No recent transactions logged in this ledger.</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        <% } else { %>
            <div class="alert alert-error">No banking account linked with this User ID. Please seek clerical assistance.</div>
        <% } %>
    </div>

    <script>
        function toggleSection(id) {
            var el = document.getElementById(id);
            if (el.style.display === "none" || el.style.display === "") {
                el.style.display = "block";
            } else {
                el.style.display = "none";
            }
        }
        
        setTimeout(function() {
            var errorF = document.getElementById('errorFlash');
            if(errorF) errorF.style.display = 'none';
            var successF = document.getElementById('successFlash');
            if(successF) successF.style.display = 'none';
        }, 3500);
    </script>
</body>
</html>
