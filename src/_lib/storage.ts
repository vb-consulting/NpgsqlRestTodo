const defaultPrefix = (window.location.pathname + "/setting").replace(/\/+/g, '/');

function getStorageKey(key: string, prefix?: string): string {
    return `${prefix || defaultPrefix}-${key}`;
}

export function loadFromStorage<T>(key: string, defaultValue: T, prefix?: string): T {
    if (typeof localStorage === 'undefined') return defaultValue;
    try {
        const stored = localStorage.getItem(getStorageKey(key, prefix));
        return stored ? JSON.parse(stored) : defaultValue;
    } catch {
        return defaultValue;
    }
}

export function saveToStorage<T>(key: string, value: T, prefix?: string): void {
    if (typeof localStorage === 'undefined') return;
    try {
        localStorage.setItem(getStorageKey(key, prefix), JSON.stringify(value));
    } catch {
        // Silently fail if localStorage is not available
    }
}