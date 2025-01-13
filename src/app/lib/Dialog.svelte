<script lang="ts">
    import { onMount } from "svelte";
    import type { Snippet } from "svelte";
    import { generateId } from "$lib/functions";

    let { 
        children, id=generateId(), dialog=$bindable(), disableEscape=false,
    } : { 
        children: Snippet, id?: string, dialog?: HTMLDialogElement, disableEscape?: boolean,
    } = $props();

    function disableEscapeKey(e: KeyboardEvent) {
        if (e.key === "Escape") {
            e.preventDefault();
        }
    }

    onMount(() => {
        if (!dialog) {
            return;
        }
        if (disableEscape) {
            dialog.addEventListener("keydown", disableEscapeKey);
        }
        document.body.appendChild(dialog);
        return () => {
            if (dialog && document.body.contains(dialog)) {
                document.body.removeChild(dialog);
                if (disableEscape) {
                    dialog.removeEventListener("keydown", disableEscapeKey);
                }
            }
        };
    });
</script>

<dialog id={id} class="modal" bind:this={dialog}>
<div class="modal-box">
{@render children?.()}
</div>
</dialog>

<style lang="scss">
</style>