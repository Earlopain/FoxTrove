// Entry point for the build script in your package.json

import Samples from "./samples";
import TimeAgo from "./time_ago";
import Toggleable from "./toggleable";

import Rails from "@rails/ujs"
Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  Samples.init();
  TimeAgo.init();
  Toggleable.init();
});
