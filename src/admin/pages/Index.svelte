<script lang="ts">
    import Users from "lucide-svelte/icons/users";
    import Logs from "lucide-svelte/icons/logs";
    import Settings from "lucide-svelte/icons/settings";

    import VsCodeLayout from "$lib/VsCodeLayout.svelte"
    import { ENVIRONMENT, BUILD_ID, APP_ID } from "../api/env";

    type Panel = "users" | "logs" | "settings";
    const statusRight = [ENVIRONMENT, BUILD_ID, APP_ID];
</script>

{#snippet buttons(id: Panel)}
    {#if id === "users"}
        <Users />
    {:else if id === "logs"}
        <Logs />
    {:else if id === "settings"}
        <Settings />
    {/if}
{/snippet}

{#snippet sidebars(id: string)}
    {#if id === "users"}
        <p>Users sidebar content for {id}</p>
    {:else if id === "logs"}
        <p>Logs sidebar content for {id}</p>
    {:else if id === "settings"}
        <p>Settings sidebar content for {id}</p>
    {/if}
{/snippet}

{#snippet contents(id: string)}
    {#if id === "users"}
        <p>Users content for {id}</p>
    {:else if id === "logs"}
        <p>Logs content for {id}</p>
    {:else if id === "settings"}
        <p>Settings content for {id}</p>
    {/if}
{/snippet}


<VsCodeLayout panels={[
    {
        id: "users",
        button: buttons,
        sidebar: sidebars,
        content: contents,
        statusLeft: ["User Management"],
        statusRight: statusRight
    },
    {
        id: "logs",
        button: buttons,
        sidebar: sidebars,
        content: contents,
        statusLeft: ["Log Management"],
        statusRight: statusRight
    },
    {
        id: "settings",
        button: buttons,
        buttonPosition: "bottom",
        sidebar: sidebars,
        content: contents,
        statusLeft: ["Settings Management"],
        statusRight: statusRight
    }
]} />

<style lang="scss">
</style>