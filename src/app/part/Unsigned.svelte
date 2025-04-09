<script lang="ts">
    import LoginPanel from "./LoginPanel.svelte";
    let showLogin = $state(false);
    // svelte-ignore non_reactive_update
    let panel = document.location.search.slice(1) as "login"|"register"|"forgot";
    if (panel == "login" || panel == "register" || panel == "forgot") {
        showLogin = true;
    }
</script>

<div class="min-h-screen bg-base-300 hero">
    <div class="hero-content text-center">
        <div class="max-w-3xl">
            <h1 class="text-5xl font-bold">
                <span class="text-info">Todo App</span>
                <div class="avatar">
                    <div class="w-9">
                        <img src="favicon.ico" alt="PostgreSQL" />
                    </div>
                </div>
                <span class="text-3xl mt-3 block">
                    Learn To Build Entire Backend Only With PostgreSQL
                </span>
            </h1>
            <div class="my-6 flex justify-center gap-4">
                {#if showLogin}
                    <LoginPanel {panel} />
                {:else}
                    <button class="btn btn-info btn-square btn-wide" onclick={() => {
                        showLogin = true; 
                        panel = "login";
                    }}>Get Started</button>
                    <a href="/learnmore" class="btn btn-info btn-outline">Learn More</a>
                {/if}
            </div>
        </div>
    </div>
</div>

<style lang="scss">
</style>