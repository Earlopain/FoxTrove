export default class Search {
  static init() {
    const searchForm = document.getElementById("hideable-search-form");
    const searchShow = document.getElementById("hideable-search-show");
    const searchHide = document.getElementById("hideable-search-hide");
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
