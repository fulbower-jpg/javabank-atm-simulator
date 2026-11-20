package model;

import interfaces.Transactable;

/**
 * OOP Demo: ENCAPSULATION, ABSTRACTION, POLYMORPHISM
 * - ENCAPSULATION: Balance and other fields are private and cannot be set directly from outside.
 *                  Balance is altered securely through deposit() and withdraw() methods only.
 * - ABSTRACTION: Implements the Transactable interface.
 * - POLYMORPHISM: Demonstrates method overloading (compile-time polymorphism) with
 *                 deposit(double amount) and deposit(double amount, String note). Overrides toString().
 */
public class Account implements Transactable {
    private String accountId;
    private String ownerUserId;
    private String accountType; // Savings or Checking
    private double balance;

    public Account(String accountId, String ownerUserId, String accountType, double initialBalance) {
        this.accountId = accountId;
        this.ownerUserId = ownerUserId;
        this.accountType = accountType;
        this.balance = initialBalance;
    }

    public String getAccountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public String getOwnerUserId() {
        return ownerUserId;
    }

    public void setOwnerUserId(String ownerUserId) {
        this.ownerUserId = ownerUserId;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    // Implementing Transactable - Encapsulation bounds Balance modifiers securely
    @Override
    public double getBalance() {
        return balance;
    }

    @Override
    public void deposit(double amount) {
        if (amount > 0) {
            this.balance += amount;
        }
    }

    // Method overloading - Compile-time Polymorphism
    @Override
    public void deposit(double amount, String note) {
        if (amount > 0) {
            this.balance += amount;
            // The note parameter exists for polymorphism verification
        }
    }

    @Override
    public boolean withdraw(double amount) {
        if (amount > 0 && amount <= this.balance) {
            this.balance -= amount;
            return true;
        }
        return false;
    }

    @Override
    public String toString() {
        return "Account [ID=" + accountId + ", Owner=" + ownerUserId + ", Type=" + accountType + ", Balance=" + balance + "]";
    }
}
