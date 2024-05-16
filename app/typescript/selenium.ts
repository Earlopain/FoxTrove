export default class Selenium {
  public static init() {
    const element = document.getElementById("selenium-notice")!;
    setInterval(async () => {
      const request = await fetch("/stats/selenium");
      const json = await request.json();
      if (json.active) {
        element.classList.remove("hidden");
      } else {
        element.classList.add("hidden"); 
      }
    }, 5000);
  }
}
