<script setup lang="ts"></script>
<template>
  <div>
    <div class="hero">
      <header>
        <div class="hero-header h1">This is the hero component</div>
      </header>
      <main class="content">
        <p>
          This is the hero main content area. It can contain text, images,
          videos or other types of content. The hero component is used to
          highlight important information or calls to action on the page.
        </p>
        <p>
          Use the hero component to create a visually appealing and engaging
          section that captures the attention of users and encourages them to
          explore further.
        </p>
      </main>
      <aside class="hero-sidebar">
        <div class="hero-sidebar-heading">Directly to</div>
        <ul>
          <li><a href="#">Gothenburg University</a></li>
          <li><a href="#">Koha</a></li>
          <li><a href="#">Databases</a></li>
          <li><a href="#">Somewhere along the way</a></li>
          <li><a href="#">Sometime</a></li>
        </ul>
      </aside>
      <footer class="hero-footer">
        <button type="button" class="btn-link">Call to action »</button>
      </footer>
    </div>
  </div>
</template>

<style scoped>
@import url("~/assets/css/hero.css");
</style>
