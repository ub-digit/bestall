<script setup lang="ts"></script>
<template>
  <div>
    <div class="navigation-grid">
      <nav id="main-nav" aria-label="Main navigation">
        <ul>
          <li>
            <a href="#top"
              ><span
                ><svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="16"
                  height="16"
                  viewBox="0 0 16 16"
                >
                  <!-- Icon from OpenSearch UI by OpenSearch Contributors - https://github.com/opensearch-project/oui/blob/main/LICENSE.txt -->
                  <path
                    fill="#888888"
                    d="m8.13 1.229l5.5 4.47a1 1 0 0 1 .37.777V14a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V6.476a1 1 0 0 1 .37-.776l5.5-4.471a1 1 0 0 1 1.26 0M13 6.476L7.5 2.005L2 6.475V14h11z"
                  /></svg></span
              >Home</a
            >
          </li>
          <li><a href="#responsivness">Responsivness</a></li>
          <li><a href="#colors">Colors</a></li>
          <li><a href="#typography">Typography</a></li>
          <li><a href="#buttons">Buttons</a></li>
          <li><a href="#logotypes">Logotypes</a></li>
          <li><a href="#icons">Icons</a></li>
        </ul>
      </nav>
    </div>
  </div>
</template>

<style scoped>
/* ##### Navigation Layout ##### */
.navigation-grid {
  display: grid;
  grid-template-columns: 1fr;
  grid-template-areas:
    "nav-toggle"
    "nav";
  @media (min-width: 48rem) {
    grid-template-columns: 1fr auto;
    grid-template-areas: "nav nav-toggle";
  }
  nav {
    grid-area: nav;
  }
  .nav-toggle {
    grid-area: nav-toggle;
  }
}

.navigation-grid {
  nav {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    ul {
      list-style: none;
      padding: 0;
      margin: 0;
      display: flex;
      justify-content: flex-start;
      flex-direction: column;
      gap: 1rem;
      font-size: 1.25rem;
      font-weight: bold;
      white-space: nowrap;

      @media (min-width: 48rem) {
        flex-direction: row;
        align-items: center;
        min-height: 2.5rem;
        border-bottom: none;
        flex-wrap: nowrap;
      }
      li a svg {
        display: none;
      }
      li {
        @media (min-width: 48rem) {
          &:hover {
          }
          &:first-child {
            svg {
              display: inline-block;
              margin-right: 0.5rem;
            }
          }
        }

        a {
          display: block;
          text-decoration: none;
          color: var(--bg-color-text);
        }
        a:hover {
          text-decoration: underline;
          color: oklch(from var(--brand-color) l c h);
        }
      }
    }
  }
  .nav-toggle {
    display: flex;
    justify-content: flex-end;
    padding: 0.6rem 0;
    margin: 0;
    button {
      svg:nth-of-type(2) {
        display: none;
      }
      &[aria-expanded="true"] {
        svg:nth-of-type(1) {
          display: none;
        }
        svg:nth-of-type(2) {
          display: inline-block;
        }
      }
      padding: 0.5rem 1rem;
      border: none;
      background: none;
      font-size: 1.25rem;
      font-weight: bold;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      &:hover {
        text-decoration: underline;
      }
    }
  }
}
</style>
