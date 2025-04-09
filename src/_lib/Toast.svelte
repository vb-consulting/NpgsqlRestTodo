<script lang="ts">
    import Bug from "lucide-svelte/icons/bug";
    import X from "lucide-svelte/icons/x";
    import Alert from "lucide-svelte/icons/shield-alert";
    import Info from "lucide-svelte/icons/info";
    import { toasts } from "$lib/toastStore";

    let { removeAfterMs } : { removeAfterMs?: number } = $props();

    let timeout: number | undefined = undefined;
    if (removeAfterMs && removeAfterMs > 0) {
        $effect(() => {
            if ($toasts.length > 0) {
                if (timeout) {
                    clearTimeout(timeout);
                }
                timeout = setTimeout(() => {
                    toasts.set($toasts.slice(1));
                    timeout = undefined;
                }, removeAfterMs);
            }
        });
    }
</script>

<div class="toast">
    {#each $toasts as {message, type}, i}
        <div class="alert shadow-xl" class:alert-error={type === "error"} class:alert-warning={type === "warning"} class:alert-info={type === "info"}>
            {#if type === "info"}
                <Info />
            {:else if type === "warning"}
                <Alert />
            {:else if type === "error"}
                <Bug />
            {/if}
            <span>{message}</span>
            <button class="dismiss tooltip" data-tip="dismiss" onclick={() => toasts.set($toasts.filter((_, j) => i !== j))}>
                <X />
            </button>
        </div>
    {/each}
</div>

<style lang="scss">
    .dismiss {
        cursor: pointer;
    }
</style>