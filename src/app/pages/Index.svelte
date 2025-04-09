<script lang="ts">
    import user from "$lib/user";
    import Unsigned from "../part/Unsigned.svelte";
    import Home from "../part/Home.svelte";
    import Toast from "$lib/Toast.svelte";
</script>

{#if $user == null}
<Unsigned />
{:else}
<Home />
{/if}

<Toast />

<style lang="scss">
</style>