export default class Samples {
  public static init() {
    let currentActive: Element | undefined;
    for (const thumbnail of document.querySelectorAll(".submission-file")) {
      thumbnail.addEventListener("click", () => {
        this.show(currentActive);
        currentActive = thumbnail;
        this.hide(thumbnail);
        thumbnail.nextElementSibling?.addEventListener("click", () => {
          this.show(thumbnail);
        }, { once: true });
      });
    }
  }

  private static hide(thumbnail: Element) {
    thumbnail.classList.add("active-thumbnail");
    thumbnail.nextElementSibling?.classList.remove("hidden");
  }

  private static show(thumbnail?: Element) {
    thumbnail?.classList.remove("active-thumbnail");
    thumbnail?.nextElementSibling?.classList.add("hidden");
  }
}
