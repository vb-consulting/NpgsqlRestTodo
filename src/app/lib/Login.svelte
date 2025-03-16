<script lang="ts">
    import { fade as animation } from "svelte/transition";
    import Mail from "lucide-svelte/icons/mail";
    import Key from "lucide-svelte/icons/key-round";
    import Alert from "lucide-svelte/icons/shield-alert";

    import { authLogin } from "$api/authApi";
    import user from "$lib/user";

    let emailInput: HTMLInputElement;
    let passwordInput: HTMLInputElement;

    let emailMsg = $state<string>();
    let passwordMsg = $state<string>();
    let working = $state(false);
    let success = $state<boolean | undefined>();

    async function login() {
        passwordMsg = "";
        emailMsg = "";
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
            data: JSON.stringify(getAnalyticsData())
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

    const getAnalyticsData = () => ({
        timestamp: new Date().toISOString(),
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
        screen: {
            width: window.screen.width,
            height: window.screen.height,
            colorDepth: window.screen.colorDepth,
            pixelRatio: window.devicePixelRatio,
            orientation: screen.orientation.type
        },
        browser: {
            userAgent: navigator.userAgent,
            language: navigator.language,
            languages: navigator.languages,
            cookiesEnabled: navigator.cookieEnabled,
            doNotTrack: navigator.doNotTrack,
            onLine: navigator.onLine,
            platform: navigator.platform,
            vendor: navigator.vendor
        },
        memory: {
            deviceMemory: (navigator as any).deviceMemory,
            hardwareConcurrency: navigator.hardwareConcurrency
        },
        window: {
            innerWidth: window.innerWidth,
            innerHeight: window.innerHeight,
            outerWidth: window.outerWidth,
            outerHeight: window.outerHeight
        },
        location: {
            href: window.location.href,
            hostname: window.location.hostname,
            pathname: window.location.pathname,
            protocol: window.location.protocol,
            referrer: document.referrer
        },
        performance: {
            navigation: {
                type: performance.navigation?.type,
                redirectCount: performance.navigation?.redirectCount
            },
            timing: performance.timing ? {
                loadEventEnd: performance.timing.loadEventEnd,
                loadEventStart: performance.timing.loadEventStart,
                domComplete: performance.timing.domComplete,
                domInteractive: performance.timing.domInteractive,
                domContentLoadedEventEnd: performance.timing.domContentLoadedEventEnd
            } : null
        }
    });
</script>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4" transition:animation onintroend={() => emailInput?.focus()}>

    <div class="text-center md:text-left md:order-2">
        <h2 class="text-2xl font-bold">Login now!</h2>
        <p class="py-6">
            Provident cupiditate voluptatem et in. Quaerat fugiat ut assumenda excepturi exercitationem
            quasi. In deleniti eaque aut repudiandae et a id nisi.
        </p>
    </div>

    <div class="card bg-base-100 max-w-sm shadow-xl md:order-1 justify-self-center">
        <div class="card-body">
            <div class="form-control">
                <label class="label pb-0.75" class:text-error={emailMsg} for="email">
                    <span class="label-text">{emailMsg ?? "Email"}</span>
                </label>
                <label class="input input-bordered flex items-center gap-2" class:input-error={emailMsg} class:input-primary={!emailMsg}>
                    <Mail size="16" class="h-4 w-4 opacity-70" />
                    <input id="email" type="email" placeholder="email" class="grow" bind:this={emailInput} disabled={working} />
                </label>
            </div>
            <div class="form-control">
                <label class="label pb-0.75" class:text-error={passwordMsg} for="password">
                    <span class="label-text">{passwordMsg ?? "Password"}</span>
                </label>
                <label class="input input-bordered flex items-center gap-2" class:input-error={passwordMsg} class:input-primary={!passwordMsg}>
                    <Key size="16" class="h-4 w-4 opacity-70" />
                    <input id="password" type="password" placeholder="password" class="grow" bind:this={passwordInput} disabled={working} />
                </label>
                <div class="mt-4">
                    <a href="/forgot" class="link link-hover">Forgot password?</a>
                </div>
            </div>
            {#if success == false}
            <div class="text-error mt-1 flex items-center">
                <Alert size="16" class="h-4 w-4 opacity-70" />
                <span class="ml-2">Invalid Email Or Password</span>
            </div>
            {/if}
            <button class="btn btn-primary mt-1" onclick={login} aria-label="Login" disabled={working}>
                {#if working}
                    <span class="loading loading-bars loading-xs"></span>
                {:else}
                    Login
                {/if}
            </button>
        </div>
    </div>

</div>

<style lang="scss">
</style>