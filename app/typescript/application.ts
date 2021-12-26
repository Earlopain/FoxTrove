// Entry point for the build script in your package.json

import TimeAgo from "./time_ago";

document.addEventListener("DOMContentLoaded", () => {
  new TimeAgo().formatAll();
});
