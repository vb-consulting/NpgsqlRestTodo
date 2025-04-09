<script lang="ts">
    import Key from "lucide-svelte/icons/key-round";
    import Toast from "$lib/Toast.svelte";
    import Dialog from "$lib/Dialog.svelte";
    import { authPasswordResetStart, authPasswordReset } from "../api/authApi";
    import api from "$lib/api";
    import generateId from "$lib/generateId";
    import getAnalytics from "$lib/analytics";
    import passwordInfo from "../lib/passwordInfo";
    import moment from "moment";

    let loading = $state(true);
    
    // svelte-ignore non_reactive_update
    let passwordInput: HTMLInputElement;
    // svelte-ignore non_reactive_update
    let repeatInput: HTMLInputElement;

    let passwordMsg = $state<string>();
    let repeatMsg = $state<string>();
    let working = $state(false);

    // svelte-ignore non_reactive_update
    let expiredModal: HTMLDialogElement;
    // svelte-ignore non_reactive_update
    let successModal: HTMLDialogElement;

    let payload = $state<{code: string, email: string}>({
        code: "",
        email: ""
    });
    let minutes = $state<number>(0);
    $effect(() => {
        if (minutes <= 0 && loading == false) {
            expiredModal.showModal();
        }
    });

    const token = generateId(64);

    (async function() {
        try {
            const encoded = document.location.hash.slice(1);
            document.location.hash = "";
            if (!encoded) {
                document.location = "/";
            }
            const decoded = decodeURIComponent(Array.prototype.map.call(window.atob(encoded), c => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2)).join(""));
            payload = JSON.parse(decoded);
            if (!payload || !payload.code || !payload.email) {
                document.location = "/";
            }
            const result = await api(() => authPasswordResetStart({
                code: payload.code,
                email: payload.email,
                token: token,
                timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                analytics: JSON.stringify(getAnalytics())
            }));
            if (!result) {
                document.location = "/";
                return;
            }
            minutes = moment(result).diff(moment(), "minutes");
            if (minutes <= 0) {
                document.location = "/";
                return;
            }
            setInterval(() => minutes = moment(result).diff(moment(), "minutes"), 10000); // this is impossible with react, just saying
            loading = false;
            setTimeout(() => passwordInput.focus(), 0);
        } catch (e) {
            //document.location = "/";
            console.error(e);
        }
    })();

    async function reset() {
        const result = await api(() => authPasswordReset({
            code: payload.code,
            email: payload.email,
            token: token,
            password: passwordInput.value,
            repeat: repeatInput.value,
            analytics: JSON.stringify(getAnalytics())
        })) as IAuthPasswordResetResponse;
        const code = result?.code ?? -1;
        if (code == 101) {
            expiredModal.showModal();
        } else if (code == 0) {
            successModal.showModal();
        } else if (code > 0 && code < 100) {
            passwordMsg = result.message as string;
            passwordInput.focus();
            passwordInput.select();
        } else {
            document.location = "/"
        }
    }
</script>

{#if loading}
<div class="min-h-screen bg-base-300 hero">
    <div class="loader-container">
        <div class="flex flex-col items-center justify-center space-y-6">
            <div class="loading loading-spinner text-primary w-32"></div>
            <h2 class="text-2xl font-semibol text-primary">Checking the link</h2>
            <p class="text-warning">Please wait while we verify some data...</p>
        </div>
    </div>
</div>
{:else}
<div class="min-h-screen hero">
    <div class="card bg-base-300 max-w-sm shadow-xl md:order-1 justify-self-center">
        <div class="hero-content block space-y-6">
            <h2 class="text-2xl">Reset Password for {payload?.email}</h2>
            <div class="text-justify text-sm mb-4 text-black/60 dark:text-white/70">
                <p>
                    {passwordInfo()}
                </p>
                <p class="mt-2" class:text-warning={minutes <= 5}>
                    This form expires in {minutes} {minutes == 1 ? "minute" : "minutes"}.
                </p>
            </div>
            
            <div class="form-control">
                <label class="label pb-0.75" class:text-error={passwordMsg} for="password">
                    <span class="label-text">{passwordMsg ?? "New Password"}</span>
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
                        onkeypress={e => {if (e.key == "Enter"){repeatInput.focus(); repeatInput.select()}}} 
                    />
                </label>
            </div>
            <div class="form-control">
                <label class="label pb-0.75" class:text-error={repeatMsg} for="repeat">
                    <span class="label-text">{repeatMsg ?? "Repeat New Password"}</span>
                </label>
                <label class="input input-bordered flex items-center gap-2" class:input-error={repeatMsg} class:input-primary={!repeatMsg}>
                    <Key size="16" class="h-4 w-4 opacity-70" />
                    <input 
                        id="repeat" 
                        type="password" 
                        placeholder="repeat password" 
                        class="grow" 
                        bind:this={repeatInput} 
                        disabled={working} 
                        onkeypress={e => e.key == "Enter" && reset()} 
                    />
                </label>
            </div>

            <button class="btn btn-primary mt-1" onclick={reset} aria-label="Reset" disabled={working}>
                {#if working}
                    <span class="loading loading-bars loading-xs"></span>
                {:else}
                    Reset
                {/if}
            </button>
        </div>
    </div>
</div>
{/if}

<Dialog bind:dialog={expiredModal} disableEscape bodyAppendChild>
    <h3 class="text-lg font-bold">
        Form Expired !
    </h3>
    <div class="py-4">
        <p>
            To protect your account, the link you clicked has expired.
        </p>
        <p class="pt-4">
            Please try again by requesting a new password reset link.
        </p>
    </div>
    <div class="modal-action">
        <button class="btn" onclick={() => document.location = "/?login"} aria-label="Return to Login">
            Return to Login
        </button>
    </div>
</Dialog>

<Dialog bind:dialog={successModal} disableEscape bodyAppendChild>
    <h3 class="text-lg font-bold">
        Password Successfully Reset !
    </h3>
    <div class="py-4">
        <p>
            Your password has been updated. Your account is now secure with your new password.
        </p>
        <p class="pt-4">
            Click the "Go to Login" button below to sign in with your new credentials.
        </p>
    </div>
    <div class="modal-action">
        <button class="btn" onclick={() => document.location = "/?login"} aria-label="Return to Login">
            Go to Login
        </button>
    </div>
</Dialog>

<Toast removeAfterMs={0} />

<style lang="scss">
</style>