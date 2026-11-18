/**
 * 播放页（教材 9.2.7 播放页）
 * 展示 5 项信息：封面图、歌曲名称、歌手、当前播放时间与进度条、歌曲时长，并提供上一首/播放/下一首控制。
 */
import { router } from '@kit.ArkUI';
import { PlayerParams, SongItemType } from '../models/MusicModels';
import { getSongList } from '../api/MusicApi';
import { COLOR_ACCENT, COLOR_SUB, COLOR_TEXT, COLOR_WEAK } from '../common/Theme';
import { formatTime } from '../common/Widgets';
import { goBack } from '../common/Nav';

@Entry
@Component
struct Player {
  @StorageProp('topSafe') topSafe: number = 0;
  @StorageProp('bottomSafe') bottomSafe: number = 0;
  @State current: SongItemType = new SongItemType(1, '逐梦星辰', '云雀合唱团', $r('app.media.cover_1'), 252);
  @State songs: SongItemType[] = [];
  @State progress: number = 0;
  @State playing: boolean = true;
  @State liked: boolean = false;
  private timerId: number = -1;

  aboutToAppear(): void {
    const raw: Object | undefined = router.getParams();
    if (raw !== undefined && raw !== null) {
      const params: PlayerParams = raw as PlayerParams;
      this.current = new SongItemType(params.id, params.title, params.artist, params.cover,
        params.duration > 0 ? params.duration : 240);
    }

    getSongList().then((list: SongItemType[]) => {
      this.songs = list;
    });

    this.timerId = setInterval(() => {
      this.tick();
    }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private tick(): void {
    if (!this.playing) {
      return;
    }
    if (this.progress >= this.current.duration) {
      this.progress = this.current.duration;
      this.playing = false;
      return;
    }
    this.progress = this.progress + 1;
  }

  private findIndex(): number {
    for (let i = 0; i < this.songs.length; i++) {
      if (this.songs[i].id === this.current.id) {
        return i;
      }
    }
    return -1;
  }

  private switchSong(offset: number): void {
    if (this.songs.length === 0) {
      return;
    }
    let index: number = this.findIndex();
    if (index < 0) {
      index = 0;
    }
    const next: number = (index + offset + this.songs.length) % this.songs.length;
    this.current = this.songs[next];
    this.progress = 0;
    this.playing = true;
  }

  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(20)
        .height(20)
        .fillColor(COLOR_TEXT)
        .onClick(() => {
          goBack();
        })

      Column() {
        Text('正在播放')
          .fontSize(14)
          .fontColor(COLOR_TEXT)
        Text('每日推荐 · 第 ' + this.current.id.toString() + ' 首')
          .fontSize(10)
          .fontColor(COLOR_WEAK)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Image($r('app.media.ic_share'))
        .width(18)
        .height(18)
        .fillColor(COLOR_TEXT)
    }
    .width('100%')
    .height(44)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  PrevButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.ic_prev'))
        .width(20)
        .height(20)
        .fillColor(COLOR_TEXT)
    }
    .width(48)
    .height(48)
    .borderRadius(24)
    .backgroundColor('#1AFFFFFF')
    .onClick(() => {
      this.switchSong(-1);
    })
  }

  @Builder
  PlayButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.playing ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
        .width(26)
        .height(26)
        .fillColor('#ffffff')
    }
    .width(68)
    .height(68)
    .borderRadius(34)
    .backgroundColor(COLOR_ACCENT)
    .shadow({ radius: 22, color: '#66E4608B', offsetY: 8 })
    .onClick(() => {
      if (this.progress >= this.current.duration) {
        this.progress = 0;
      }
      this.playing = !this.playing;
    })
  }

  @Builder
  NextButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.ic_next'))
        .width(20)
        .height(20)
        .fillColor(COLOR_TEXT)
    }
    .width(48)
    .height(48)
    .borderRadius(24)
    .backgroundColor('#1AFFFFFF')
    .onClick(() => {
      this.switchSong(1);
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.current.cover)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(60)
        .opacity(0.45)

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#B3060608')

      Column() {
        this.TopBar()

        Blank()

        Image(this.current.cover)
          .width('62%')
          .aspectRatio(1)
          .constraintSize({ maxWidth: 300, maxHeight: 300 })
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
          .shadow({ radius: 40, color: '#66000000', offsetY: 16 })

        Text(this.current.title)
          .fontSize(23)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 26 })

        Text(this.current.artist)
          .fontSize(13)
          .fontColor(COLOR_SUB)
          .margin({ top: 8 })

        Blank()

        Slider({
          value: this.progress,
          min: 0,
          max: this.current.duration > 0 ? this.current.duration : 1,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .blockColor(COLOR_ACCENT)
          .selectedColor(COLOR_ACCENT)
          .trackColor('#3a3a42')
          .trackThickness(3)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.progress = value;
          })

        Row() {
          Text(formatTime(this.progress))
            .fontSize(11)
            .fontColor(COLOR_SUB)
          Blank()
          Text(formatTime(this.current.duration))
            .fontSize(11)
            .fontColor(COLOR_WEAK)
        }
        .width('100%')
        .padding({ left: 4, right: 4 })

        Row() {
          this.PrevButton()
          this.PlayButton()
          this.NextButton()
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 26 })

        Row() {
          Column() {
            Image($r('app.media.ic_heart'))
              .width(20)
              .height(20)
              .fillColor(this.liked ? COLOR_ACCENT : COLOR_TEXT)
            Text('喜欢')
              .fontSize(10)
              .fontColor(COLOR_WEAK)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
          .onClick(() => {
            this.liked = !this.liked;
          })

          Column() {
            Image($r('app.media.ic_comment'))
              .width(20)
              .height(20)
              .fillColor(COLOR_TEXT)
            Text('评论')
              .fontSize(10)
              .fontColor(COLOR_WEAK)
              .margin({ top: 5 })
          }
          .layoutWeight(1)

          Column() {
            Image($r('app.media.ic_list'))
              .width(20)
              .height(20)
              .fillColor(COLOR_TEXT)
            Text('列表')
              .fontSize(10)
              .fontColor(COLOR_WEAK)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 30, bottom: this.bottomSafe + 18 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 26, right: 26, top: this.topSafe + 8 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0d0d10')
  }
}
