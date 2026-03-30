<template>
  <div>
    <h2>Bestall-nuxt - Simulerar primo</h2>

    Bestall stödjer tre inloggningsmetoder:

    <ul>
      <li>GU-inloggning</li>
      <li>Koha (bibliotekskortnummer, pin-kod)</li>
      <li>GitHub (för devel)</li>
    </ul>

    <table>
      <thead>
        <tr>
          <th>Typ</th>
          <th>Id</th>
          <th>Title</th>
          <th>Description</th>
          <th>View</th>
          <th>Language</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="link in links" :key="link.id">
          <td>{{ link.type }}</td>
          <td>
            <NuxtLink
              :to="
                $localePath({
                  path: `/${link.id}`,
                  query: link.query,
                  replace: true,
                })
              "
              >{{ link.id }}</NuxtLink
            >
          </td>
          <td>{{ link.title }}</td>
          <td>{{ link.desc }}</td>
          <td>{{ link.query.view }}</td>
          <td>{{ link.query.language }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
const runtimeConfig = useRuntimeConfig();
const localePath = useLocalePath();

useHead({
  title: "Bestall-nuxt - Simulerar primo",
});

const languages = ["swe", "eng"];
const views = ["46GUB_KOHA", "46GUB_VU1"];
const data = [
  {
    books: [
      {
        id: 1063720,
        title: "Forskningsmetodikens grunder",
        desc: "Beskrivning av vad du testar med denna bok.",
      },
      {
        id: 8503,
        title:
          "Katalog der kroatischen, polnischen und tschechischen Handschriften der Österreichischen Nationalbibliothek",
        desc: "Beskrivning av vad du testar med denna bok.",
      },
    ],
    subscription: [
      {
        id: 189763,
        title:
          "Befolkningsförändringar. Del 1, Församlingar, kommuner och A-regioner",
        desc: "Beskrivning av vad du testar med denna prenumeration.",
      },
      {
        id: 176500,
        title: "Fornvännen (Print)",
        desc: "Beskrivning av vad du testar med denna prenumeration.",
      },
      {
        id: 178300,
        title: "Scientific American (Print)",
        desc: "Beskrivning av vad du testar med denna prenumeration.",
      },
      {
        id: 752187,
        title: "Högskoleboken",
        desc: "Bara ref.",
      },
    ],
    collection: [
      {
        id: 2756053,
        title: "Collection",
        desc: "Beskrivning av vad du testar med denna collection.",
      },
      {
        id: 2682798,
        title: "Hasselblads fotografiska AB - samling av trycksaker",
        desc: "Saknar exemplar",
      },
    ],
  },
];

const links = computed(() => {
  const links = [];
  for (const item of data) {
    for (const book of item.books) {
      for (const language of languages) {
        for (const view of views) {
          links.push({
            id: book.id,
            title: book.title,
            desc: book.desc,
            type: "book",
            query: { view, language },
          });
        }
      }
    }
    for (const subscription of item.subscription) {
      for (const language of languages) {
        for (const view of views) {
          links.push({
            id: subscription.id,
            title: subscription.title,
            desc: subscription.desc,
            type: "subscription",
            query: { view, language },
          });
        }
      }
    }
    for (const collection of item.collection) {
      for (const language of languages) {
        for (const view of views) {
          links.push({
            id: collection.id,
            title: collection.title,
            desc: collection.desc,
            type: "collection",
            query: { view, language },
          });
        }
      }
    }
  }
  return links;
});
</script>

<style scoped>
table {
  border-collapse: collapse;
  width: 100%;
  tr {
    border: 1px solid black;
  }
  td,
  th {
    border: 1px solid black;
    padding: 1rem;
  }
}
</style>
