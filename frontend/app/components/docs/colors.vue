<script setup lang="ts"></script>
<template>
  <div>
    <section class="color-palette-section">
      <h2># Colors</h2>
      <div class="color-palette-samples">
        <div class="color-palette-samples-item">
          <div class="color-swatch light-light"></div>
          <div class="color-swatch light-base"></div>
          <div class="color-swatch light-dark"></div>
        </div>
        <div class="color-palette-samples-item">
          <div class="color-swatch dark-light"></div>
          <div class="color-swatch dark-base"></div>
          <div class="color-swatch dark-dark"></div>
        </div>
        <div class="color-palette-samples-item">
          <div class="color-swatch brand-light"></div>
          <div class="color-swatch brand-base"></div>
          <div class="color-swatch brand-dark"></div>
        </div>
        <div class="color-palette-samples-item">
          <div class="color-swatch success-light"></div>
          <div class="color-swatch success-base"></div>
          <div class="color-swatch success-dark"></div>
        </div>
        <div class="color-palette-samples-item">
          <div class="color-swatch danger-light"></div>
          <div class="color-swatch danger-base"></div>
          <div class="color-swatch danger-dark"></div>
        </div>
        <div class="color-palette-samples-item">
          <div class="color-swatch warning-light"></div>
          <div class="color-swatch warning-base"></div>
          <div class="color-swatch warning-dark"></div>
        </div>
        <div class="color-palette-samples-item">
          <div class="color-swatch info-light"></div>
          <div class="color-swatch info-base"></div>
          <div class="color-swatch info-dark"></div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.color-palette-section {
  .color-palette-samples {
    display: grid;
    /*
        Defines the column structure for a CSS grid layout.
        - Uses 'auto-fit' to automatically fit as many columns as possible in the container.
        - Each column has a minimum width of 6rem and will expand to fill available space (maximum of 1fr).
        - Ensures responsive grid behavior across different screen sizes.
    */
    grid-template-columns: repeat(auto-fit, minmax(6rem, 1fr));
    gap: 1rem;
    margin-top: 1rem;
    .color-palette-samples-item {
      @media (min-width: 48rem) {
      }
      border: 1px solid var(--dark-light);
      .color-swatch {
        height: 40px;
      }
    }
  }
}
</style>
