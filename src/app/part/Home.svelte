<script lang="ts">
    import TodosIcon from "lucide-svelte/icons/circle-check-big";
    import CategoriesIcon from "lucide-svelte/icons/layout-list";
    import UserIcon from "lucide-svelte/icons/circle-user-round";
    import SimpleUserIcon from "lucide-svelte/icons/user";
    import SettingsIcon from "lucide-svelte/icons/settings";

    import user from "$lib/user";
    import VsCodeLayout from "$lib/VsCodeLayout.svelte"
    import { ENVIRONMENT, BUILD_ID, APP_ID } from "../api/env";

    const statusRight = [ENVIRONMENT, BUILD_ID, APP_ID];
</script>


{#snippet userStatus()}
    <div class="bg-green-800">
        <SimpleUserIcon size={14} class="mr-2" />
        {$user?.name}
        [{$user?.roles.toString()}]
    </div>
{/snippet}

{#snippet sidebars()}
    <!-- {#if id === "users"}
        <p>Users sidebar content for {id}</p>
    {:else if id === "logs"}
        <p>Logs sidebar content for {id}</p>
    {:else if id === "settings"}
        <p>Settings sidebar content for {id}</p>
    {/if} -->
{/snippet}

{#snippet contents()}
    <!-- {#if id === "users"}
        <p>Users content for {id}</p>
    {:else if id === "logs"}
        <p>Logs content for {id}</p>
    {:else if id === "settings"}
        <p>Settings content for {id}</p>
    {/if} -->
{/snippet}

<VsCodeLayout panels={[
    {
        id: "todo",
        button: TodosIcon,
        sidebar: sidebars,
        content: contents,
        statusLeft: [userStatus, "Todos Editor"],
        statusRight: statusRight
    }, {
        id: "category",
        button: CategoriesIcon,
        sidebar: sidebars,
        content: contents,
        statusLeft: [userStatus, "Categories Editor"],
        statusRight: statusRight
    }, {
        id: "user",
        button: UserIcon,
        buttonPosition: "bottom",
        sidebar: sidebars,
        content: contents,
        statusLeft: [userStatus, "Logged User Management"],
        statusRight: statusRight
    }, {
        id: "settings",
        button: SettingsIcon,
        buttonPosition: "bottom",
        sidebar: sidebars,
        content: contents,
        statusLeft: [userStatus, "Settings"],
        statusRight: statusRight
    },
]} />

<style lang="scss">
</style>