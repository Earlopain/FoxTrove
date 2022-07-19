// Entry point for the build script in your package.json

import TimeAgo from "./time_ago";
import Search from "./search";
import Samples from "./samples";

import Rails from "@rails/ujs"
Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  Samples.init();
  Search.init();
  TimeAgo.init();
});
