const regex = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;

/**
 * Sanitize html string for Cross Site Scripting (XSS) attacks.
 * If input contains script tag, empty string will be returned and warning will be raised.
 *
 * @param input input html string
 * @param search a segment to mark
 * @param open opening tag
 * @param open closing tag
 */
export default function sanitize(input: string) {
    if (!input) {
        return input;
    }
    if (regex.test(input)) {
        console.warn("Input contains script tag. It will be removed.");
        return "";
    }
    return input;
}
