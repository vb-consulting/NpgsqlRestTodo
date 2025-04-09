<script lang="ts" generics="T extends string">
    import { onMount, type Snippet, type Component } from "svelte";
    import{ loadFromStorage, saveToStorage } from "$lib/storage";

    let { 
        panels = [], 
        autoHideTreshold = 170,
        undockThreshold = 30,
        mobileThreshold = 500,
        keyPrefix,
        activePanel = $bindable(),
        sidebarVisible = $bindable()
    } : { 
        panels: {
            id: T, 
            title?: string,
            button: Snippet<[T]> | Component | any,
            buttonPosition?: "top" | "bottom",
            sidebar: Snippet<[T]>,
            sidebarTitle?: string | Snippet<[T]>,
            content: Snippet<[T]>
            statusLeft?: (string | Snippet<[StatusArg<T>]>)[],
            statusRight?: (string | Snippet<[StatusArg<T>]>)[],
        }[],
        autoHideTreshold?: number,
        undockThreshold?: number,
        mobileThreshold?: number,
        keyPrefix?: string,
        activePanel?: T,
        sidebarVisible?: boolean
    } = $props();

    // Initialize from props or fallback to localStorage
    if (activePanel === undefined) {
        const loadedActivePanel = loadFromStorage('activePanel', panels[0].id, keyPrefix);
        activePanel = panels.find(p => p.id === loadedActivePanel) ? loadedActivePanel : panels[0].id;
    }
    
    if (sidebarVisible === undefined) {
        sidebarVisible = loadFromStorage('sidebarVisible', true, keyPrefix);
    }
    let sidebarWidth = $state(loadFromStorage('sidebarWidth', 300, keyPrefix));
    let isMobile = $state(false);
    
    // Reactive effects to save state to localStorage
    $effect(() => {
        saveToStorage('activePanel', activePanel, keyPrefix);
    });
    
    $effect(() => {
        saveToStorage('sidebarVisible', sidebarVisible, keyPrefix);
    });
    
    $effect(() => {
        saveToStorage('sidebarWidth', sidebarWidth);
    });
    
    // Resizing state
    let isResizing = $state(false);
    let currentSidebar: HTMLElement | null = null;
    let startX = 0;
    let startWidth = 0;
        
    function switchPanel(panel: T) {
        const isCurrentlyActive = activePanel === panel;
        
        // If clicking the already active button, toggle sidebar visibility
        if (isCurrentlyActive) {
            sidebarVisible = !sidebarVisible;
            return;
        }
        
        // Switch to the new panel (width remains the same)
        activePanel = panel;
        
        // Show sidebar if it was hidden
        if (!sidebarVisible) {
            sidebarVisible = true;
        }
    }
    
    function checkMobile() {
        if (typeof window !== 'undefined') {
            isMobile = window.innerWidth < mobileThreshold;
        }
    }

    function initResize(e: MouseEvent) {
        if (!(e.target instanceof HTMLElement) || isMobile) return;
        
        isResizing = true;
        currentSidebar = e.target.parentElement;
        startX = e.clientX;
        startWidth = currentSidebar ? parseInt(getComputedStyle(currentSidebar).width, 10) : 0;
        
        // Add dragging class for visual feedback
        e.target.classList.add("dragging");
        
        // Prevent text selection during drag
        document.body.style.userSelect = "none";
        document.body.style.cursor = "col-resize";
        
        document.addEventListener("mousemove", doResize);
        document.addEventListener("mouseup", stopResize);
    }
    
    function doResize(e: MouseEvent) {
        if (!isResizing || !currentSidebar) return;
        
        const width = startWidth + e.clientX - startX;
        
        // Check if dragging too close to the left edge (auto-hide)
        if (width < autoHideTreshold) {
            sidebarVisible = false;
            stopResize();
            return;
        }
        
        // Constrain width within min/max bounds
        const constrainedWidth = Math.max(200, Math.min(600, width));
        
        currentSidebar.style.width = constrainedWidth + "px";
        sidebarWidth = constrainedWidth;
    }
    
    function stopResize() {
        isResizing = false;
        
        // Remove dragging class
        document.querySelectorAll(".resize-handle").forEach(handle => {
            handle.classList.remove("dragging");
        });
        
        // Restore normal cursor and text selection
        document.body.style.userSelect = "";
        document.body.style.cursor = "";
        
        currentSidebar = null;
        
        document.removeEventListener("mousemove", doResize);
        document.removeEventListener("mouseup", stopResize);
    }
    
    function initUndock(e: Event) {
        const mouseEvent = e as MouseEvent;
        if (sidebarVisible || isMobile) return;
        
        // Immediately start resize mode from hidden position
        isResizing = true;
        startX = mouseEvent.clientX;
        startWidth = 0; // Starting from hidden (width 0)
        currentSidebar = document.querySelector(".sidebar") as HTMLElement;
        
        let hasShownSidebar = false;
        
        if (mouseEvent.target instanceof HTMLElement) {
            mouseEvent.target.classList.add("dragging");
        }
        
        document.body.style.userSelect = "none";
        document.body.style.cursor = "col-resize";
        
        // Custom resize handler for undock that shows sidebar after threshold
        function handleUndockResize(e: MouseEvent) {
            const dragDistance = e.clientX - startX;
            
            // Show sidebar once threshold is reached
            if (!hasShownSidebar && dragDistance > undockThreshold) {
                hasShownSidebar = true;
                sidebarVisible = true;
            }
            
            // If sidebar is visible, resize it
            if (hasShownSidebar && sidebarVisible) {
                // Check if dragging too close to the left edge (auto-hide/dock)
                if (dragDistance < autoHideTreshold) {
                    sidebarVisible = false;
                    hasShownSidebar = false; // Allow re-undocking
                    return;
                }
                
                const width = Math.max(200, Math.min(600, dragDistance));
                if (currentSidebar) {
                    currentSidebar.style.width = width + "px";
                }
                sidebarWidth = width;
            }
        }
        
        function handleUndockEnd() {
            isResizing = false;
            
            document.body.style.userSelect = "";
            document.body.style.cursor = "";
            
            if (mouseEvent.target instanceof HTMLElement) {
                mouseEvent.target.classList.remove("dragging");
            }
            
            currentSidebar = null;
            
            document.removeEventListener("mousemove", handleUndockResize);
            document.removeEventListener("mouseup", handleUndockEnd);
        }
        
        document.addEventListener("mousemove", handleUndockResize);
        document.addEventListener("mouseup", handleUndockEnd);
    }

    function isSnippet(prop: Snippet<[T]> | Component): prop is Snippet<[T]> {
        return typeof prop === 'function' && 
            '$' in prop &&
            typeof prop.$ === 'object';
    }
    
    // doUndock and stopUndock functions removed - now handled by doResize/stopResize directly
    
    onMount(() => {
        // Set up activity bar edge for undocking when sidebar is hidden
        const activityBarEdge = document.querySelector(".activity-bar-edge");
        if (activityBarEdge) {
            activityBarEdge.addEventListener("mousedown", initUndock);
        }
        
        // Initialize mobile detection
        checkMobile();
        
        // Listen for window resize to update mobile state
        function handleResize() {
            checkMobile();
        }
        
        window.addEventListener('resize', handleResize);
        
        // Cleanup
        return () => {
            window.removeEventListener('resize', handleResize);
        };
    });
