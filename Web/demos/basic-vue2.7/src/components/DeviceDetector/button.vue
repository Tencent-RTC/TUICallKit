<template>
  <button type="button" @click="onClick" :class="['button', type, className]">
    <slot></slot>
  </button>
</template>

<script>
export default {
  name: 'Button',
  props: {
    type: String,
    onClick: {
      type: Function,
      default: () => {},
    },
    className: String,
  },
};
</script>

<style scoped>
.button {
  padding: 6px 16px;
  border-radius: 4px;
  border: 0;
  outline: none;
  background-color: transparent;
  user-select: none;
  font-size: 0.875rem;
  min-width: 64px;
  box-sizing: border-box;
  font-weight: 500;
  line-height: 1.75;
  transition: background-color 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms,
    box-shadow 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms,
    border 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;
}
.outlined {
  padding: 5px 15px;
  border: 1px solid #006eff;
  color: #006eff;
  cursor: pointer;
}
.contained {
  cursor: pointer;
  color: #ffffff;
  background-color: #006eff;
  box-shadow: 0px 3px 1px -2px rgb(0 0 0 / 20%), 0px 2px 2px 0px rgb(0 0 0 / 14%), 0px 1px 5px 0px rgb(0 0 0 / 12%);
}
.disabled {
  box-shadow: none;
  color: rgba(0, 0, 0, 0.26);
  background-color: rgba(0, 0, 0, 0.12);
}
</style>
