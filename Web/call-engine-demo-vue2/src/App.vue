<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <div id="app">
    <div class="container">
      <RouterView />
    </div>
  </div>
</template>

<style scoped>
html {
  height: 100vh;
  font-size: 1vw;
}
body,#app{
  height: 100vh;
}
#app {
  display: flex;
  width: 100%;
}
.container {
  display: flex;
  width: 100vw;
  margin: 0 auto;
  padding: 0 11rem;
  justify-content: space-between;
}
@media screen and (max-width: 1600px) {
  .container {
    padding: 0 3rem;
  }
}

@media screen and (max-width: 1200px) {
  .container {
    padding: 0 1rem;
  }
}
@media screen and (max-width: 900px) {
  .container {
    padding: 0 0;
  }
}
</style>
