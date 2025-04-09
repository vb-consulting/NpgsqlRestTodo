<script lang="ts">
    import Mail from "lucide-svelte/icons/mail";
    import Key from "lucide-svelte/icons/key-round";
    import api from "$lib/api";
    import { authRegister } from "../api/authApi";
    import getAnalytics from "$lib/analytics";
    import Dialog from "$lib/Dialog.svelte";
    import passwordInfo from "./passwordInfo";

    let { returnToLogin } : { returnToLogin?: ()=>void } = $props();

    // svelte-ignore non_reactive_update
    let emailInput: HTMLInputElement;
    
    let passwordInput: HTMLInputElement;
    let confirmPasswordInput: HTMLInputElement;

    let emailMsg = $state<string>();
    let passwordMsg = $state<string>();
    let confirmPasswordMsg = $state<string>();
    let working = $state(false);
    
    // svelte-ignore non_reactive_update
    let successModal: HTMLDialogElement;

    async function register() {
        // Reset all message states
        emailMsg = undefined;
        passwordMsg = undefined;
        confirmPasswordMsg = undefined;

        // Validate email
        if (!emailInput.value) {
            emailMsg = 'Email is required';
            emailInput.focus();
            return;
        }

        // Validate password
        if (!passwordInput.value) {
            passwordMsg = 'Password is required';
            passwordInput.focus();
            return;
        }

        // Validate password confirmation
        if (!confirmPasswordInput.value) {
            confirmPasswordMsg = 'Please confirm your password';
            confirmPasswordInput.focus();
            return;
        }

        // Check if passwords match
        if (passwordInput.value !== confirmPasswordInput.value) {
            confirmPasswordMsg = 'Passwords do not match';
            confirmPasswordInput.focus();
            return;
        }

        working = true;
        const result = await api(() => authRegister({
            email: emailInput.value,
            password: passwordInput.value,
            repeat: passwordInput.value,
            analytics: JSON.stringify(getAnalytics())
        })) as IAuthRegisterResponse;
        working = false;

        if (result.code == 0) {
            successModal.showModal();
        } else if (result.code == 10) {
            // Email already exists, can't register twice, just redirect to login or reset passwrod
            returnToLogin?.();
        } else if (result.code == 1) {
            emailMsg = result.message ?? "";
            emailInput.focus();
        } else if (result.code == 3) {
            confirmPasswordMsg = result.message ?? "";
            confirmPasswordInput.focus();
        } else {
            passwordMsg = result.message ?? "";
            passwordInput.focus();

            passwordInput.value = "";
            confirmPasswordInput.value = "";
        }
    }
</script>

<div class="text-justify text-sm mb-4 text-black/60 dark:text-white/70">
    {passwordInfo()}
</div>

<div class="form-control max-w-xs">
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
            onkeypress={e => {if (e.key == "Enter"){passwordInput.focus(); passwordInput.select()}}} 
        />
    </label>
</div>

<div class="form-control max-w-xs">
    <label class="label pb-0.75" class:text-error={passwordMsg} for="password">
        <span class="label-text">{passwordMsg ?? "Password"}</span>
    </label>
    <label class="input input-bordered flex items-center gap-2" class:input-error={passwordMsg} class:input-primary={!passwordMsg}>
        <Key size="16" class="h-4 w-4 opacity-70" />
        <input 
            id="password" 
            type="password" 
            placeholder="password" 
            class="grow" 
            bind:this={passwordInput} 
            disabled={working} 
            onkeypress={e => {if (e.key == "Enter"){confirmPasswordInput.focus(); confirmPasswordInput.select()}}} 
        />
    </label>
</div>

<div class="form-control max-w-xs">
    <label class="label pb-0.75" class:text-error={confirmPasswordMsg} for="confirmPassword">
        <span class="label-text">{confirmPasswordMsg ?? "Confirm Password"}</span>
    </label>
    <label class="input input-bordered flex items-center gap-2" class:input-error={confirmPasswordMsg} class:input-primary={!confirmPasswordMsg}>
        <Key size="16" class="h-4 w-4 opacity-70" />
        <input 
            id="confirmPassword" 
            type="password" 
            placeholder="confirm password" 
            class="grow" 
            bind:this={confirmPasswordInput} 
            disabled={working} 
            onkeypress={e => e.key == "Enter" && register()} 
        />
    </label>
</div>

<button class="btn btn-primary mt-6" onclick={register} aria-label="Register" disabled={working}>
    {#if working}
        <span class="loading loading-bars loading-xs"></span>
    {:else}
        Register
    {/if}
</button>

<Dialog bind:dialog={successModal} disableEscape bodyAppendChild>
    <h3 class="text-lg font-bold">Almost There – Confirm Your Registration!</h3>
    <div class="py-4">
        <p>
            Hi {emailInput?.value ?? "New User"},
        </p>
        <p class="pt-4">
            Thanks for signing up with Your Todo Service! We’ve sent a confirmation email to your inbox. 
        </p>
        <p class="pt-4">
            Please check your email (and spam/junk folder, just in case) and click the link inside to complete your registration. 
        </p>
        <p class="pt-4">
            Once you do, you’ll be all set to use this awesome Todo application. If you run into any issues, feel free to let us know—we’re here to help!
            Looking forward to having you with us,
        </p>
        <p class="pt-2">
            The Your Todo Service Team
        </p>
    </div>
    <div class="modal-action">
        <button class="btn" onclick={() => {
            successModal.close();
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