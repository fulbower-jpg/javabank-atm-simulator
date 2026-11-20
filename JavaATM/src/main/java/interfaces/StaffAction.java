package interfaces;

/**
 * OOP Demo: ABSTRACTION
 * This interface defines the behavior of staff actions.
 * Clerks, Technicians, and Managers implement this differently, demonstrating Polymorphism.
 */
public interface StaffAction {
    String performAction(String targetUserId, String details);
}
