<script lang="ts">
    import Layout from "$part/Layout.svelte";
    import Drawer from "$part/Drawer.svelte";
    
    // let tasks = [
    //     { id: 1, text: "Example task to showcase the interface", completed: false },
    //     { id: 2, text: "Click the checkbox to mark a task as completed", completed: true },
    //     { id: 3, text: "Use the edit button to modify a task", completed: false }
    // ];

    // let newTaskText = "";
    // let editingTask = null;
    // let editText = "";

    // function addTask() {
    //     if (newTaskText.trim()) {
    //         tasks = [...tasks, { 
    //             id: Math.max(0, ...tasks.map(t => t.id)) + 1, 
    //             text: newTaskText, 
    //             completed: false 
    //         }];
    //         newTaskText = "";
    //     }
    // }

    // function deleteTask(id) {
    //     tasks = tasks.filter(task => task.id !== id);
    // }

    // function toggleComplete(id) {
    //     tasks = tasks.map(task => 
    //         task.id === id ? {...task, completed: !task.completed} : task
    //     );
    // }

    // function startEditing(task) {
    //     editingTask = task.id;
    //     editText = task.text;
    // }

    // function saveEdit() {
    //     if (editText.trim()) {
    //         tasks = tasks.map(task => 
    //             task.id === editingTask ? {...task, text: editText} : task
    //         );
    //     }
    //     editingTask = null;
    // }

    // function cancelEdit() {
    //     editingTask = null;
    // }
</script>

<Layout>
    {#snippet navStart()}
        <h1 class="text-2xl font-bold">Welcome to the Todo App</h1>
    {/snippet}
    
    <p class="mb-4">This is a simple todo app built with Svelte and Tailwind CSS.</p>
    <p class="mb-4">You can add, edit, and delete tasks.</p>
    <p class="mb-4">Click the button below to get started!</p>
    <button class="btn btn-primary">
        Get Started
    </button>
    
    {#snippet drawer()}
        <Drawer />
    {/snippet}
</Layout>

<style lang="scss">
</style>