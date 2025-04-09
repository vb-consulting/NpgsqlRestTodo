const _characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

/**
 * Generate random characters string
 * @param length default 5
 */
export default function generateId(length: number = 5) {
    let result = "";
    for (let i = 0; i < length; i++) {
        result += _characters.charAt(Math.floor(Math.random() * _characters.length));
    }
    return result;
}
