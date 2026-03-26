<script setup lang="ts"></script>
<template>
  <section class="buttons-section">
    <h2># Buttons</h2>
    <div class="button-samples">
      <div class="button-sample">
        <button type="button" class="btn-primary">Button Primary</button>
      </div>
      <div class="button-sample">
        <button type="button" class="btn-secondary">Button Secondary</button>
      </div>
      <div class="button-sample">
        <button type="button" class="btn-light">Button Light</button>
      </div>

      <div class="button-sample">
        <button type="button" class="btn-primary" disabled>
          Button Primary Disabled
        </button>
      </div>
      <div class="button-sample">
        <div class="button-sample">
          <button type="button" class="btn-link">Button Link</button>
        </div>
      </div>
      <div class="button-sample">
        <div class="button-sample">
          <button type="button" disabled class="btn-link">Button Link</button>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.buttons-section .button-samples {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 1rem;
}
</style>
