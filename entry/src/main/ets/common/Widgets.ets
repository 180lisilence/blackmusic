/**
 * 黑马云音乐 —— 公共组件与工具
 */
import { COLOR_CARD, COLOR_INACTIVE, COLOR_SUB, COLOR_TEXT, COLOR_WEAK } from './Theme';

/** 秒 -> mm:ss */
export function formatTime(total: number): string {
  const safe: number = total > 0 ? Math.floor(total) : 0;
  const minute: number = Math.floor(safe / 60);
  const second: number = safe % 60;
  const m: string = minute < 10 ? '0' + minute.toString() : minute.toString();
  const s: string = second < 10 ? '0' + second.toString() : second.toString();
  return m + ':' + s;
}

/** 区块标题：标题 + 更多 */
@Builder
export function SectionHeader(title: string) {
  Row() {
    Text(title)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor(COLOR_TEXT)
    Blank()
    Text('更多')
      .fontSize(12)
      .fontColor(COLOR_WEAK)
    Image($r('app.media.ic_back'))
      .width(10)
      .height(10)
      .fillColor(COLOR_WEAK)
      .rotate({ angle: 180 })
      .margin({ left: 2 })
  }
  .width('100%')
  .height(24)
  .alignItems(VerticalAlign.Center)
}

/** 搜索框（点击进入搜索，当前版本仅做占位提示） */
@Builder
export function SearchBar(placeholder: string) {
  Row() {
    Row() {
      Image($r('app.media.ic_search'))
        .width(15)
        .height(15)
        .fillColor(COLOR_SUB)
      Text(placeholder)
        .fontSize(13)
        .fontColor(COLOR_SUB)
        .margin({ left: 6 })
    }
    .layoutWeight(1)
    .height(36)
    .padding({ left: 12, right: 12 })
    .borderRadius(18)
    .backgroundColor(COLOR_CARD)
    .alignItems(VerticalAlign.Center)

    Image($r('app.media.ic_scan'))
      .width(22)
      .height(22)
      .fillColor(COLOR_SUB)
      .margin({ left: 14 })
  }
  .width('100%')
  .alignItems(VerticalAlign.Center)
}

/** 空状态 */
@Builder
export function LoadingTip() {
  Column() {
    Image($r('app.media.ic_note'))
      .width(26)
      .height(26)
      .fillColor(COLOR_INACTIVE)
    Text('正在加载…')
      .fontSize(12)
      .fontColor(COLOR_INACTIVE)
      .margin({ top: 8 })
  }
  .width('100%')
  .padding({ top: 40, bottom: 40 })
  .alignItems(HorizontalAlign.Center)
}


