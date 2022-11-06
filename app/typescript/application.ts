// Entry point for the build script in your package.json

import ClickMode from "./click_mode";
import MultiselectMode from "./multiselect_mode";
import Samples from "./samples";
import TimeAgo from "./time_ago";
import Toggleable from "./toggleable";

import Rails from "@rails/ujs"
Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  ClickMode.init();
  MultiselectMode.init();
  Samples.init();
  TimeAgo.init();
  Toggleable.init();
});
