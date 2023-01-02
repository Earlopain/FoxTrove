export default class SubmissionFile {
  private element: HTMLImageElement;
  private full: HTMLImageElement;

  constructor(element: HTMLImageElement) {
    this.element = element;
    this.full = this.element.nextElementSibling as HTMLImageElement;
  }

  public getSample() {
    return this.element;
  }

  public getFull() {
    return this.full;
  }

  public addClickListener(callback: () => void) {
    this.element.addEventListener("click", callback);
  }

  public isOriginal() {
    return this.element.closest(".original") !== null;
  }

  public sameAs(other: SubmissionFile) {
    return this.element.isSameNode(other.element);
  }

  public select() {
    this.element.classList.add("selected");
  }

  public isSelected() {
    return this.element.classList.contains("selected");
  }

  public unselect() {
    this.element.classList.remove("selected");
  }

  public toggleSelect() {
    this.element.classList.toggle("selected");
  }

  public getId() {
    return parseInt(this.getAttribute("data-id"));
  }

  public getWidth() {
    return parseInt(this.getAttribute("data-width"));
  }

  public getHeight() {
    return parseInt(this.getAttribute("data-height"));
  }

  public getCompareLabel() {
    return this.getAttribute("data-compare-label")
  }

  public async preloadFull(): Promise<void> {
    if(this.full.complete) {
      return;
    }
    return new Promise(resolve => {
      this.full.loading = "eager";
      this.full.addEventListener("load", () => {
        resolve();
      });
    });
  }

  public showFullFile() {
    this.full.classList.remove("hidden");
    if (this.full instanceof HTMLVideoElement) {
      this.full.currentTime = 0;
      this.full.play();
    }
  }

  public hideFullFile() {
    this.full.classList.add("hidden");
    if (this.full instanceof HTMLVideoElement) {
      this.full.pause();
    }
  }

  private getAttribute(data: string) {
    return this.element.closest(".submission-sample")?.getAttribute(data) as string;
  }
}
