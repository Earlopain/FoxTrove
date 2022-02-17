// Entry point for the build script in your package.json

import TimeAgo from "./time_ago";
import Search from "./search";

import Rails from "@rails/ujs"
Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  new TimeAgo().formatAll();
  Search.init();
});
