<script>
	// Bridge the global App show/hide lifecycle onto the uni event bus so the
	// ring plugin (@trtc/call-ring-wx) can rebuild+resume ring playback when
	// the mini program returns to the foreground. App.onShow / App.onHide are
	// the only lifecycle hooks guaranteed to fire under uni-app + WeChat mini
	// program; wx.onAppShow/onHide are not reliably mapped here. The event
	// name strings are the shared contract with CALL_RING_EVENTS — keep them
	// in sync with TUIKit/states/TUICallService/const/call.ts.
	const CALL_RING_APP_SHOW = 'callRing:appShow';
	const CALL_RING_APP_HIDE = 'callRing:appHide';

	export default {
		onLaunch: function() {
			console.log('App Launch')
		},
		onShow: function() {
			console.log('App Show')
			uni.$emit(CALL_RING_APP_SHOW)
		},
		onHide: function() {
			console.log('App Hide')
			uni.$emit(CALL_RING_APP_HIDE)
		}
	}
</script>

<style>
	/*每个页面公共css */
</style>
