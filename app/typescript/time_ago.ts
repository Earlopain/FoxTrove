export default class TimeAgo {
  private static units: Map<Intl.RelativeTimeFormatUnit, number> = new Map([
    ["year", 24 * 60 * 60 * 1000 * 365],
    ["month", 24 * 60 * 60 * 1000 * 365 / 12],
    ["day", 24 * 60 * 60 * 1000],
    ["hour", 60 * 60 * 1000],
    ["minute", 60 * 1000],
    ["second", 1000],
  ]);
  private static dateTimeFormatter = new Intl.DateTimeFormat("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    hour12: false,
  });
  private static relativeTimeFormatter = new Intl.RelativeTimeFormat("en", { numeric: "auto" })

  public formatAll(): void {
    const now = new Date();
    for (const element of document.getElementsByClassName("time-ago")) {
      this.format(element, now);
    }
  }

  private format(element: Element, now: Date) {
    const datetime = Date.parse(element.getAttribute("datetime") as string);
    var elapsed = datetime - now.getTime();

    const [unit, value] = this.getUnit(elapsed);
    element.innerHTML = TimeAgo.relativeTimeFormatter.format(Math.round(elapsed / value), unit);
    element.setAttribute("title", TimeAgo.dateTimeFormatter.format(datetime));
  }

  private getUnit(elapsed: number): [Intl.RelativeTimeFormatUnit, number] {
    for (const [key, value] of TimeAgo.units.entries()) {
      if (Math.abs(elapsed) > value) {
        return [key, value]
      }
    }
    return ["second", 1000];
  }
}
