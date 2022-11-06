export type AvailableTypes = "search" | "multiselect";

export default class Toggleable {
  private static all: Map<string, Toggleable> = new Map();

  private showLink: HTMLAnchorElement;
  private hideLink: HTMLAnchorElement;

  private constructor(container: HTMLElement) {
    this.showLink = container.querySelector(".link-show") as HTMLAnchorElement; 
    this.showLink.addEventListener("click", () => {
      container.setAttribute("data-content-visible", "true");
    });
    this.hideLink = container.querySelector(".link-hide") as HTMLAnchorElement;
    this.hideLink.addEventListener("click", () => {
      container.setAttribute("data-content-visible", "false");
    });
  }

  public setShowAction(callback: () => void) {
    this.showLink.addEventListener("click", callback);
  }

  public setHideAction(callback: () => void) {
    this.hideLink.addEventListener("click", callback);
  }

  public static init() {
    for (const container of document.querySelectorAll(".toggleable-container")) {
      this.all.set(container.id, new Toggleable(container as HTMLElement));
    }
  }

  public static get(type: AvailableTypes) {
    return this.all.get(type);
  }
}
