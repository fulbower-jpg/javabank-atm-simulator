<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank - 403 Forbidden</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 2rem; background: #0f172a; color: white;">
        <div style="text-align: center; max-width: 500px;">
            <p style="font-size: 5rem; font-weight: 700; color: #ef4444; margin-bottom: 1rem;">403</p>
            <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">Unauthorized Access Attempted</h2>
            <%
                String error = request.getParameter("error");
            %>
            <p style="color: #ef4444; font-weight:600; font-family: monospace; margin-bottom: 1rem;">
                <%= error != null ? error : "Core security boundaries triggered. Role clearance mismatch." %>
            </p>
            <p style="color: #94a3b8; font-size: 0.9rem; margin-bottom: 2rem;">Your session token role does not carry sufficient clearance to query this staff/clerk dashboard.</p>
            <a href="../index.jsp" class="btn" style="background-color: var(--accent-blue);">Return to Login Terminal</a>
        </div>
    </div>
</body>
</html>
