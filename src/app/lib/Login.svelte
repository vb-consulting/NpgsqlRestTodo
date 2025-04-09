<script lang="ts">
    import Mail from "lucide-svelte/icons/mail";
    import Key from "lucide-svelte/icons/key-round";
    import Alert from "lucide-svelte/icons/octagon-x";

    import { authLogin } from "../api/authApi";
    import user from "$lib/user";
    import getAnalytics from "$lib/analytics";

    let emailInput: HTMLInputElement;
    let passwordInput: HTMLInputElement;

    let emailMsg = $state<string>();
    let passwordMsg = $state<string>();
    let working = $state(false);
    let success = $state<boolean | undefined>();

    async function login() {
        passwordMsg = undefined;
        emailMsg = undefined;
        success = undefined;

        if (!emailInput.value) {
            emailMsg = 'Email is required';
            emailInput.focus();
            return;
        }
        if (!passwordInput.value) {
            passwordMsg = 'Password is required';
            passwordInput.focus();
            return;
        }
        working = true;
        const result = await authLogin({
            username: emailInput.value,
            password: passwordInput.value,
            analytics: JSON.stringify(getAnalytics())
        });
        working = false;
        if (result.status === 200) {
            success = true;
            user.set(JSON.parse(result.response));
        } else {
            success = false;
            setTimeout(() => {
                emailInput.focus();
                emailInput.select();
                passwordInput.value = "";
            }, 0);
        }
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
            onkeypress={e => {if (e.key == "Enter"){passwordInput.focus(); passwordInput.select()}}} 
        />
    </label>
</div>
<div class="form-control">
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
            onkeypress={e => e.key == "Enter" && login()} 
        />
    </label>
</div>

<div class="text-error mt-1 flex items-center" class:invisible={success != false}>
    <Alert size="16" class="h-4 w-4 opacity-70" />
    <span class="ml-2">Invalid Email Or Password</span>
</div>

<button class="btn btn-primary mt-1" onclick={login} aria-label="Login" disabled={working}>
    {#if working}
        <span class="loading loading-bars loading-xs"></span>
    {:else}
        Login
    {/if}
</button>

<style lang="scss">
    .label-text {
        white-space: break-spaces;
        text-align: justify;
    }
</style>