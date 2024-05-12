import ClickMode from "./click_mode";
import Toggleable from "./toggleable";

export default class MultiselectMode {
  private static submitting = false;
  private static counter: HTMLElement | null;

  public static init() {
    this.counter = document.getElementById("selected-count");
    
    const toggleable = Toggleable.get("multiselect");
    toggleable?.setShowAction(() => {
      ClickMode.activate(this);
    });

    toggleable?.setHideAction(() => {
      ClickMode.activateDefault();
    });

    for (const submissionFile of [...ClickMode.getAllSubmissionFiles()]) {
      submissionFile.addClickListener(() => {
        if(ClickMode.isDisabled(this)) {
          return;
        }

        submissionFile.toggleSelect();
        this.setCount();
      })
    }

    const elements = {
      hide_many: document.getElementById("hide-selected"),
      backlog_many: document.getElementById("backlock-selected"),
      unbacklog_many: document.getElementById("unbacklock-selected"),
      enqueue_many: document.getElementById("enqueue-selected"),
    };
    for (const [endpoint, link] of Object.entries(elements)) {
      link?.addEventListener("click", () => {
        this.submit(endpoint);
      });
    }
    document.getElementById("select-all")?.addEventListener("click", () => {
      ClickMode.selectAll();
      this.setCount();
    })
  }

  private static async submit(endpoint: string) {
    if(this.submitting || ClickMode.getSelectedIds().length == 0) {
      return;
    }
    this.submitting = true;
    await fetch(`/submission_files/${endpoint}.json`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ ids: ClickMode.getSelectedIds() })
    });
    this.submitting = false;
    ClickMode.deselectAll();
  }

  private static setCount(count?: number) {
    if(this.counter) {
      count = count || ClickMode.getSelectedIds().length;
      this.counter.innerText = count.toString();
    }
  }

  public static reset() {
    this.setCount(0);
  }
}
