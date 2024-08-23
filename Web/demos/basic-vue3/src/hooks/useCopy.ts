import useMessage from "./useMessage";

export default function useCopy() {
  const { showMessage } = useMessage();

  const copyText = (textToCopy: string) => {
    navigator.clipboard.writeText(textToCopy)
    .then(() => {
      showMessage({
        message: 'copy succeed',
        type: 'success'
      })
    })
    .catch((error) => {
      console.error('copy fail:', error);
    });
  };

  return {
    copyText,
  };
}
