<script lang="ts">
    import Layout from "$part/Layout.svelte";
    import Drawer from "$part/Drawer.svelte";
    import Toast from "$lib/Toast.svelte";
    import LogOut from "lucide-svelte/icons/log-out";
    import { authLogout } from "$api/authApi";
    import getAnalytics from "$lib/analyticsData";
    import api from "$lib/api";

    import user from "$lib/user";

    if (!$user) {
        window.location.href = "/";
    }
    
    function logout() {
        api(() => authLogout({
            analytics: JSON.stringify(getAnalytics())
        })).then(() => {
            $user = null;
            window.location.href = "/";
        })
    }
</script>

<Layout>
    {#snippet navStart()}
        <h1 class="text-2xl font-bold">User profile</h1>
    {/snippet}

    profile section


    <div class="mt-10">
        <button class="btn" onclick={logout}>
            <LogOut size={16} />
            Logout
        </button>
    </div>

    {#snippet drawer()}
        <ul>
            <li><a href="/">Home</a></li>
        </ul>
        <div class="divider"></div>
        <Drawer />
    {/snippet}
</Layout>

<Toast removeAfterMs={0} />

<style lang="scss">
</style>