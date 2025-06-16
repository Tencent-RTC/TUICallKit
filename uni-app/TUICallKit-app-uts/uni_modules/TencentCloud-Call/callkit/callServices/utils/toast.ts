import { NAME } from "../const";

class Toast {
  position: String;

  constructor() {
    this.position = "center";
  }

  public show(text: string) {
    uni.showToast({
      title: text,
      position: this.position,
      success: () => {
        console.log(`${NAME.PREFIX} showToast success`);
      },
      fail: () => {
        console.log(`${NAME.PREFIX} showToast fail`);
      },
      complete: () => {
        console.log(`${NAME.PREFIX} showToast complete`);
      },
    });
  }
}

export const toast = new Toast();
