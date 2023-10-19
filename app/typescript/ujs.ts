export default class UJS {
  public static init() {
    document.querySelectorAll("[data-confirm]").forEach(linkTarget => {
      const message = linkTarget.getAttribute("data-confirm")!;

      linkTarget.addEventListener("click", e => {
        if (!confirm(message)) {
          e.preventDefault();
        }
      });
    });
  }
}
