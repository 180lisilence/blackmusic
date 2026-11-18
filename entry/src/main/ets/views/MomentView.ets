/**
 * 首页 —— 动态页（教材 9.2.5 首页-动态页）
 * 结构：互动广场 + 动态列表（作者 / 内容 / 歌曲卡片 / 点赞评论分享）
 */
import { MomentItemType, SongItemType } from '../models/MusicModels';
import { getMomentList } from '../api/MusicApi';
import { COLOR_ACCENT, COLOR_CARD, COLOR_SUB, COLOR_TEXT, COLOR_WEAK, SPACE_PAGE } from '../common/Theme';
import { LoadingTip } from '../common/Widgets';
import { gotoPlayer } from '../common/Nav';

@Component
struct MomentCard {
  @ObjectLink item: MomentItemType;

  build() {
    Column() {
      Row() {
        Image(this.item.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(this.item.author)
            .fontSize(13)
            .fontColor(COLOR_SUB)
          Text(this.item.publishedAt)
            .fontSize(11)
            .fontColor(COLOR_WEAK)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })

        Image($r('app.media.ic_more'))
          .width(18)
          .height(18)
          .fillColor(COLOR_WEAK)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(this.item.content)
        .fontSize(14)
        .fontColor('#ececf2')
        .lineHeight(21)
        .width('100%')
        .margin({ top: 12 })

      Row() {
        Image(this.item.song.cover)
          .width(44)
          .height(44)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(this.item.song.title)
            .fontSize(13)
            .fontColor(COLOR_TEXT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.item.song.artist)
            .fontSize(11)
            .fontColor(COLOR_WEAK)
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })

        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.ic_play'))
            .width(12)
            .height(12)
            .fillColor('#ffffff')
        }
        .width(30)
        .height(30)
        .borderRadius(15)
        .backgroundColor(COLOR_ACCENT)
      }
      .width('100%')
      .padding(10)
      .borderRadius(12)
      .backgroundColor(COLOR_CARD)
      .margin({ top: 12 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        gotoPlayer(this.item.song);
      })

      Row() {
        Row() {
          Image($r('app.media.ic_heart'))
            .width(16)
            .height(16)
            .fillColor(this.item.liked ? COLOR_ACCENT : COLOR_WEAK)
          Text(this.item.likes.toString())
            .fontSize(12)
            .fontColor(this.item.liked ? COLOR_ACCENT : COLOR_WEAK)
            .margin({ left: 5 })
        }
        .onClick(() => {
          this.item.liked = !this.item.liked;
          this.item.likes = this.item.liked ? this.item.likes + 1 : this.item.likes - 1;
        })

        Row() {
          Image($r('app.media.ic_comment'))
            .width(16)
            .height(16)
            .fillColor(COLOR_WEAK)
          Text(this.item.comments.toString())
            .fontSize(12)
            .fontColor(COLOR_WEAK)
            .margin({ left: 5 })
        }
        .margin({ left: 26 })

        Row() {
          Image($r('app.media.ic_share'))
            .width(15)
            .height(15)
            .fillColor(COLOR_WEAK)
          Text(this.item.shares.toString())
            .fontSize(12)
            .fontColor(COLOR_WEAK)
            .margin({ left: 5 })
        }
        .margin({ left: 26 })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .alignItems(HorizontalAlign.Start)
    .border({ width: { bottom: 0.5 }, color: '#1c1c22' })
  }
}

@Component
export struct MomentView {
  @StorageProp('topSafe') topSafe: number = 0;
  @StorageLink('moments') moments: MomentItemType[] = [];

  aboutToAppear(): void {
    getMomentList().then((list: MomentItemType[]) => {
      this.moments = list;
    });
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('动态')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_TEXT)
          Blank()
          Row() {
            Image($r('app.media.ic_note'))
              .width(14)
              .height(14)
              .fillColor(COLOR_ACCENT)
            Text('互动广场')
              .fontSize(12)
              .fontColor(COLOR_ACCENT)
              .margin({ left: 4 })
          }
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(14)
          .backgroundColor('#2a1a22')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 4 })

        if (this.moments.length === 0) {
          LoadingTip()
        } else {
          Column() {
            ForEach(this.moments, (item: MomentItemType) => {
              MomentCard({ item: item })
            }, (item: MomentItemType) => item.id.toString())
          }
          .width('100%')
        }

        Text('已经看到全部动态')
          .fontSize(11)
          .fontColor(COLOR_WEAK)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 16, bottom: 10 })
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
