<template>
  <div class="tabbed">
    <nav class="tabbed-nav" @click.prevent="handleNavClick">
      <slot name="tabbedNav">
        <p class="muted">No tabs provided</p>
      </slot>
    </nav>

    <div class="tabbed-content">
      <slot name="tabbedContent">
        <p class="muted">No tab content provided</p>
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
const activeTab: number | null = ref(null);
const slots = useSlots();
console.log("Available slots:", Object.keys(slots));
const nav = computed(() => (slots["tabbedNav"] ? slots["tabbedNav"]() : []));
const content = ref(slots["tabbedContent"] ? slots["tabbedContent"]() : []);

console.log("Nav slot content:", nav.value);
console.log("Content slot content:", content.value);

watch(
  activeTab,
  (newVal) => {
    //reset all content to hidden
    document.querySelectorAll(".tabbed-content > *").forEach((item, index) => {
      (item as HTMLElement).style.display = "none";
    });
    // then show the active tab content
    const contentItems = document.querySelectorAll(".tabbed-content > *");
    contentItems.forEach((item, index) => {
      (item as HTMLElement).style.display = index === newVal ? "block" : "none";
    });
    // add active class to active tab
    document.querySelectorAll(".tabbed-nav > *").forEach((item, index) => {
      if (index === newVal) {
        (item as HTMLElement).classList.add("active");
      } else {
        (item as HTMLElement).classList.remove("active");
      }
    });
  },
  {
    immediate: true,
  },
);
activeTab.value = 0; // Default to the first tab

const handleNavClick = (event: Event) => {
  const target = event.target as HTMLElement;
  if (target.tagName === "A" || target.tagName === "BUTTON") {
    const index = Array.from(target.parentElement?.children || []).indexOf(
      target,
    );
    if (index >= 0) activeTab.value = index;
  }
};
</script>

<style>
/* Component styles here */
.tabbed {
  --border-color-default: var(--light-dark);
  .tabbed-content {
    padding: var(--spacer-16) 0;
  }
  display: flex;
  flex-direction: column;
  .tabbed-nav {
    display: flex;

    border-bottom: 1px solid var(--border-color-default);
    a {
      background-color: var(--light-light);
      border-top: 1px;
      border-left: 1px;
      border-right: 1px;
      border-bottom: 0;
      border-style: solid;
      border-color: var(--border-color-default);
      padding: var(--spacer-8) var(--spacer-16);
      &:nth-child(even) {
        border-left: 0;
      }
      &.active {
        background-color: var(--dark-base);
        color: white;
      }
    }
  }
}
</style>
