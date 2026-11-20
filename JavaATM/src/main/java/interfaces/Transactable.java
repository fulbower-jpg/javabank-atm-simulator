package interfaces;

/**
 * OOP Demo: ABSTRACTION
 * This interface defines the contract for any financial transactional entity.
 * It demonstrates abstraction by declaring methods without implementation details.
 */
public interface Transactable {
    void deposit(double amount);
    void deposit(double amount, String note); // Method overloading for Polymorphism
    boolean withdraw(double amount);
    double getBalance();
}
