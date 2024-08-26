<template>
  <div class="card">
    <slot />
  </div>
</template>

<style lang="scss" scoped>
.card {
  width: auto;
  height: 40px;
  padding: 0 24px;
  
  display: inline-flex;
  justify-content: center;
  align-items: center;
  gap: 0 4px;
  background: #FFFFFF;
  box-shadow: 0px 3px 8px #E9F0FB;
  border-radius: 20px;
  
  cursor: pointer;
  font-weight: 500;
  font-size: 14px;
  color: #4F586B;
}
</style>
