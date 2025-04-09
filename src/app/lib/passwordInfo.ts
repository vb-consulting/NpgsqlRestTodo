import {
    AUTH_MIN_PASSWORD_LENGTH,
    AUTH_REQUIRED_UPPERCASE,
    AUTH_REQUIRED_LOWERCASE,
    AUTH_REQUIRED_NUMBER,
    AUTH_REQUIRED_SPECIAL
} from "$lib/env";

/**
 * Returns a user-friendly message describing password requirements
 * @returns {string} A user-friendly message with password requirements
 */
export default function(): string {
    const requirements: string[] = [];

    // Handle length requirements
    if (AUTH_MIN_PASSWORD_LENGTH) {
        requirements.push(`be at least ${AUTH_MIN_PASSWORD_LENGTH} characters long`);
    }

    // Handle character type requirements
    if (AUTH_REQUIRED_UPPERCASE) {
        const plural = AUTH_REQUIRED_UPPERCASE > 1 ? 's' : '';
        requirements.push(`contain at least ${AUTH_REQUIRED_UPPERCASE} uppercase letter${plural}`);
    }

    if (AUTH_REQUIRED_LOWERCASE) {
        const plural = AUTH_REQUIRED_LOWERCASE > 1 ? 's' : '';
        requirements.push(`contain at least ${AUTH_REQUIRED_LOWERCASE} lowercase letter${plural}`);
    }

    if (AUTH_REQUIRED_NUMBER) {
        const plural = AUTH_REQUIRED_NUMBER > 1 ? 's' : '';
        requirements.push(`contain at least ${AUTH_REQUIRED_NUMBER} number${plural}`);
    }

    if (AUTH_REQUIRED_SPECIAL) {
        const plural = AUTH_REQUIRED_SPECIAL > 1 ? 's' : '';
        requirements.push(`contain at least ${AUTH_REQUIRED_SPECIAL} special character${plural}`);
    }

    // Handle edge case where no requirements are set
    if (requirements.length === 0) {
        return "There are no specific requirements for your password.";
    }

    // Format the message with proper grammar
    let message = "Your password must ";

    if (requirements.length === 1) {
        message += requirements[0] + ".";
    } else {
        const lastRequirement = requirements.pop();
        message += requirements.join(", ") + ", and " + lastRequirement + ".";
    }

    return message;
}