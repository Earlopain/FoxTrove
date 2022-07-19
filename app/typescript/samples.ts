export default class Samples {
  private static currentActive: Element | undefined;

  public static init() {
    for (const thumbnail of document.querySelectorAll(".submission-file")) {
      thumbnail.addEventListener("click", () => {
        if (this.currentActive && thumbnail.isSameNode(this.currentActive)) {
          this.removeCurrentActive();
        } else {
          this.hideLarge(this.currentActive);
          this.currentActive = thumbnail;
          this.showLarge(thumbnail);
          thumbnail.nextElementSibling?.addEventListener("click", () => {
            this.removeCurrentActive();
          }, { once: true });
        }
      });
    }
  }

  private static showLarge(thumbnail: Element) {
    thumbnail.classList.add("active-thumbnail");
    thumbnail.nextElementSibling?.classList.remove("hidden");
  }

  private static hideLarge(thumbnail?: Element) {
    thumbnail?.classList.remove("active-thumbnail");
    thumbnail?.nextElementSibling?.classList.add("hidden");
  }

  private static removeCurrentActive() {
    this.hideLarge(this.currentActive);
    this.currentActive = undefined;
  }
}
