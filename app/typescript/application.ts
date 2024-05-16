import "../stylesheet/application";

import ClickMode from "./click_mode";
import MultiselectMode from "./multiselect_mode";
import Samples from "./samples";
import Selenium from "./selenium";
import TimeAgo from "./time_ago";
import Toggleable from "./toggleable";
import UJS from "./ujs";

document.addEventListener("DOMContentLoaded", () => {
  ClickMode.init();
  Toggleable.init();
  MultiselectMode.init();
  Samples.init();
  TimeAgo.init();
  UJS.init();
  Selenium.init();
});
