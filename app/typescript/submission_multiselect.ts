import ClickMode from "./click_mode";

export default class SubmissionMultiselect {
  private static submitting = false;

  public static init() {
    document.getElementById("enter-select-mode")?.addEventListener("click", () => {
      ClickMode.activate(this);
    });

    document.getElementById("leave-select-mode")?.addEventListener("click", () => {
      ClickMode.activateDefault();
    });

    for (const element of [...ClickMode.getAllElements()]) {
      element.addEventListener("click", () => {
        if(ClickMode.isDisabled(this)) {
          return;
        }

        element.classList.toggle("selected");
      })
    }

    const elements = {
      hide_many: document.getElementById("hide-selected"),
      backlog_many: document.getElementById("backlock-selected"),
      enqueue_many: document.getElementById("enqueue-selected"),
    };
    for (const [endpoint, link] of Object.entries(elements)) {
      link?.addEventListener("click", () => {
        this.submit(endpoint);
      });
    }
    document.getElementById("select-all")?.addEventListener("click", () => {
      ClickMode.selectAll();
    })
  }

  private static async submit(endpoint: string) {
    if(this.submitting) {
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
    ClickMode.deselectAll();
  }
}
