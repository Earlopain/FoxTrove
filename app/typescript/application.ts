// Entry point for the build script in your package.json

import ClickMode from "./click_mode";
import MultiselectMode from "./multiselect_mode";
import Samples from "./samples";
import TimeAgo from "./time_ago";
import Toggleable from "./toggleable";

// TODO: https://github.com/rails/rails/issues/49499
import "@rails/ujs";

document.addEventListener("DOMContentLoaded", () => {
  ClickMode.init();
  Toggleable.init();
  MultiselectMode.init();
  Samples.init();
  TimeAgo.init();
});
