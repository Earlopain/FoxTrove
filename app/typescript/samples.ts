export default class Samples {
  private currentActive: Element | undefined;

  public constructor() {
    for (const thumbnail of document.querySelectorAll(".submission-file")) {
      thumbnail.addEventListener("click", () => {
        if (thumbnail.isSameNode(this.currentActive)) {
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

  private showLarge(thumbnail: Element) {
    thumbnail.classList.add("active-thumbnail");
    thumbnail.nextElementSibling?.classList.remove("hidden");
  }

  private hideLarge(thumbnail?: Element) {
    thumbnail?.classList.remove("active-thumbnail");
    thumbnail?.nextElementSibling?.classList.add("hidden");
  }

  private removeCurrentActive() {
    this.hideLarge(this.currentActive);
    this.currentActive = undefined;
  }
}
