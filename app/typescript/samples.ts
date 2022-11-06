import ClickMode from "./click_mode";
import SubmissionFile from "./submission_file";

export default class Samples {
  private static currentActive: SubmissionFile | undefined;

  public static init() {
    for (const submissionFile of ClickMode.getAllSubmissionFiles()) {
      submissionFile.addClickListener(() => {
        if(ClickMode.isDisabled(this)) {
          return;
        }

        if (this.currentActive && submissionFile.sameAs(this.currentActive)) {
          this.reset();
        } else {
          this.hideLarge(this.currentActive);
          this.currentActive = submissionFile;
          this.showLarge(submissionFile);
          submissionFile.getFull().addEventListener("click", () => {
            this.reset();
          }, { once: true });
        }
      });
    }
  }

  private static showLarge(submissionFile: SubmissionFile) {
    submissionFile.select()
    submissionFile.showFullFile();
  }

  private static hideLarge(submissionFile?: SubmissionFile) {
    submissionFile?.unselect();
    submissionFile?.hideFullFile()
  }

  public static reset() {
    this.hideLarge(this.currentActive);
    this.currentActive = undefined;
  }
}
