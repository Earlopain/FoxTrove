export default class Search {
  static init() {
    for (const container of document.querySelectorAll(".hideable-search-container")) {
      const searchShow = container.querySelector(".hideable-search-show");
      const searchHide = container.querySelector(".hideable-search-hide");
      searchShow?.addEventListener("click", () => {
        container.setAttribute("data-form-visible", "true");
      });
      searchHide?.addEventListener("click", () => {
        container.setAttribute("data-form-visible", "false");
      });
    }
  }
}
