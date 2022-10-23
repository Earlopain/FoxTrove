import ClickMode from "./click_mode";

export default class Samples {
  private static currentActive: Element | undefined;

  public static init() {
    for (const thumbnail of ClickMode.getAllElements()) {
      thumbnail.addEventListener("click", () => {
        if(ClickMode.isDisabled(this)) {
          return;
        }

        if (this.currentActive && thumbnail.isSameNode(this.currentActive)) {
          this.reset();
        } else {
          this.hideLarge(this.currentActive);
          this.currentActive = thumbnail;
          this.showLarge(thumbnail);
          thumbnail.nextElementSibling?.addEventListener("click", () => {
            this.reset();
          }, { once: true });
        }
      });
    }
  }

  private static showLarge(thumbnail: Element) {
    thumbnail.classList.add("selected");
    thumbnail.nextElementSibling?.classList.remove("hidden");
    if (thumbnail.nextElementSibling instanceof HTMLVideoElement) {
      thumbnail.nextElementSibling.currentTime = 0;
      thumbnail.nextElementSibling.play();
    }
  }

  private static hideLarge(thumbnail?: Element) {
    thumbnail?.classList.remove("selected");
    thumbnail?.nextElementSibling?.classList.add("hidden");
    if (thumbnail?.nextElementSibling instanceof HTMLVideoElement) {
      thumbnail.nextElementSibling.pause();
    }
  }

  public static reset() {
    this.hideLarge(this.currentActive);
    this.currentActive = undefined;
  }
}
