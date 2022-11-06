export default class SubmissionFile {
  private element: HTMLElement;
  private full: HTMLElement;

  constructor(element: HTMLElement) {
    this.element = element;
    this.full = this.element.nextElementSibling as HTMLElement;
  }

  public getFull() {
    return this.full;
  }

  public addClickListener(callback: () => void) {
    this.element.addEventListener("click", callback);
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
    return parseInt(this.element.closest(".submission-sample")?.getAttribute("data-id") as string);
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
}
