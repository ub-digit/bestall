<script setup lang="ts"></script>
<template>
  <div>
    <section class="typography-section">
      <h2># Typography</h2>
      <div class="font-samples">
        <div class="font-family-group">
          <div class="font-sample open-sans-regular">
            <h3 class="open-sans-regular">Open Sans Regular</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
          <div class="font-sample open-sans-italic">
            <h3 class="open-sans-italic">Open Sans Italic</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
          <div class="font-sample open-sans-bold">
            <h3 class="open-sans-bold">Open Sans Bold</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
        </div>
        <div class="font-family-group">
          <div class="font-sample tex-gyre-heros-bold">
            <h3 class="tex-gyre-heros-bold">Tex Gyre Heros Bold</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
          <div class="font-sample tex-gyre-heros-cn-regular">
            <h3 class="tex-gyre-heros-cn-regular">Tex Gyre Heros CN Regular</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
          <div class="font-sample tex-gyre-heros-cn-bold">
            <h3 class="tex-gyre-heros-cn-bold">Tex Gyre Heros CN Bold</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
          <div class="font-sample tex-gyre-heros-cn-italic">
            <h3 class="tex-gyre-heros-cn-italic">Tex Gyre Heros CN Italic</h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
          <div class="font-sample tex-gyre-heros-cn-bold-italic">
            <h3 class="tex-gyre-heros-cn-bold-italic">
              Tex Gyre Heros CN Bold Italic
            </h3>
            <p>
              The quick brown fox jumps over the lazy dog.
              ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789
            </p>
          </div>
        </div>

        <div class="heading-samples">
          <h1>Heading 1</h1>
          <h2>Heading 2</h2>
          <h3>Heading 3</h3>
          <h4>Heading 4</h4>
          <h5>Heading 5</h5>
          <h6>Heading 6</h6>
        </div>

        <div class="link-samples">
          <ul>
            <li>
              <a class="arrow-after" href="#">Foo to Bar</a>
              (with arrow-after class)
            </li>
            <li><a href="#">Bar to Foo</a></li>
          </ul>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.typography-section {
  .font-samples {
    font-size: 1rem;
    display: flex;
    flex-direction: column;

    .font-family-group {
      display: flex;
      flex-direction: column;
      margin-bottom: var(--spacer-32);
      .font-sample {
        > h3 {
          margin-bottom: var(--spacer-16);
        }
      }
    }
  }
  .link-samples {
    ul {
      list-style: none;
      padding: 0;
      li {
        margin-bottom: 0.5rem;
      }
    }
  }
}
</style>
