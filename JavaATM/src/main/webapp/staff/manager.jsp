<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List, java.util.ArrayList" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Manager)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Manager+clearance+level+required.");
        return;
    }
    Manager manager = (Manager) user;

    List<User> users = FileManager.loadUsers();
    List<Account> accounts = FileManager.loadAccounts();
    List<Transaction> transactions = FileManager.loadTransactions();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank - Manager Control Console</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .tabs {
            display: flex;
            border-bottom: 2px solid var(--card-border);
            margin-bottom: 2rem;
            gap: 1rem;
        }
        .tab-btn {
            background: none;
            border: none;
            padding: 0.75rem 1.25rem;
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--text-light);
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: all 0.2s;
        }
        .tab-btn.active {
            color: var(--accent-blue);
            border-bottom-color: var(--accent-blue);
        }
        .tab-content {
            display: none;
            animation: fadeIn 0.3s ease-out;
        }
        .tab-content.active {
            display: block;
        }
        .sortable-th {
            cursor: pointer;
            user-select: none;
        }
        .sortable-th:hover {
            background-color: #e2e8f0;
            color: var(--text-dark);
        }
    </style>
</head>
<body>
    <header>
        <div class="logo-section">
            <h1>🏦 JavaBank ATM <span>Staff Portal (Manager)</span></h1>
        </div>
        <div class="user-controls">
            <div class="user-info">
                <p>Welcome, Manager <strong><%= manager.getName() %></strong></p>
                <span>Authorization LEVEL 10</span>
            </div>
            <a href="../LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </header>

    <div class="content-area" style="max-width: 1200px; margin: 0 auto;">
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

        <div style="margin-bottom: 2rem;">
            <h2>Executive System Override & Control Console</h2>
            <p style="color: var(--text-light); font-size: 0.85rem;">Provide complete system audits, delete/create client portfolios, reset credentials and override hardware vaults.</p>
        </div>

        <!-- tab elements -->
        <div class="tabs">
            <button class="tab-btn active" onclick="switchTab('accountsList')">📂 View All Accounts</button>
            <button class="tab-btn" onclick="switchTab('createAccount')">➕ Create New Account</button>
            <button class="tab-btn" onclick="switchTab('systemOverride')">🔑 Secure System Override</button>
            <button class="tab-btn" onclick="switchTab('deleteAccount')">❌ Deletions Desk</button>
            <button class="tab-btn" onclick="switchTab('fullLogs')">📝 Transaction Ledger Audits</button>
        </div>

        <!-- 1. VIEW ALL ACCOUNTS -->
        <div id="accountsList" class="tab-content active">
            <div class="card">
                <h3 class="card-title">Customers Overview Directory</h3>
                <p style="font-size: 0.8rem; color: var(--text-light); margin-bottom: 1rem;">🗣️ Sorting Guide: click Name or Balance columns to perform active client sorting.</p>
                
                <table id="accountsTable">
                    <thead>
                        <tr>
                            <th class="sortable-th" onclick="sortTable(0, 'string')">Customer Name ↕</th>
                            <th class="sortable-th" onclick="sortTable(1, 'string')">Card ID / UserID ↕</th>
                            <th class="sortable-th" onclick="sortTable(2, 'double')">Ledger Balance ↕</th>
                            <th>Account Type</th>
                            <th>Current Card Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (User u : users) {
                                if (u instanceof Customer) {
                                    Customer cust = (Customer) u;
                                    Account linkedAcc = null;
                                    for (Account a : accounts) {
                                        if (a.getOwnerUserId().equalsIgnoreCase(cust.getUserId())) {
                                            linkedAcc = a;
                                            break;
                                        }
                                    }
                        %>
                                <tr>
                                    <td><strong><%= cust.getName() %></strong></td>
                                    <td class="mono"><%= cust.getUserId() %></td>
                                    <td class="mono" data-val="<%= linkedAcc != null ? linkedAcc.getBalance() : 0 %>">
                                        <%= linkedAcc != null ? "PKR " + String.format("%,.2f", linkedAcc.getBalance()) : "N/A" %>
                                    </td>
                                    <td><%= linkedAcc != null ? linkedAcc.getAccountType() : "Unassigned" %></td>
                                    <td>
                                        <% if (cust.isLocked()) { %>
                                            <span style="color: var(--error-red); font-weight:600;">⛔ LOCKED</span>
                                        <% } else { %>
                                            <span style="color: var(--success-green); font-weight:600;">✅ ACTIVE</span>
                                        <% } %>
                                    </td>
                                </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 2. CREATE NEW ACCOUNT -->
        <div id="createAccount" class="tab-content">
            <div class="card" style="max-width: 600px;">
                <h3 class="card-title">➕ Provision New Customer Record</h3>
                <form action="../ManagerServlet" method="POST">
                    <input type="hidden" name="action" value="create">

                    <div class="form-group">
                        <label for="name">Customer Full Name</label>
                        <input type="text" id="name" name="name" placeholder="e.g. Alice Khan" required autocomplete="off">
                    </div>

                    <div class="form-group">
                        <label for="userId">Secure Customer ID (Card Number)</label>
                        <input type="text" id="userId" name="userId" placeholder="e.g. C004" required autocomplete="off">
                        <span style="font-size:0.75rem; color:var(--text-light);">Unique academic card handle (e.g., C001-C999).</span>
                    </div>

                    <div class="form-group">
                        <label for="pin">Temporary Secure PIN (Numeric)</label>
                        <input type="password" id="pin" name="pin" placeholder="Numeric 4-6 digits" maxlength="6" required autocomplete="off">
                    </div>

                    <div class="form-group">
                        <label for="balance">Initial Deposit Balance (PKR)</label>
                        <input type="number" id="balance" name="balance" min="0" placeholder="e.g. 5000" required autocomplete="off">
                    </div>

                    <div class="form-group">
                        <label for="accountType">Account Core Type</label>
                        <select id="accountType" name="accountType">
                            <option value="Savings">Savings Account</option>
                            <option value="Checking">Checking Account</option>
                        </select>
                    </div>

                    <button type="submit" class="btn" style="margin-top: 1rem;">Approve Account Integration</button>
                </form>
            </div>
        </div>

        <!-- 3. OVERRIDING CARD/PIN -->
        <div id="systemOverride" class="tab-content">
            <div class="card" style="max-width: 600px;">
                <h3 class="card-title">🔑 Executive Customer Credentials Override</h3>
                <p style="font-size:0.8rem; color:var(--text-light); margin-bottom:1.5rem;">Perform actions such as manual PIN overrides or manual customer locker locks state transitions.</p>
                
                <form action="../ManagerServlet" method="POST">
                    <input type="hidden" name="action" value="override">

                    <div class="form-group">
                        <label for="overrideCust">Select Target Customer Card ID</label>
                        <select id="overrideCust" name="customerId">
                            <% for(User u : users) { if(u instanceof Customer) { %>
                                <option value="<%= u.getUserId() %>"><%= u.getName() %> (<%= u.getUserId() %>)</option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="newPinOverride">Enter Overridden New PIN (Optional)</label>
                        <input type="password" id="newPinOverride" name="newPin" placeholder="Leave empty to keep existing" maxlength="6" autocomplete="off">
                    </div>

                    <div class="form-group">
                        <label for="lockOverride">Locker Override Status</label>
                        <select id="lockOverride" name="lockStatus">
                            <option value="false">Unlock & Enable Card (Active)</option>
                            <option value="true">Lock & Restrict Card (Locked)</option>
                        </select>
                    </div>

                    <button type="submit" class="btn" style="background-color: var(--accent-blue); margin-top: 1rem;">Apply Security Overrides</button>
                </form>
            </div>
        </div>

        <!-- 4. EXPUNGE ACCOUNTS -->
        <div id="deleteAccount" class="tab-content">
            <div class="card" style="max-width: 600px; border-top: 4px solid var(--error-red);">
                <h3 class="card-title">❌ Remove Customer Portfolio</h3>
                <p style="font-size:0.85rem; color: var(--error-red); margin-bottom: 1.5rem;">🚨 CRITICAL: Removing user records is permanent and irreversible. Linked balances will be expunged.</p>

                <form action="../ManagerServlet" method="POST" onsubmit="return confirmDeletion()">
                    <input type="hidden" name="action" value="delete">

                    <div class="form-group">
                        <label for="deleteCust">Select Customer Card to Exterminate</label>
                        <select id="deleteCust" name="customerId">
                            <option value="">-- Choose Account --</option>
                            <% for(User u : users) { if(u instanceof Customer) { %>
                                <option value="<%= u.getUserId() %>"><%= u.getName() %> (Card: <%= u.getUserId() %>)</option>
                            <% } } %>
                        </select>
                    </div>

                    <button type="submit" class="btn" style="background-color: var(--error-red); margin-top: 1rem;">Permanently Expunge Account</button>
                </form>
            </div>
        </div>

        <!-- 5. audited journal tx list logs -->
        <div id="fullLogs" class="tab-content">
            <div class="card">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 1.5rem;">
                    <h3 class="card-title" style="margin-bottom:0;">Full Transactions Audit Logs</h3>
                    <div>
                        <select id="filterTxType" onchange="runFilterLogs()" style="padding: 0.35rem 0.75rem; font-size: 0.8rem;">
                            <option value="ALL">Show All Transaction Typologies</option>
                            <option value="WITHDRAWAL">Withdrawals Only</option>
                            <option value="DEPOSIT">Deposits Only</option>
                            <option value="ACCOUNT_CREATION">Provisioning Actions Only</option>
                            <option value="OVERRIDE">Credential Overrides Only</option>
                        </select>
                    </div>
                </div>

                <table id="fullAuditsTable">
                    <thead>
                        <tr>
                            <th>DateTime Timestamp</th>
                            <th>Auditor TX ID</th>
                            <th>Linked Account ID</th>
                            <th>TX Operation Typology</th>
                            <th>Amount (PKR)</th>
                            <th>Audit Notes / Override Trace</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (int i = transactions.size() - 1; i >= 0; i--) {
                                Transaction t = transactions.get(i);
                        %>
                                <tr class="tx-row" data-type="<%= t.getType() %>">
                                    <td class="mono"><%= t.getTimestamp() %></td>
                                    <td class="mono" style="font-weight: 500;"><%= t.getTxnId() %></td>
                                    <td class="mono"><%= t.getAccountId() %></td>
                                    <td>
                                        <span class="mono" style="font-weight:600; padding:0.15rem 0.4rem; border-radius:4px; font-size:0.75rem;
                                            <%= t.getType().equals("DEPOSIT") ? "color:#10b981; background-color:#ecfdf5;" :
                                               t.getType().equals("WITHDRAWAL") ? "color:#ef4444; background-color:#fef2f2;" :
                                               "color:#3b82f6; background-color:#eff6ff;" %>">
                                            <%= t.getType() %>
                                        </span>
                                    </td>
                                    <td class="mono">PKR <%= String.format("%,.2f", t.getAmount()) %></td>
                                    <td style="color:var(--text-light);"><%= t.getNotes() %></td>
                                </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <script>
        // tabs selector switch helper
        function switchTab(tabId) {
            var contents = document.getElementsByClassName('tab-content');
            for(var i=0; i<contents.length; i++) {
                contents[i].classList.remove('active');
            }
            var buttons = document.getElementsByClassName('tab-btn');
            for(var i=0; i<buttons.length; i++) {
                buttons[i].classList.remove('active');
            }
            
            document.getElementById(tabId).classList.add('active');
            
            var btnIndex = 0;
            if (tabId === 'accountsList') btnIndex = 0;
            else if (tabId === 'createAccount') btnIndex = 1;
            else if (tabId === 'systemOverride') btnIndex = 2;
            else if (tabId === 'deleteAccount') btnIndex = 3;
            else if (tabId === 'fullLogs') btnIndex = 4;
            buttons[btnIndex].classList.add('active');
        }

        // sorting implementation
        var order = {};
        function sortTable(colIndex, type) {
            var table = document.getElementById("accountsTable");
            var rows = Array.from(table.rows).slice(1);
            
            order[colIndex] = !order[colIndex];
            
            rows.sort(function(a, b) {
                var cellA = a.cells[colIndex];
                var cellB = b.cells[colIndex];
                
                var valA, valB;
                if (type === 'double') {
                    valA = parseFloat(cellA.getAttribute('data-val') || '0');
                    valB = parseFloat(cellB.getAttribute('data-val') || '0');
                } else {
                    valA = cellA.innerText.trim().toLowerCase();
                    valB = cellB.innerText.trim().toLowerCase();
                }
                
                if (valA < valB) return order[colIndex] ? -1 : 1;
                if (valA > valB) return order[colIndex] ? 1 : -1;
                return 0;
            });
            
            var tbody = table.tBodies[0];
            rows.forEach(function(row) {
                tbody.appendChild(row);
            });
        }

        function confirmDeletion() {
            var sel = document.getElementById('deleteCust').value;
            if(!sel) {
                alert('Please select a customer portfolio target to expunge.');
                return false;
            }
            return window.confirm('☠️ CRITICAL SYSTEM OVERRIDE: Are you 100% sure you want to permanently delete custom card ID: ' + sel + '? This expunges users from store databases. This action is terminal and cannot be undone!');
        }

        function runFilterLogs() {
            var typeVal = document.getElementById('filterTxType').value;
            var rows = document.getElementsByClassName('tx-row');
            
            for(var i=0; i<rows.length; i++) {
                var r = rows[i];
                var t = r.getAttribute('data-type');
                if (typeVal === 'ALL' || typeVal === t) {
                    r.style.display = 'table-row';
                } else {
                    r.style.display = 'none';
                }
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
