<script setup lang="ts"></script>
<template>
  <section class="responsiveness-section">
    <h2># Responsivness</h2>
    <!-- ### Gets filled with JS -->
    <div class="document-width"></div>
    <div class="breakpoint-info"></div>
    <p class="note">
      <strong>Note:</strong> The breakpoints are defined in the CSS file
      vars.css as CSS custom properties. The problem with CSS custom properties
      is that they cannot be used in media queries. Therefore, these are only
      for reference and cannot be used directly in media queries. When using
      media queries, use the actual values.
    </p>
    <ul>
      <li>Default: 0rem and up</li>
      <li>Medium breakpoint: 48rem and up</li>
      <li>Large breakpoint: 64rem and up</li>
      <li>Max width is 75rem;</li>
    </ul>

    <code>
      @media (min-width: 48rem) {} <br />
      @media (min-width: 64rem) {} <br />
    </code>
  </section>
</template>

<style scoped></style>
