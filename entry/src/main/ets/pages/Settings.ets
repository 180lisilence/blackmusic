/**
 * 服务器设置页：填地址 → 自检 → 保存。地址持久化到 Preferences，页面立即生效。
 */
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { getBaseUrl, loadBaseUrl, saveBaseUrl, DEFAULT_BASE_URL } from '../common/AppConfig';
import { probeServer } from '../api/MusicApi';
import { COLOR_ACCENT, COLOR_CARD, COLOR_SUB, COLOR_TEXT, COLOR_WEAK } from '../common/Theme';

@Entry
@Component
struct Settings {
  @StorageProp('topSafe') topSafe: number = 0;
  @State url: string = getBaseUrl();
  @State testing: boolean = false;
  @State result: string = '';

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    loadBaseUrl(ctx).then((u: string) => {
      this.url = u;
    });
  }

  private test(): void {
    this.testing = true;
    this.result = '正在连接…';
    probeServer().then((msg: string) => {
      this.result = msg;
      this.testing = false;
    });
  }

  private save(): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    let u: string = this.url.trim();
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'http://' + u;
    }
    saveBaseUrl(ctx, u).then(() => {
      this.url = u;
      this.result = '已保存：' + u + '（返回首页刷新数据）';
    });
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(20)
          .height(20)
          .fillColor(COLOR_TEXT)
          .onClick(() => {
            router.back();
          })
        Text('服务器设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TEXT)
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(52)
      .alignItems(VerticalAlign.Center)

      Text('接口地址（只填 IP:端口 或完整 http 前缀均可）')
        .fontSize(12)
        .fontColor(COLOR_SUB)
        .width('100%')

      TextInput({ text: this.url, placeholder: DEFAULT_BASE_URL })
        .height(46)
        .margin({ top: 8 })
        .backgroundColor(COLOR_CARD)
        .fontColor(COLOR_TEXT)
        .placeholderColor(COLOR_WEAK)
        .borderRadius(10)
        .onChange((v: string) => {
          this.url = v;
        })

      Row({ space: 10 }) {
        Button('测试连接')
          .layoutWeight(1)
          .height(42)
          .backgroundColor(COLOR_CARD)
          .fontColor(COLOR_TEXT)
          .onClick(() => {
            this.test();
          })
        Button('保存')
          .layoutWeight(1)
          .height(42)
          .backgroundColor(COLOR_ACCENT)
          .fontColor('#ffffff')
          .onClick(() => {
            this.save();
          })
      }
      .width('100%')
      .margin({ top: 14 })

      Text(this.result)
        .fontSize(12)
        .fontColor(this.result.startsWith('连通') || this.result.startsWith('已保存') ? COLOR_ACCENT : COLOR_WEAK)
        .width('100%')
        .margin({ top: 14 })

      Column() {
        Text('约定接口（与教材一致）')
          .fontSize(12)
          .fontColor(COLOR_SUB)
          .width('100%')
        Text('GET /swiper         轮播\nGET /dailyRecommend 每日推荐\nGET /recommendList  推荐歌单\nGET /songList       歌曲列表\nGET /momentList     动态')
          .fontSize(12)
          .fontColor(COLOR_WEAK)
          .lineHeight(20)
          .width('100%')
          .margin({ top: 6 })
        Text('返回裸数组或 { data: [...] } 都可解析；字段兼容 title/name/songName、artist/singer、cover/coverUrl。')
          .fontSize(11)
          .fontColor(COLOR_WEAK)
          .width('100%')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(14)
      .margin({ top: 20 })
      .borderRadius(12)
      .backgroundColor(COLOR_CARD)
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: this.topSafe + 6 })
    .backgroundColor('#0d0d10')
  }
}
