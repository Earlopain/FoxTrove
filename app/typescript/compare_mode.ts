import Cropper from "cropperjs";
import ClickMode from "./click_mode";
import SubmissionFile from "./submission_file";

declare var juxtapose: any;

interface Slider {
  src: string,
  label: string,
}

export default class CompareMode {
  private static originalImage: SubmissionFile;
  private static target: HTMLElement;
  private static lastCropEvent?: Cropper.CropEvent;
  private static currentJuxtapoase?: any;

  public static init() {
    this.originalImage = ClickMode.getAllSubmissionFiles().find(s => s.isOriginal()) as SubmissionFile;
    this.target = document.getElementById("image-juxtaposition") as HTMLElement;

    const cropTarget = this.originalImage.getSample();
    if(!cropTarget) {
      return;
    }

    let timeoutId: number;
    new Cropper(cropTarget, {
      autoCrop: false,
      aspectRatio: this.originalImage.getWidth() / this.originalImage.getHeight(),
      background: false,
      movable: false,
      rotatable: false,
      scalable: false,
      viewMode: 1,
      zoomable: false,
      crop: (event) => {
        this.lastCropEvent = event;
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => { this.createComparasion(); }, 250);
      }
    });

    for (const submissionFile of ClickMode.getAllSubmissionFiles()) {
      submissionFile.addClickListener(() => {
        if(ClickMode.isDisabled(this)) {
          return;
        }
        
        ClickMode.deselectAll();
        submissionFile.select();
        this.createComparasion();
      })
    }

    ClickMode.activate(this);
  }

  private static async createComparasion() {
    const submissionFile = ClickMode.firstSelected();
    if(!submissionFile || !this.lastCropEvent) {
      return;
    }

    await this.originalImage.preloadFull();
    await submissionFile.preloadFull();
    const croppedOriginal = await this.getCroppedBlobUrl(this.lastCropEvent.detail, this.originalImage);
		const croppedToCompare = await this.getCroppedBlobUrl(this.lastCropEvent.detail, submissionFile);
    const left = { src: croppedOriginal, label: this.originalImage.getCompareLabel() };
    const right = { src: croppedToCompare, label: submissionFile.getCompareLabel() };
    this.createCompareJuxtapose(left, right);
  }

  private static createCompareJuxtapose(left: Slider, right: Slider) {
		const currentPercentage = this.currentJuxtapoase ? parseFloat(this.currentJuxtapoase.getPosition()) : 50;
		this.target.innerHTML = "";
		this.currentJuxtapoase = new juxtapose.JXSlider("#" + this.target.id,
			[
				{
					src: left.src,
					label: left.label
				},
				{
					src: right.src,
					label: right.label,
				}
			],
			{
				showLabels: true,
				startingPosition: currentPercentage,
				makeResponsive: true
			});
	}

  private static async getCroppedBlobUrl(event: Cropper.Data, submissionFile: SubmissionFile) {
		const ratio = submissionFile.getWidth() / submissionFile.getSample().naturalWidth;
    const canvas = document.createElement("canvas");
		canvas.width = submissionFile.getWidth();
		canvas.height = submissionFile.getHeight();
		const ctx = canvas.getContext("2d") as CanvasRenderingContext2D;
		ctx.imageSmoothingEnabled = false;

		const sx = event.x * ratio;
    const sy = event.y * ratio;
    const sw = event.width * ratio;
    const sh = event.height * ratio;
		ctx.drawImage(submissionFile.getFull(), sx, sy, sw, sh, 0, 0, canvas.width, canvas.height);
		return await this.canvasToBlobUrl(canvas);
	}

  private static canvasToBlobUrl(canvas: HTMLCanvasElement): Promise<string> {
		return new Promise(resolve => {
			canvas.toBlob(blob => {
        resolve(URL.createObjectURL(blob as Blob));
      }, "image/png");
		})
	}
}
