<template>
  <singleCall
    v-if="!isGroupCall"
    :call-role="callRole"
    :call-status="callStatus"
    :media-type="mediaType"
  />
  <groupCall
    v-else
    :call-role="callRole"
    :call-status="callStatus"
    :media-type="mediaType"
  />
</template>

<script setup lang="ts">
import { onMounted, ref, toRefs, watch, defineProps } from "vue";
import {
  MediaType,
  CallStatus,
  CallRole,
} from "../../callServices/const/index";
import singleCall from "./singleCall.vue";
import groupCall from "./groupCall.vue";

const props = defineProps({
  callStatus: {
    type: CallStatus,
    default: CallStatus.IDLE,
  },
  mediaType: {
    type: MediaType,
    default: MediaType.UNKNOWN,
  },
  callRole: {
    type: CallRole,
    default: CallRole.UNKNOWN,
  },
  isGroupCall: {
    type: Boolean,
    default: false,
  },
});
</script>

<style></style>
