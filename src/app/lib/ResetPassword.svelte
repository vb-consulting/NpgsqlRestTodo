<script lang="ts">
    import Mail from "lucide-svelte/icons/mail";
    import Dialog from "$lib/Dialog.svelte";
    import api from "$lib/api";
    import { authPasswordResetCode } from "../api/authApi";
    import getAnalytics from "$lib/analytics";

    let { returnToLogin } : { returnToLogin?: ()=>void } = $props();
    let emailInput: HTMLInputElement;
    let emailMsg = $state<string>();
    let working = $state(false);
    
    // svelte-ignore non_reactive_update
    let modal: HTMLDialogElement;

    async function reset() {
        emailMsg = undefined;
        if (!emailInput.value) {
            emailMsg = 'Email is required';
            emailInput.focus();
            return;
        }
        working = true;
        let result = await api(() => authPasswordResetCode({
            email: emailInput.value,
            analytics: JSON.stringify(getAnalytics())
        })) as string;
        working = false;
        if (!result) {
            emailMsg = "Email format is invalid";
            setTimeout(() => {
                emailInput.focus(); 
                emailInput.select();
            }, 0);
            return;
        }
        modal.showModal();
    }
</script>

<div class="form-control">
    <label class="label pb-0.75" class:text-error={emailMsg} for="email">
        <span class="label-text">{emailMsg ?? "Email"}</span>
    </label>
    <label class="input input-bordered flex items-center gap-2" class:input-error={emailMsg} class:input-primary={!emailMsg}>
        <Mail size="16" class="h-4 w-4 opacity-70" />
        <input 
            id="email" 
            type="email" 
            placeholder="email" 
            class="grow" 
            bind:this={emailInput} 
            disabled={working} 
            onkeypress={e => e.key == "Enter" && reset()} 
        />
    </label>
</div>

<button class="btn btn-primary mt-6" onclick={reset} aria-label="Login" disabled={working}>
    {#if working}
        <span class="loading loading-bars loading-xs"></span>
    {:else}
        Send Reset Link
    {/if}
</button>

<Dialog class="text-left" bind:dialog={modal} disableEscape>
    <h3 class="text-lg font-bold">Password Reset Email Sent</h3>
    <div class="py-4">
        <p class="pt-4">
            We've sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.
        </p>
        <p class="pt-4">
            The link will expire in <b>30 minutes</b> for security reasons. If you don't see the email in your inbox, please check your spam or junk folder.
        </p>
        <p class="pt-2">
            The Your Todo Service Team
        </p>
    </div>
    <div class="modal-action">
        <button class="btn" onclick={() => {
            modal.close();
            returnToLogin?.();
        }}>
            Return to Login
        </button>
    </div>
</Dialog>

<style lang="scss">
    .label-text {
        white-space: break-spaces;
        text-align: justify;
    }
</style>