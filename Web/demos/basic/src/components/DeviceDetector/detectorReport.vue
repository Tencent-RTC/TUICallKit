<template>
  <div class="device-testing-report">
    <div class="testing-title">检测报告</div>
    <div class="device-report-list">
        <div class="device-report">
          <div class="device-info">
            <span class="report-icon">
              <!-- 摄像头图标 -->
              <svg t="1630397874793" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="958" width="24" height="24"><path d="M489.244444 0a460.8 460.8 0 1 1 0 921.6A460.8 460.8 0 0 1 489.244444 0z m0 204.8a256 256 0 1 0 0 512 256 256 0 0 0 0-512z" fill="#47494D" opacity=".8" p-id="959"></path><path d="M489.244444 460.8m-153.6 0a153.6 153.6 0 1 0 307.2 0 153.6 153.6 0 1 0-307.2 0Z" fill="#47494D" opacity=".8" p-id="960"></path><path d="M120.604444 952.32a368.64 61.44 0 1 0 737.28 0 368.64 61.44 0 1 0-737.28 0Z" fill="#47494D" opacity=".8" p-id="961"></path></svg>
            </span>
            <div class="device-name">{{ reportData.camera.result }}</div>
          </div>
          <div :class="[reportData.camera.type === 'success' ? 'green' : 'red']">
            {{reportData.camera.type === 'success' ? '正常' : '异常'}}
          </div>
        </div>
        <div class="device-report">
          <div class="device-info">
            <span class="report-icon">
              <!-- 麦克风图标 -->
              <svg t="1630397938861" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1205" width="24" height="24"><path d="M841.551448 434.423172A41.666207 41.666207 0 0 1 882.758621 476.548414c0 194.701241-144.454621 355.469241-329.551449 376.514207v86.722207h164.758069a41.666207 41.666207 0 0 1 41.207173 42.089931A41.666207 41.666207 0 0 1 717.965241 1024H306.034759A41.666207 41.666207 0 0 1 264.827586 981.874759a41.666207 41.666207 0 0 1 41.207173-42.089931h164.758069v-86.722207C285.696 832.052966 141.241379 671.249655 141.241379 476.548414a41.666207 41.666207 0 0 1 41.207173-42.125242 41.666207 41.666207 0 0 1 41.171862 42.125242c0 162.78069 129.129931 294.770759 288.379586 294.770758l8.827586-0.141241c155.153655-4.766897 279.552-134.850207 279.552-294.629517a41.666207 41.666207 0 0 1 41.171862-42.125242zM512 0c119.419586 0 216.275862 88.770207 216.275862 198.232276v317.228138c0 106.990345-92.513103 194.206897-208.154483 198.091034l-8.121379 0.141242c-119.419586 0-216.275862-88.770207-216.275862-198.232276V198.232276c0-106.990345 92.513103-194.206897 208.154483-198.091035L512 0z" fill="#47494D" opacity=".8" p-id="1206"></path></svg>
            </span>
            <div class="device-name">{{ reportData.microphone.result }}</div>
          </div>
          <div :class="[reportData.microphone.type === 'success' ? 'green' : 'red']">
            {{ reportData.microphone.type === 'success' ? '正常' : '异常' }}
          </div>
        </div>
         <div v-if="reportData.speaker" class="device-report">
          <div class="device-info">
            <span class="report-icon">
              <!-- 扬声器图标 -->
              <svg t="1629186923749" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="2923" width="24" height="24"><path d="M640 181.333333c0-46.037333-54.357333-70.4-88.746667-39.850666L359.552 311.850667a32 32 0 0 1-21.248 8.106666H181.333333A96 96 0 0 0 85.333333 415.957333v191.872a96 96 0 0 0 96 96h157.013334a32 32 0 0 1 21.248 8.106667l191.616 170.410667c34.389333 30.549333 88.789333 6.144 88.789333-39.850667V181.333333z m170.325333 70.272a32 32 0 0 1 44.757334 6.698667A424.917333 424.917333 0 0 1 938.666667 512a424.96 424.96 0 0 1-83.626667 253.696 32 32 0 0 1-51.413333-38.058667A360.917333 360.917333 0 0 0 874.666667 512a360.917333 360.917333 0 0 0-71.04-215.637333 32 32 0 0 1 6.698666-44.757334zM731.434667 357.12a32 32 0 0 1 43.392 12.928c22.869333 42.24 35.84 90.666667 35.84 141.994667a297.514667 297.514667 0 0 1-35.84 141.994666 32 32 0 0 1-56.32-30.464c17.92-33.152 28.16-71.082667 28.16-111.530666s-10.24-78.378667-28.16-111.530667a32 32 0 0 1 12.928-43.392z" fill="#47494D" opacity=".8" p-id="2924"></path></svg>
            </span>
            <div class="device-name">{{ reportData.speaker.result }}</div>
          </div>
          <div :class="[reportData.speaker.type === 'success' ? 'green' : 'red']">
            {{ reportData.speaker.type === 'success' ? '正常' : '异常' }}
          </div>
        </div>
        <div v-if="reportData.network" class="device-report">
          <div class="device-info">
            <span class="report-icon">
              <!-- 网络图标 -->
              <svg t="1630400570252" class="icon" viewBox="0 0 1291 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1640" width="24" height="24"><path d="M992.211478 583.68A449.758609 449.758609 0 0 0 650.017391 426.295652c-136.904348 0-259.561739 61.039304-342.194087 157.384348a90.156522 90.156522 0 0 0 136.859826 117.359304 269.846261 269.846261 0 0 1 205.334261-94.430608c82.142609 0 155.737043 36.641391 205.334261 94.386087a90.156522 90.156522 0 1 0 136.859826-117.359305zM559.86087 922.134261a90.156522 90.156522 0 1 0 180.313043 0 90.156522 90.156522 0 0 0-180.313043 0z" fill="#47494D" opacity=".8" p-id="1641"></path><path d="M1253.064348 289.124174A809.316174 809.316174 0 0 0 650.017391 20.613565a809.316174 809.316174 0 0 0-603.046956 268.466087 90.156522 90.156522 0 1 0 127.777391 127.065044l0.311652 0.26713A629.581913 629.581913 0 0 1 650.017391 200.926609c189.395478 0 359.290435 83.389217 474.957913 215.485217l0.267131-0.26713a90.156522 90.156522 0 1 0 127.777391-127.065044z" fill="#47494D" opacity=".8" p-id="1642"></path></svg>
            </span>
            <div class="device-name">网络延时</div>
          </div>
          <div :class="[reportData.network.result.rtt <= 200 ? 'green' : 'red']">
            {{ `${reportData.network.result.rtt}ms` }}
          </div>
        </div>
        <div v-if="reportData.network" class="device-report">
          <div class="device-info">
            <span class="report-icon">
              <!-- 网络图标 -->
              <svg t="1630400570252" class="icon" viewBox="0 0 1291 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1640" width="24" height="24"><path d="M992.211478 583.68A449.758609 449.758609 0 0 0 650.017391 426.295652c-136.904348 0-259.561739 61.039304-342.194087 157.384348a90.156522 90.156522 0 0 0 136.859826 117.359304 269.846261 269.846261 0 0 1 205.334261-94.430608c82.142609 0 155.737043 36.641391 205.334261 94.386087a90.156522 90.156522 0 1 0 136.859826-117.359305zM559.86087 922.134261a90.156522 90.156522 0 1 0 180.313043 0 90.156522 90.156522 0 0 0-180.313043 0z" fill="#47494D" opacity=".8" p-id="1641"></path><path d="M1253.064348 289.124174A809.316174 809.316174 0 0 0 650.017391 20.613565a809.316174 809.316174 0 0 0-603.046956 268.466087 90.156522 90.156522 0 1 0 127.777391 127.065044l0.311652 0.26713A629.581913 629.581913 0 0 1 650.017391 200.926609c189.395478 0 359.290435 83.389217 474.957913 215.485217l0.267131-0.26713a90.156522 90.156522 0 1 0 127.777391-127.065044z" fill="#47494D" opacity=".8" p-id="1642"></path></svg>
            </span>
            <div class="device-name">上行网络质量</div>
          </div>
          <div :class="[goodUplinkQuality ? 'green' : 'red']">
              {{ NETWORK_QUALITY[reportData.network.result.uplinkQuality] }}
          </div>
        </div>
        <div v-if="reportData.network" class="device-report">
          <div class="device-info">
            <span class="report-icon">
              <!-- 网络图标 -->
              <svg t="1630400570252" class="icon" viewBox="0 0 1291 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1640" width="24" height="24"><path d="M992.211478 583.68A449.758609 449.758609 0 0 0 650.017391 426.295652c-136.904348 0-259.561739 61.039304-342.194087 157.384348a90.156522 90.156522 0 0 0 136.859826 117.359304 269.846261 269.846261 0 0 1 205.334261-94.430608c82.142609 0 155.737043 36.641391 205.334261 94.386087a90.156522 90.156522 0 1 0 136.859826-117.359305zM559.86087 922.134261a90.156522 90.156522 0 1 0 180.313043 0 90.156522 90.156522 0 0 0-180.313043 0z" fill="#47494D" opacity=".8" p-id="1641"></path><path d="M1253.064348 289.124174A809.316174 809.316174 0 0 0 650.017391 20.613565a809.316174 809.316174 0 0 0-603.046956 268.466087 90.156522 90.156522 0 1 0 127.777391 127.065044l0.311652 0.26713A629.581913 629.581913 0 0 1 650.017391 200.926609c189.395478 0 359.290435 83.389217 474.957913 215.485217l0.267131-0.26713a90.156522 90.156522 0 1 0 127.777391-127.065044z" fill="#47494D" opacity=".8" p-id="1642"></path></svg>
            </span>
            <div class="device-name">下行网络质量</div>
          </div>
          <div :class="[goodDownlinkQuality ? 'green' : 'red']">
            {{ NETWORK_QUALITY[reportData.network.result.downlinkQuality] }}
          </div>
        </div>
    </div>
    <div class="device-report-footer">
      <Button type="outlined" :onClick="handleReset">重新检测</Button>
      <Button type="contained" :onClick="handleClose">完成检测</Button>
    </div>
  </div>
</template>

<script>
import { NETWORK_QUALITY } from './utils.js';
import Button from './button.vue';
export default {
  name: 'detectorReport',
  props: {
    reportData: Object,
    handleReset: Function,
    handleClose: Function,
  },
  components: {
    Button,
  },
  data() {
    return {
      NETWORK_QUALITY,
    };
  },
  computed: {
    goodUplinkQuality() {
      return this.reportData.network.result.uplinkQuality > 0 && this.reportData.network.result.uplinkQuality < 4;
    },
    goodDownlinkQuality() {
      return this.reportData.network.result.downlinkQuality > 0 && this.reportData.network.result.downlinkQuality < 4;
    },
  },
  methods: {

  },
};
</script>

<style lang="scss" src="./index.scss" scoped>
</style>
