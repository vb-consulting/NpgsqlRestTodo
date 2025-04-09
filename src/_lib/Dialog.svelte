<script lang="ts">
    import { onMount } from "svelte";
    import type { Snippet } from "svelte";
    import type { HTMLDialogAttributes } from 'svelte/elements';
    import generateId from "$lib/generateId";

    let { 
        children, 
        id=generateId(), 
        dialog=$bindable(), 
        disableEscape=false,
        bodyAppendChild=false,
        class: className = "",
        ...others
    } : { 
        children: Snippet, 
        id?: string, 
        dialog?: HTMLDialogElement, 
        disableEscape?: boolean,
        bodyAppendChild?: boolean,
        class?: string,
        others?: Omit<HTMLDialogAttributes, "class">,
    } & Omit<HTMLDialogAttributes, "class"> = $props();

    function disableEscapeKey(e: KeyboardEvent) {
        if (e.key === "Escape") {
            e.preventDefault();
        }
    }

    if (bodyAppendChild && !dialog) {
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
    }
</script>

<dialog id={id} class="{(className + " modal").trim()}" {...others} bind:this={dialog}>
<div class="modal-box">
{@render children?.()}
</div>
</dialog>

<style lang="scss">
</style>