</script>

<div class="vscode-container" class:mobile={isMobile}>
    <div class="vscode-main">
        <!-- Activity Bar -->
        <div class="activity-bar bg-base-300">
            <div class="activity-bar-edge" style="pointer-events: {sidebarVisible || isMobile ? "none" : "auto"}; opacity: {sidebarVisible || isMobile ? "0" : "1"}"></div>
                <div class="activity-bar-top">
                    {#each panels as panel (panel.id)}
                        {#if panel?.buttonPosition !== "bottom"}
                        <button 
                            class="activity-btn" 
                            class:active={activePanel === panel.id}
                            class:sidebar-hidden={activePanel === panel.id && !sidebarVisible}
                            onclick={() => switchPanel(panel.id)} 
                            title={panel.title || panel.id.charAt(0).toUpperCase() + panel.id.slice(1)}
                        >
                            {#if isSnippet(panel.button)}
                                {@render panel.button?.(panel.id)}
                            {:else}
                                <panel.button />
                            {/if}
                        </button>
                        {/if}
                    {/each}
                </div>
                <div class="activity-bar-bottom">
                    {#each panels as panel (panel.id)}
                        {#if panel?.buttonPosition === "bottom"}
                        <button 
                            class="activity-btn" 
                            class:active={activePanel === panel.id}
                            class:sidebar-hidden={activePanel === panel.id && !sidebarVisible}
                            onclick={() => switchPanel(panel.id)} 
                            title={panel.title || panel.id.charAt(0).toUpperCase() + panel.id.slice(1)}
                        >
                            {#if isSnippet(panel.button)}
                                {@render panel.button?.(panel.id)}
                            {:else}
                                <panel.button />
                            {/if}
                        </button>
                        {/if}
                    {/each}
                </div>
        </div>

        <!-- Sidebar Container -->
        <div class="sidebar-container bg-base-200 sidebar-right-shadow" class:collapsed={!sidebarVisible}>
            {#each panels as panel (panel.id)}
                {#if activePanel === panel.id && sidebarVisible}
                <div id="{panel.id}-sidebar" class="sidebar" style="width: {sidebarWidth}px;">
                    <!-- svelte-ignore a11y_no_static_element_interactions -->
                    <div class="resize-handle" onmousedown={initResize}></div>
                    <div class="sidebar-header bg-base-100">
                        {panel.sidebarTitle ? typeof panel.sidebarTitle === "string" ? panel.sidebarTitle : panel.sidebarTitle?.(panel.id) : panel.title || panel.id.charAt(0).toUpperCase() + panel.id.slice(1)}
                    </div>
                    <div class="sidebar-content">
                        {@render panel.sidebar?.(panel.id)}
                    </div>
                </div>
                {/if}
            {/each}
        </div>

        <!-- Main Editor Area -->
        {#if !(sidebarVisible && isMobile)}
        <div class="main-editor">
            {#each panels as panel (panel.id)}
                {#if activePanel === panel.id}
                {@render panel.content?.(panel.id)}
                {/if}
            {/each}
        </div>
        {/if}
    </div>

    <!-- Status Bar -->
    <div class="status-bar">
        {#each panels as panel (panel.id)}
            {#if activePanel === panel.id}
            <div class="status-left">
                {#each panel.statusLeft || [] as item, index}
                    {#if typeof item === "string"}
                        <span>{item}</span>
                    {:else if typeof item === "function"}
                        {@render item?.({id: panel.id, position: "left", index})}
                    {/if}
                {/each}
            </div>
            <div class="status-right">
                {#each panel.statusRight || [] as item, index}
                    {#if typeof item === "string"}
                        <span>{item}</span>
                    {:else if typeof item === "function"}
                        {@render item?.({id: panel.id, position: "right", index})}
                    {/if}
                {/each}
            </div>
            {/if}
        {/each}
    </div>
</div>

<style lang="scss">
    // DaisyUI semantic colors mapped for VS Code layout
    $vs-bg-primary: oklch(var(--b1));           // Main editor background
    $vs-bg-secondary: oklch(var(--b2));         // Sidebar background  
    $vs-bg-tertiary: oklch(var(--b3));          // Sidebar header background
    $vs-activity-bar-bg: oklch(var(--n));       // Activity bar (darker/neutral)
    $vs-status-bar-bg: oklch(var(--n));         // Status bar (same as activity bar)
    $vs-splitter-bg: oklch(var(--bc) / 0.3);    // Splitter (semi-transparent border)
    $vs-text-primary: oklch(var(--bc));
    $vs-text-secondary: oklch(var(--nc));
    $vs-text-muted: oklch(var(--nc) / 0.6);
    $vs-border: oklch(var(--b3));
    $vs-primary: oklch(var(--p));
    $vs-primary-content: oklch(var(--pc));
    $vs-primary-hover: oklch(var(--p) / 0.1);

    // Layout dimensions
    $vs-activity-bar-width: 48px;
    $vs-sidebar-default-width: 300px;
    $vs-sidebar-min-width: 200px;
    $vs-sidebar-max-width: 600px;
    $vs-status-bar-height: 22px;
    $vs-resize-handle-width: 4px;
    $vs-activity-btn-size: 32px;

    // Spacing
    $vs-spacing-xs: 2px;
    $vs-spacing-sm: 4px;
    $vs-spacing-md: 6px;
    $vs-spacing-lg: 8px;
    $vs-spacing-xl: 12px;
    $vs-spacing-xxl: 16px;
    $vs-spacing-xxxl: 20px;

    // Border and radius
    $vs-border-width: 2px;
    $vs-border-radius: 3px;
    $vs-border-radius-md: 4px;
    $vs-active-indicator-width: 3px;
    
    // VS Code specific colors (non-themeable)
    $vs-status-bar-bg: #007ACC;
    $vs-status-bar-color: white;
    $vs-splitter-hover-bg: #007ACC;
    $vs-active-indicator-color: var(--color-info);
    
    // Opacity values
    $vs-activity-btn-inactive-opacity: 0.6;
    $vs-activity-btn-active-opacity: 1;

    // Font sizes
    $vs-font-xs: 11px;
    $vs-font-sm: 12px;
    $vs-font-base: 13px;
    $vs-font-lg: 24px;

    // Z-index
    $vs-z-resize-handle: 10;
    $vs-z-activity-edge: 15;

    :global(html),
    :global(body) {
        height: 100vh;
        margin: 0;
        padding: 0;
        overflow: hidden;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe WPC", "Segoe UI", system-ui, "Ubuntu", "Droid Sans", sans-serif;
        font-size: $vs-font-base;
    }

    .vscode-container {
        height: 100vh;
        display: flex;
        flex-direction: column;
    }
    
    .vscode-container.mobile {
        overflow: hidden;
    }

    .vscode-main {
        flex: 1;
        display: flex;
        overflow: hidden;
    }

    :global(.activity-bar) {
        width: $vs-activity-bar-width;
        border-right: $vs-border-width solid $vs-border;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: center;
        padding: $vs-spacing-lg 0;
        position: relative;
    }
    
    .mobile :global(.activity-bar) {
        height: calc(100vh - $vs-status-bar-height);
        position: fixed;
        left: 0;
        top: 0;
        z-index: 999;
    }

    .activity-bar-top {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: $vs-spacing-sm;
    }

    .activity-bar-bottom {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: $vs-spacing-sm;
    }

    .activity-bar-edge {
        position: absolute;
        top: 0;
        right: -2px;
        width: $vs-resize-handle-width;
        height: 100%;
        cursor: col-resize;
        background: transparent;
        z-index: $vs-z-activity-edge;
        opacity: 0;
        pointer-events: none;
    }

    .activity-bar-edge:hover {
        background: $vs-primary;
        opacity: 1;
    }

    .activity-btn {
        width: $vs-activity-btn-size;
        height: $vs-activity-btn-size;
        margin: $vs-spacing-sm 0;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        border: none;
        border-radius: $vs-border-radius-md;
        color: $vs-text-secondary;
        cursor: pointer;
        transition: all 0.2s;
        opacity: $vs-activity-btn-inactive-opacity;
        position: relative;
    }

    .activity-btn:hover {
        background: $vs-bg-tertiary;
        color: $vs-text-primary;
        opacity: $vs-activity-btn-active-opacity;
    }

    .activity-btn.active {
        color: $vs-text-primary;
        position: relative;
        opacity: $vs-activity-btn-active-opacity;
    }
    
    .activity-btn.active::before {
        content: '';
        position: absolute;
        left: -#{$vs-spacing-lg};
        top: -#{$vs-spacing-sm};
        width: $vs-active-indicator-width;
        height: calc(100% + #{$vs-spacing-sm * 2});
        background: $vs-active-indicator-color;
        opacity: $vs-activity-btn-active-opacity;
        border-radius: 0 1px 1px 0;
    }
    
    .activity-btn.sidebar-hidden {
        color: $vs-text-secondary;
        position: relative;
        opacity: 0.7;
    }
    
    .activity-btn.sidebar-hidden::before {
        content: '';
        position: absolute;
        left: -#{$vs-spacing-lg};
        top: -#{$vs-spacing-sm};
        width: $vs-active-indicator-width;
        height: calc(100% + #{$vs-spacing-sm * 2});
        background: $vs-active-indicator-color;
        opacity: $vs-activity-btn-inactive-opacity;
        border-radius: 0 1px 1px 0;
    }
    
    .activity-btn.sidebar-hidden:hover {
        color: $vs-text-primary;
        opacity: 1;
    }
    
    .activity-btn.sidebar-hidden:hover::before {
        background: $vs-active-indicator-color;
        opacity: $vs-activity-btn-active-opacity;
    }

    .sidebar {
        width: $vs-sidebar-default-width;
        min-width: $vs-sidebar-min-width;
        max-width: $vs-sidebar-max-width;
        background: $vs-bg-primary;
        border-right: $vs-border-width solid $vs-border;
        display: flex;
        flex-direction: column;
        position: relative;
    }
    
    .mobile .sidebar {
        position: fixed;
        top: 0;
        left: $vs-activity-bar-width;
        width: calc(100vw - $vs-activity-bar-width) !important;
        height: 100vh;
        z-index: 1000;
        border-right: none;
        min-width: calc(100vw - $vs-activity-bar-width);
        max-width: calc(100vw - $vs-activity-bar-width);
    }
    
    .mobile .status-bar {
        position: fixed;
        bottom: 0;
        left: 0;
        width: 100vw !important;
        z-index: 1001;
    }


    .resize-handle {
        position: absolute;
        top: 0;
        right: -2px;
        width: $vs-resize-handle-width;
        height: 100%;
        cursor: col-resize;
        background: transparent;
        z-index: $vs-z-resize-handle;
    }
    
    .mobile .resize-handle {
        display: none;
    }
    
    /* Disable hover states in mobile mode for immediate dimming */
    .mobile .activity-btn:hover {
        background: transparent;
        color: $vs-text-secondary;
        opacity: $vs-activity-btn-inactive-opacity;
    }
    
    .mobile .activity-btn.active:hover {
        background: transparent;
        color: $vs-text-primary;
        opacity: $vs-activity-btn-active-opacity;
    }
    
    .mobile .activity-btn.sidebar-hidden:hover {
        background: transparent;
        color: $vs-text-secondary;
        opacity: $vs-activity-btn-inactive-opacity;
    }
    
    .mobile .activity-btn.sidebar-hidden:hover::before {
        opacity: $vs-activity-btn-inactive-opacity;
    }
    
    /* Fix main editor positioning in mobile mode to account for fixed activity bar */
    .mobile .main-editor {
        margin-left: $vs-activity-bar-width;
        width: calc(100% - $vs-activity-bar-width);
    }
    

    .resize-handle:hover {
        background: $vs-splitter-hover-bg;
    }

    .sidebar-container {
        display: flex;
        position: relative;
    }

    .sidebar-container.collapsed {
        width: 0;
    }

    .sidebar-container.collapsed .sidebar {
        display: none;
    }
    
    .sidebar-right-shadow {
        box-shadow: 4px 0 12px 0 rgba(0, 0, 0, 0.3);
    }

    .sidebar-header {
        padding: $vs-spacing-lg $vs-spacing-xxl;
        font-size: $vs-font-xs;
        font-weight: bold;
        text-transform: uppercase;
    }

    .sidebar-content {
        flex: 1;
        overflow-y: auto;
        padding: $vs-spacing-lg;
    }

    .main-editor {
        flex: 1;
        background: $vs-bg-primary;
        display: flex;
        flex-direction: column;
        padding: $vs-spacing-xxxl;
        color: $vs-text-primary;
        overflow-y: auto;
    }

    .status-bar {
        height: $vs-status-bar-height;
        background: $vs-status-bar-bg;
        color: $vs-status-bar-color;
        display: flex;
        align-items: center;
        font-size: $vs-font-sm;
        user-select: none;
        overflow: hidden;
        white-space: nowrap;
        position: relative;
    }

    .status-left {
        height: 100%;
        display: flex;
        position: relative;
        z-index: 2;
        background: $vs-primary;
        flex-shrink: 0;
    }

    .status-right {
        height: 100%;
        display: flex;
        position: absolute;
        right: 0;
        top: 0;
        z-index: 1;
        max-width: 100%;
        overflow: hidden;
    }

    .status-left > *,
    .status-left > :global(*),
    .status-right > *,
    .status-right > :global(*) {
        padding: 0 $vs-spacing-lg;
        display: flex;
        height: 100%;
        align-items: center;
        white-space: nowrap;
        flex-shrink: 0;
    }


</style>