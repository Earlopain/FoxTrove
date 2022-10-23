// Entry point for the build script in your package.json

import ClickMode from "./click_mode";
import Samples from "./samples";
import SubmissionMultiselect from "./submission_multiselect";
import TimeAgo from "./time_ago";
import Toggleable from "./toggleable";

import Rails from "@rails/ujs"
Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  ClickMode.init();
  Samples.init();
  SubmissionMultiselect.init();
  TimeAgo.init();
  Toggleable.init();
});
