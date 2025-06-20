<script lang="ts">
    import user from "$lib/user";
    import type { Snippet } from "svelte";

    let { children, drawer, navStart } : { children: Snippet, drawer?: Snippet, navStart?: Snippet } = $props();
    
    const menuLinks = [
        { name: "Home", path: "/" },
        { name: "Profile", path: "/profile/" },
        { name: "Settings", path: "/settings/" }
    ];
</script>

{#snippet avatarBtn(end: boolean = true)}
<div class="dropdown dropdown-end" class:dropdown-end={end}>
    <div tabindex="-1" role="button" class="btn btn-ghost btn-circle avatar">
        <div class="w-10 rounded-full bg-primary text-primary-content grid place-items-center avatar-title">
            {$user?.name ? $user?.name.split("@")[0] : "guest"}
        </div>
    </div>
    <ul tabindex="-1" class="menu dropdown-content w-30 p-4 bg-base-300 shadow-lg">
        {#each menuLinks as { name, path }}
        {#if path !== document.location.pathname}
        <li><a href={path}>{name}</a></li>
        {/if}
        {/each}
    </ul>
</div>
{/snippet}

<div class="drawer lg:drawer-open h-screen">
    <input id="drawer" type="checkbox" class="drawer-toggle" />
    <div class="drawer-content flex flex-col min-h-screen"> 

        <div class="navbar">
            <div class="navbar-start w-full">
                <label for="drawer" class="btn btn-square btn-ghost lg:hidden">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-5 h-5 stroke-current">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                    </svg>
                </label>
                {#if navStart}
                    <div class="ps-4">
                        {@render navStart()}
                    </div>
                {/if}
            </div>
            <div class="navbar-end w-fit">
                {@render avatarBtn()}
            </div>
        </div>
        
        <main class="flex-grow container p-6">
            {@render children?.()}
        </main>

        <footer class="footer footer-horizontal footer-center bg-base-200 text-base-content rounded p-10 mt-auto">
            <div>
                <p>
                    Created with <a href="https://vb-consulting.github.io/npgsqlrest/" class="link link-primary font-semibold" target="_blank">NpgsqlRest</a>
                    <span class="px-2">•</span>
                    <a href="https://github.com/vbilopav/NpgsqlRestTodo" class="link link-primary" target="_blank">View on GitHub</a>
                </p>
                <p class="text-xs opacity-70 mt-1">PostgreSQL RESTful API with Todo App Demo</p>
            </div>
        </footer>
    </div>

    <div class="drawer-side shadow-base-300 shadow-lgm min-h-max">
        <label for="drawer" aria-label="close sidebar" class="drawer-overlay"></label> 
        <div class="menu p-4 w-60 min-h-full bg-base-200 text-base-content">

            <div class="max-w-full overflow-hidden">
                <div class="flex items-center gap-2 px-4">
                    {@render avatarBtn(false)}
                    <div class="user-info-container">
                        <p class="font-bold">{$user?.name}</p>
                        <p class="text-xs opacity-70">{$user?.roles}</p>
                    </div>
                </div>
                <div class="divider"></div>
                {@render drawer?.()}
            </div>

            <!-- <div class="mt-auto">
                <button class="btn w-full" onclick={logout}>
                    <LogOut size={16} />
                    Logout
                </button>
            </div> -->
        </div>
    </div>
</div>

<style lang="scss">
    .avatar-title {
        font-size: .6rem;
        line-height: 3.75;
        text-overflow: ellipsis;
        padding-left: 0.2rem;
        padding-right: 0.2rem;
    }
    .user-info-container {
        display: grid;
        & > * {
            overflow: hidden;
            text-overflow: ellipsis;
            min-width: 0;
        }
    }
</style>