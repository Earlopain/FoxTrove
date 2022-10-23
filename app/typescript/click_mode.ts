import Samples from "./samples";
import SubmissionMultiselect from "./submission_multiselect";

export default class ClickMode {
  public static state: Object = Samples;
  private static elements: NodeListOf<Element>;

  public static init() {
    this.elements = document.querySelectorAll(".submission-file");
  }

  public static selectAll() {
    this.elements.forEach(e => { e.classList.add("selected") });
  }

  public static deselectAll() {
    this.elements.forEach(e => { e.classList.remove("selected") });
  }

  public static getSelectedIds() {
    return [...document.querySelectorAll(".submission-file.selected")].map(e => {
      return parseInt(e.closest(".submission-sample")?.getAttribute("data-id") || "0");
    })
  }

  public static getAllElements() {
    return this.elements;
  }

  public static isDisabled(type: Object) {
    return type != this.state;
  }

  public static activate(type: Object) {
    this.resetAll();
    this.state = type;
  }

  public static activateDefault() {
    this.resetAll();
    this.state = Samples;
  }

  private static resetAll() {
    Samples.reset();
    SubmissionMultiselect.reset();
    this.deselectAll();
  }
}
