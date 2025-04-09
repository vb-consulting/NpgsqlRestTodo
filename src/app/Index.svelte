<script lang="ts">
    import user from "$lib/user";
    import Unsigned from "$part/Unsigned.svelte";
    import Toast from "$lib/Toast.svelte";
</script>

{#if $user == null}
<Unsigned />
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