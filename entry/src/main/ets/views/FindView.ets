/**
 * 首页 —— 发现页（教材 9.2.4 首页-发现页）
 * 结构：标题 + 搜索框（按歌名/歌手本地过滤）+ 猜你喜欢歌曲列表
 */
import { SongItemType } from '../models/MusicModels';
import { getSongList } from '../api/MusicApi';
import { COLOR_ACCENT, COLOR_CARD, COLOR_SUB, COLOR_TEXT, COLOR_WEAK, SPACE_PAGE } from '../common/Theme';
import { formatTime, LoadingTip, SectionHeader } from '../common/Widgets';
import { gotoPlayer } from '../common/Nav';

@Component
export struct FindView {
  @StorageProp('topSafe') topSafe: number = 0;
  @StorageLink('songs') songs: SongItemType[] = [];
  @State keyword: string = '';

  aboutToAppear(): void {
    getSongList().then((list: SongItemType[]) => {
      this.songs = list;
    });
  }

  /** 按歌名 / 歌手本地过滤；空关键字返回全量 */
  private filteredSongs(): SongItemType[] {
    const k: string = this.keyword.trim().toLowerCase();
    if (k.length === 0) {
      return this.songs;
    }
    return this.songs.filter((s: SongItemType) => {
      return s.title.toLowerCase().includes(k) || s.artist.toLowerCase().includes(k);
    });
  }

  @Builder
  SongRow(song: SongItemType, index: number) {
    Row() {
      Text((index + 1).toString())
        .fontSize(12)
        .fontColor(index < 3 ? COLOR_ACCENT : COLOR_WEAK)
        .width(18)
        .textAlign(TextAlign.Center)

      Image(song.cover)
        .width(52)
        .height(52)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
        .margin({ left: 6 })

      Column() {
        Text(song.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(song.artist + ' · ' + formatTime(song.duration))
          .fontSize(11)
          .fontColor(COLOR_WEAK)
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Image($r('app.media.ic_play'))
        .width(16)
        .height(16)
        .fillColor(COLOR_SUB)
        .padding(0)

      Image($r('app.media.ic_more'))
        .width(18)
        .height(18)
        .fillColor(COLOR_WEAK)
        .margin({ left: 14 })
    }
    .width('100%')
    .height(72)
    .padding({ left: 4, right: 4 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      gotoPlayer(song);
    })
  }

  build() {
    Scroll() {
      Column() {
        Text('发现')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TEXT)
          .width('100%')
          .margin({ bottom: 12 })

        Row() {
          Image($r('app.media.ic_search'))
            .width(15)
            .height(15)
            .fillColor(COLOR_SUB)
          TextInput({ text: this.keyword, placeholder: '搜索歌曲、歌手、歌单' })
            .layoutWeight(1)
            .height(36)
            .backgroundColor(Color.Transparent)
            .fontColor(COLOR_TEXT)
            .placeholderColor(COLOR_SUB)
            .fontSize(13)
            .margin({ left: 6 })
            .onChange((v: string) => {
              this.keyword = v;
            })
        }
        .width('100%')
        .height(36)
        .padding({ left: 12, right: 12 })
        .borderRadius(18)
        .backgroundColor(COLOR_CARD)
        .alignItems(VerticalAlign.Center)

        Column() {
          SectionHeader('猜你喜欢')

          if (this.filteredSongs().length === 0) {
            LoadingTip()
          } else {
            Column() {
              ForEach(this.filteredSongs(), (song: SongItemType, index: number) => {
                this.SongRow(song, index)
              }, (song: SongItemType) => song.id.toString())
            }
            .width('100%')
            .margin({ top: 6 })
          }
        }
        .width('100%')
        .margin({ top: 22 })
        .alignItems(HorizontalAlign.Start)

        Text('根据你的收听记录生成')
          .fontSize(11)
          .fontColor(COLOR_WEAK)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 18, bottom: 10 })
      }
      .width('100%')
      .padding({ left: SPACE_PAGE, right: SPACE_PAGE, top: this.topSafe + 10, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
