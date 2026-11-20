# JavaBank ATM Simulator

A fully-functional, console-based **Bank ATM Simulation System** built with Java EE (Servlets + JSP) as a second-semester **Object-Oriented Programming (OOP)** university project.

## 👤 Author

**Aman Mushtaq**

## 📖 About

This project simulates a real-world ATM and bank management system with multiple user roles — Customers, Clerks, Technicians, and Managers. It is designed to demonstrate all four core OOP pillars in a practical web application context.

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java Servlets (javax.servlet-api 4.x) |
| Frontend | JSP pages with JSTL |
| Styling | Plain CSS (single responsive stylesheet) |
| Storage | File I/O — CSV flat files |
| Build | Apache Maven |
| Server | Apache Tomcat 9 / 10 |

## 🧱 OOP Structure

### 1. Encapsulation
- `Account.java` — Balance is `private`, modified only via `deposit()` / `withdraw()`
- `User.java` — PIN stored as a private hash, never exposed externally
- All model fields are private with public getters/setters

### 2. Inheritance
- `User.java` → Abstract base for all users
- `Customer.java` → Extends `User`
- `BankStaff.java` → Abstract subclass of `User`
- `Clerk`, `Technician`, `Manager` → Extend `BankStaff`

### 3. Polymorphism
- `getDashboardView()` overridden in every subclass to load role-specific screens
- `Account.deposit()` overloaded: simple amount vs. amount + note
- Dynamic dispatch used when loading users from CSV (`User u = new Customer(...)`)

### 4. Abstraction
- `User` and `BankStaff` declared `abstract`
- `Transactable` interface — contract for cash operations (implemented by `Account`)
- `StaffAction` interface — contract for employee roles (implemented by `Clerk`, `Technician`, `Manager`)

## ✨ Features

- 🔐 Secure PIN login with hashing and account lockout
- 💰 Deposit, withdraw, balance check, transaction history
- 👨‍💼 Role-based dashboards: Customer / Clerk / Technician / Manager
- 🔑 Manager: create/delete accounts, PIN override
- 🔓 Clerk: unlock locked customer accounts
- 🛠️ Technician: system maintenance view
- 💾 Persistent data via CSV file storage
- 🌐 Fully responsive web UI

## 🚀 How to Run

### Prerequisites
- Java JDK 11+
- Apache Maven
- Apache Tomcat 9 or 10

### Build
```bash
cd JavaATM
mvn clean package
```

### Deploy
```bash
cp target/JavaATM.war /path/to/tomcat/webapps/
# Start Tomcat, then visit:
# http://localhost:8080/JavaATM
```

## 🔑 Default Login Credentials

### Customers
| Card ID | Name | PIN | Balance | Status |
|---------|------|-----|---------|--------|
| C001 | Alice Khan | 1234 | PKR 25,000 | Active |
| C002 | Bob Raza | 5678 | PKR 7,500 | Active |
| C003 | Carol Malik | 9012 | PKR 12,000 | Locked |

### Staff
| ID | Name | PIN | Role |
|----|------|-----|------|
| S001 | Hassan Ali | 1111 | Clerk |
| S002 | Sara Noor | 2222 | Technician |
| S003 | Ahmed Siddiqui | 3333 | Manager |

## 📂 Project Structure

```
JavaATM/
├── pom.xml
└── src/main/
    ├── java/
    │   ├── interfaces/      # Transactable, StaffAction
    │   ├── model/           # User, Customer, BankStaff, Clerk, Manager, Technician, Account, Transaction
    │   ├── servlet/         # LoginServlet, CustomerServlet, ClerkServlet, ManagerServlet, TechnicianServlet, LogoutServlet
    │   └── util/            # FileManager, PinHasher, SessionValidator
    └── webapp/
        ├── css/             # style.css
        ├── customer/        # dashboard, deposit, withdraw, history, changepin JSPs
        ├── staff/           # clerk, manager, technician JSPs
        ├── error/           # 404, unauthorized JSPs
        └── index.jsp        # Login page
```

## 🎓 Course Info

- **Course:** Object-Oriented Programming (OOP)
- **Semester:** 2nd Semester
- **Institution:** Iqra University
