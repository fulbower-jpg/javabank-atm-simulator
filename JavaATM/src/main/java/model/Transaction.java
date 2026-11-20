package model;

/**
 * OOP Demo: ENCAPSULATION, POLYMORPHISM
 * - ENCAPSULATION: All internal states of a transaction are private and read-only (no setters, making it immutable).
 * - POLYMORPHISM: Overrides toString() to display formatted output.
 */
public class Transaction {
    private String txnId;
    private String accountId;
    private String type; // DEPOSIT, WITHDRAWAL, etc.
    private double amount;
    private String timestamp; // yyyy-MM-dd HH:mm:ss
    private String notes;

    public Transaction(String txnId, String accountId, String type, double amount, String timestamp, String notes) {
        this.txnId = txnId;
        this.accountId = accountId;
        this.type = type;
        this.amount = amount;
        this.timestamp = timestamp;
        this.notes = notes;
    }

    public String getTxnId() {
        return txnId;
    }

    public String getAccountId() {
        return accountId;
    }

    public String getType() {
        return type;
    }

    public double getAmount() {
        return amount;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public String getNotes() {
        return notes;
    }

    @Override
    public String toString() {
        return "Transaction [ID=" + txnId + ", Account=" + accountId + ", Type=" + type + ", Amount=" + amount + ", Date=" + timestamp + "]";
    }
}
