<script lang="ts">
    import user from "$lib/user";
    import LoginPanel from "$part/LoginPanel.svelte";
    import Toast from "$lib/Toast.svelte";
    let showLogin = $state(false);
</script>

{#if $user == null}
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
                    Learn To Build Entire Backend Only With PostgreSQL (ALMOST)
                </span>
            </h1>
            <div class="my-6 flex justify-center gap-4">
                {#if showLogin}
                    <LoginPanel />
                {:else}
                    <button class="btn btn-info btn-square btn-wide" onclick={() => showLogin = true}>Get Started</button>
                    <a href="/learnmore" class="btn btn-info btn-outline">Learn More</a>
                {/if}
            </div>
        </div>
    </div>
</div>
{:else}
<div class="card bg-base-100 shadow-xl">
    <div class="card-body">
        <div class="join w-full">
            <input type="text" placeholder="Add a new task..." class="input input-bordered join-item flex-1" />
            <button class="btn btn-primary btn-outline join-item">Add Task</button>
        </div>
        <div class="divider"></div>
        <div class="space-y-4">
            <div class="flex items-center">
                <input type="checkbox" class="checkbox checkbox-primary" />
                <span class="ml-3">Example task to showcase the interface</span>
            </div>
        </div>
    </div>
</div>
{/if}

<Toast removeAfterMs={0} />

<style lang="scss">
</style>