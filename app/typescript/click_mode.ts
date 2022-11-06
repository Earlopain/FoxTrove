import MultiselectMode from "./compare_mode";
import Samples from "./samples";
import SubmissionFile from "./submission_file";

export default class ClickMode {
  public static state: Object = Samples;
  private static submissionFiles: SubmissionFile[];

  public static init() {
    this.submissionFiles = [...document.querySelectorAll(".submission-file")].map(e => new SubmissionFile(e as HTMLElement));
  }

  public static selectAll() {
    this.submissionFiles.forEach(s => { s.select() });
  }

  public static deselectAll() {
    this.submissionFiles.forEach(s => { s.unselect() });
  }

  public static getSelectedIds() {
    return this.submissionFiles.filter(s => s.isSelected()).map(s => s.getId());
  }

  public static getAllSubmissionFiles() {
    return this.submissionFiles;
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
    MultiselectMode.reset();
    Samples.reset();
    this.deselectAll();
  }
}
