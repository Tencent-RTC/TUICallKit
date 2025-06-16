<script>
export default {
  onLaunch: function () {
    console.log("App Launch");
    let isActive = true;
    uni.onAppShow(() => {
      isActive = true;
    });
    uni.onAppHide(() => {
      isActive = false;
    });

    uni.$appIsActive = () => isActive;
  },
  onShow: function () {
    console.log("App Show");
  },
  onHide: function () {
    console.log("App Hide");
  },
};
</script>

<style>
</style>
