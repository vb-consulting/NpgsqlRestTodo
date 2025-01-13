import { writable } from "svelte/store";

type ToastType = "info" | "warning" | "error";

export const toasts = writable<{message: string, type: ToastType}[]>([]);

export function addError(message: string) {
    toasts.update(t => [...t, { message, type: "error" }]);
}
export function addWarning(message: string) {
    toasts.update(t => [...t, { message, type: "warning" }]);
}
export function addInfo(message: string) {
    toasts.update(t => [...t, { message, type: "info" }]);
}
