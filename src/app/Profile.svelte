<script lang="ts">
    import Layout from "$part/Layout.svelte";
    import Drawer from "$part/Drawer.svelte";
    import Toast from "$lib/Toast.svelte";
    import user from "$lib/user";

    if (!$user) {
        window.location.href = "/";
    }
    
    // import LogOut from "lucide-svelte/icons/log-out";
    // import { authLogout } from "$api/authApi";
    // import getAnalyticsData from "$lib/analyticsData";
    // import api from "$lib/api";
    // function logout() {
    //     api(() => authLogout({
    //         analyticsData: JSON.stringify(getAnalyticsData())
    //     })).then(() => {
    //         $user = null;
    //         window.location.href = "/";
    //     })
    // }
</script>

<Layout>
    {#snippet navStart()}
        <h1 class="text-2xl font-bold">User profile</h1>
    {/snippet}

    profile section

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