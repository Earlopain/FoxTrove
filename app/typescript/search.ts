export default class Search {
  static init() {
    for (const container of document.querySelectorAll(".hideable-search-container")) {
      const searchForm = container.querySelector(".hideable-search-form");
      const searchShow = container.querySelector(".hideable-search-show");
      const searchHide = container.querySelector(".hideable-search-hide");
      searchShow?.addEventListener("click", () => {
        searchShow.classList.add("hidden");
        searchHide?.classList.remove("hidden");
        searchForm?.classList.remove("hidden");
      });
      searchHide?.addEventListener("click", () => {
        searchShow?.classList.remove("hidden");
        searchHide?.classList.add("hidden");
        searchForm?.classList.add("hidden");
      });
    }
  }
}
