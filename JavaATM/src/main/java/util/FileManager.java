package util;

import model.*;
import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * OOP Demo: POLYMORPHISM, ENCAPSULATION
 * - POLYMORPHISM: Demonstrates usage of polymorphic references (User u = new Customer(...) or User u = new Clerk(...))
 *                 when loading and handling instances in memory.
 * - ENCAPSULATION: File paths and internal CSV parsing logic are encapsulated as private mechanisms.
 */
public class FileManager {
    private static final String DATA_DIR = "JavaATM/data";
    private static final String USERS_FILE = DATA_DIR + "/users.csv";
    private static final String ACCOUNTS_FILE = DATA_DIR + "/accounts.csv";
    private static final String TX_FILE = DATA_DIR + "/transactions.csv";
    private static final String ATM_FILE = DATA_DIR + "/atm_inventory.csv";

    // Static block for auto loading and checking directories
    static {
        try {
            File dir = new File(DATA_DIR);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            initializeDefaultData();
        } catch (Exception e) {
            System.err.println("Failed to initialize system directory configurations: " + e.getMessage());
        }
    }

    private static void initializeDefaultData() throws IOException {
        // Users File Initialization
        File usersFile = new File(USERS_FILE);
        if (!usersFile.exists() || usersFile.length() == 0) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(usersFile))) {
                writer.write("userId,name,hashedPin,role,isLocked,employeeId\n");
                writer.write("C001,Alice Khan," + PinHasher.hashPin("1234") + ",Customer,false,\n");
                writer.write("C002,Bob Raza," + PinHasher.hashPin("5678") + ",Customer,false,\n");
                writer.write("C003,Carol Malik," + PinHasher.hashPin("9012") + ",Customer,true,\n");
                writer.write("S001,Hassan Ali," + PinHasher.hashPin("1111") + ",Clerk,false,EMP01\n");
                writer.write("S002,Sara Noor," + PinHasher.hashPin("2222") + ",Technician,false,EMP02\n");
                writer.write("S003,Ahmed Siddiqui," + PinHasher.hashPin("3333") + ",Manager,false,EMP03\n");
            }
        }

        // Accounts File Initialization
        File accountsFile = new File(ACCOUNTS_FILE);
        if (!accountsFile.exists() || accountsFile.length() == 0) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(accountsFile))) {
                writer.write("accountId,ownerUserId,accountType,balance\n");
                writer.write("ACT001,C001,Savings,25000.0\n");
                writer.write("ACT002,C002,Checking,7500.0\n");
                writer.write("ACT003,C003,Savings,12000.0\n");
            }
        }

        // Transactions File Initialization
        File txFile = new File(TX_FILE);
        if (!txFile.exists() || txFile.length() == 0) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(txFile))) {
                writer.write("txnId,accountId,type,amount,timestamp,notes\n");
                writer.write("TX10001,ACT001,DEPOSIT,25000.0,2026-06-01 10:00:00,Initial deposit\n");
                writer.write("TX10002,ACT002,DEPOSIT,7500.0,2026-06-01 11:00:00,Initial deposit\n");
                writer.write("TX10003,ACT003,DEPOSIT,12000.0,2026-06-01 12:00:00,Initial deposit\n");
            }
        }

        // ATM Inventory File Initialization
        File atmFile = new File(ATM_FILE);
        if (!atmFile.exists() || atmFile.length() == 0) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(atmFile))) {
                writer.write("500000.0,2026-06-01 09:00:00,0\n");
            }
        }
    }

    public static List<User> loadUsers() {
        List<User> usersList = new ArrayList<>();
        File file = new File(USERS_FILE);
        if (!file.exists()) return usersList;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line = reader.readLine(); // skip header
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",", -1);
                if (parts.length >= 6) {
                    String userId = parts[0];
                    String name = parts[1];
                    String hashedPin = parts[2];
                    String role = parts[3];
                    boolean isLocked = Boolean.parseBoolean(parts[4]);
                    String employeeId = parts[5];

                    // Polymorphic references to hold different subtypes under User class reference
                    User u = null;
                    if ("Customer".equalsIgnoreCase(role)) {
                        u = new Customer(userId, name, hashedPin, isLocked);
                    } else if ("Clerk".equalsIgnoreCase(role)) {
                        u = new Clerk(userId, name, hashedPin, employeeId);
                    } else if ("Technician".equalsIgnoreCase(role)) {
                        u = new Technician(userId, name, hashedPin, employeeId);
                    } else if ("Manager".equalsIgnoreCase(role)) {
                        u = new Manager(userId, name, hashedPin, employeeId);
                    }

                    if (u != null) {
                        usersList.add(u);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("IOException reading users: " + e.getMessage());
        }
        return usersList;
    }

    public static void saveUsers(List<User> users) {
        try (BufferedWriter writer = new BufferedWriter(new BufferedWriter(new FileWriter(USERS_FILE)))) {
            writer.write("userId,name,hashedPin,role,isLocked,employeeId\n");
            for (User u : users) {
                boolean isLocked = false;
                String empId = "";
                if (u instanceof Customer) {
                    isLocked = ((Customer) u).isLocked();
                } else if (u instanceof BankStaff) {
                    empId = ((BankStaff) u).getEmployeeId();
                }
                writer.write(String.format("%s,%s,%s,%s,%b,%s\n",
                        u.getUserId(), u.getName(), u.getHashedPinForStorage(), u.getRole(), isLocked, empId));
            }
        } catch (IOException e) {
            System.err.println("IOException writing users: " + e.getMessage());
        }
    }

    public static List<Account> loadAccounts() {
        List<Account> accountsList = new ArrayList<>();
        File file = new File(ACCOUNTS_FILE);
        if (!file.exists()) return accountsList;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line = reader.readLine(); // skip header
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",", -1);
                if (parts.length >= 4) {
                    String accountId = parts[0];
                    String ownerUserId = parts[1];
                    String accountType = parts[2];
                    double balance = Double.parseDouble(parts[3]);

                    Account acc = new Account(accountId, ownerUserId, accountType, balance);
                    accountsList.add(acc);
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.err.println("IOException loading accounts: " + e.getMessage());
        }
        return accountsList;
    }

    public static void saveAccounts(List<Account> accounts) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(ACCOUNTS_FILE))) {
            writer.write("accountId,ownerUserId,accountType,balance\n");
            for (Account acc : accounts) {
                writer.write(String.format("%s,%s,%s,%.2f\n",
                        acc.getAccountId(), acc.getOwnerUserId(), acc.getAccountType(), acc.getBalance()));
            }
        } catch (IOException e) {
            System.err.println("IOException writing accounts: " + e.getMessage());
        }
    }

    public static List<Transaction> loadTransactions() {
        List<Transaction> txList = new ArrayList<>();
        File file = new File(TX_FILE);
        if (!file.exists()) return txList;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line = reader.readLine(); // skip header
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",", -1);
                if (parts.length >= 6) {
                    String txnId = parts[0];
                    String accountId = parts[1];
                    String type = parts[2];
                    double amount = Double.parseDouble(parts[3]);
                    String timestamp = parts[4];
                    String notes = parts[5];

                    txList.add(new Transaction(txnId, accountId, type, amount, timestamp, notes));
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.err.println("IOException reading transactions: " + e.getMessage());
        }
        return txList;
    }

    public static void appendTransaction(String accountId, String type, double amount, String notes) {
        String txnId = "TX" + (10000 + loadTransactions().size() + 1);
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(TX_FILE, true))) {
            writer.write(String.format("%s,%s,%s,%.2f,%s,%s\n",
                    txnId, accountId, type, amount, timestamp, notes));
            incrementAtmTxCount(type.equals("WITHDRAWAL") ? -amount : (type.equals("DEPOSIT") ? amount : 0));
        } catch (IOException e) {
            System.err.println("IOException appending transactional details: " + e.getMessage());
        }
    }

    public static String getAtmInventoryString() {
        File file = new File(ATM_FILE);
        if (!file.exists()) return "500000.0,2026-06-01 09:00:00,0";
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line = reader.readLine();
            if (line != null) return line;
        } catch (Exception e) {}
        return "500000.0,2026-06-01 09:00:00,0";
    }

    public static void saveAtmInventory(double cashLevel, String lastRefillTimestamp, int txCount) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(ATM_FILE))) {
            writer.write(String.format("%.2f,%s,%d\n", cashLevel, lastRefillTimestamp, txCount));
        } catch (IOException e) {
            System.err.println("IOException writing inventory specs: " + e.getMessage());
        }
    }

    private static void incrementAtmTxCount(double cashDelta) {
        try {
            String data = getAtmInventoryString();
            String[] parts = data.split(",");
            double cashLevel = Double.parseDouble(parts[0]) + cashDelta;
            String lastRefill = parts[1];
            int count = Integer.parseInt(parts[2].trim()) + 1;
            saveAtmInventory(cashLevel, lastRefill, count);
        } catch (Exception e) {
            System.err.println("Failed to increment count: " + e.getMessage());
        }
    }
}
