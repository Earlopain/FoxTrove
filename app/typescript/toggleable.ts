export default class Toggleable {
  static init() {
    for (const container of document.querySelectorAll(".toggleable-container")) {
      const show = container.querySelector(".link-show");
      const hide = container.querySelector(".link-hide");
      show?.addEventListener("click", () => {
        container.setAttribute("data-content-visible", "true");
      });
      hide?.addEventListener("click", () => {
        container.setAttribute("data-content-visible", "false");
      });
    }
  }
}
