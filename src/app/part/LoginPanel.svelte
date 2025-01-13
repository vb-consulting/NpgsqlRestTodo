<script lang="ts">
    import { fade } from "svelte/transition";
    import Login from "$lib/Login.svelte";
    import Register from "$lib/Register.svelte";

    let panel: "login"|"register"|"forgot" = $state("login");

    let wrapper: HTMLElement;
    function introEnd() {
        // focus first input after animation
        const input = wrapper.querySelector("input[type='email']") as HTMLInputElement;
        if (input) {
            input.focus();
            input.select();
        }
    }
</script>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4" bind:this={wrapper} transition:fade onintroend={introEnd}>

    <div class="text-center md:text-left md:order-2">
        <h2 class="text-2xl font-bold">Login now!</h2>
        <div class="py-2">
            if you are a new user, please register first. If you are an existing user, please login to access your account.
            <div class="divider"></div>
            {#if panel == "login"}
                Don't have an account? 
                <div class="mt-2">
                    <button class="btn btn-soft btn-info" onclick={() => panel = "register"}>Register Here</button>
                </div>
            {:else if panel == "register" || panel == "forgot"}
                Already have an account?
                <div class="mt-2">
                    <button class="btn btn-soft btn-info" onclick={() => panel = "login"}>Login Here</button>
                </div>
            {/if}
            <div class="divider"></div>
            <div>
                <button class="btn btn-soft btn-info" onclick={() => { }}>Continue With Google</button>
                <button class="btn btn-soft btn-info" onclick={() => { }}>Continue With LinkedIn</button>
            </div>
        </div>
    </div>

    <div class="card bg-base-100 max-w-sm shadow-xl md:order-1 justify-self-center">
        <div class="card-body">
        {#if panel == "login"}
            <div in:fade onintroend={introEnd}>
                <Login />
                <div class="mt-1">
                    <button class="btn btn-link" onclick={() => panel = "forgot"}>Forgot Password?</button>
                </div>
            </div>
        {:else if panel == "register"}
            <div in:fade onintroend={introEnd}><Register returnToLogin={() => panel="login"} /></div>
        {:else if panel == "forgot"}
            <div in:fade onintroend={introEnd}>Reset</div>
        {/if}
        </div>
    </div>

</div>

<style lang="scss">
</style>