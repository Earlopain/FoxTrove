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
    thumbnail.classList.add("hidden");
    thumbnail.nextElementSibling?.classList.remove("hidden");
  }

  private static show(thumbnail?: Element) {
    thumbnail?.classList.remove("hidden");
    thumbnail?.nextElementSibling?.classList.add("hidden");
  }
}
