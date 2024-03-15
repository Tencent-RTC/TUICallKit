import { onMounted, onUnmounted, unref, type Ref } from 'vue';
import { useListenEvent } from './useListenerEvent';
import { noop } from '@/utils';

/**
* @function 监听点击目标元素外的事件
* @description 给某个元素添加该监听事件，实现点击该元素区域外触发回调
* @param {Ref<HTMLElement | undefined>} 需要监听的元素
* @param {Function} 事件触发的回调函数
* @return {void}
* @example
*   const elRef = ref();
*   useOnClickOutSide(elRef, () => {console.log('click outside')}]);
*/
export function useOnClickOutSide(targetEl: Ref<HTMLElement | undefined>, handler: () => any) {
  let stop = noop;

  onMounted(() => {
    const target = unref(targetEl);

    if (!target) {
      console.warn('target is empty');
      return;
    }

    const listener = (event: Event) => {
      const paths = event.composedPath();

      if (paths.includes(target)) {
        return;
      }
      handler();
    };
    stop = useListenEvent('click', listener, { passive: true });
  });

  onUnmounted(() => {
    stop();
  });
}
