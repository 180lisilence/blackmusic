/**
 * 启动页（教材 9.1 启动页）
 * 展示宣传信息，5 秒后自动进入首页；右上角「跳过」可立即进入。
 */
import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { COLOR_ACCENT, COLOR_TEXT } from '../common/Theme';

const SPLASH_SECONDS: number = 5;

@Entry
@Component
struct Splash {
  @StorageProp('topSafe') topSafe: number = 0;
  @State count: number = SPLASH_SECONDS;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      this.count = this.count - 1;
      if (this.count <= 0) {
        this.jumpToHome();
      }
    }, 1000);
  }

  aboutToDisappear(): void {
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private jumpToHome(): void {
    this.clearTimer();
    try {
      router.replaceUrl({ url: 'pages/Index' });
    } catch (err) {
      hilog.error(0x0000, 'HeimaMusic', 'replaceUrl failed: %{public}s', JSON.stringify(err));
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image($r('app.media.splash'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Row() {
        Text('跳过')
          .fontSize(12)
          .fontColor(COLOR_TEXT)
        Text(' ' + this.count.toString())
          .fontSize(12)
          .fontColor(COLOR_ACCENT)
      }
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .borderRadius(16)
      .backgroundColor('#59000000')
      .border({ width: 0.5, color: '#33FFFFFF' })
      .margin({ top: this.topSafe + 10, right: 16 })
      .onClick(() => {
        this.jumpToHome();
      })

      Column() {
        Blank()
        Text('黑马云音乐 · 6.0.0 · 听见每一次心动')
          .fontSize(10)
          .fontColor('#66FFFFFF')
          .margin({ bottom: 26 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0d0d10')
  }
}
