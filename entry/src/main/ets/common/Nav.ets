/**
 * 黑马云音乐 —— 路由跳转封装
 */
import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PlayerParams, SongItemType } from '../models/MusicModels';

const DOMAIN = 0x0000;
const TAG = 'HeimaMusic';

/** 跳转播放页 */
export function gotoPlayer(song: SongItemType): void {
  try {
    router.pushUrl({
      url: 'pages/Player',
      params: new PlayerParams(song.id, song.title, song.artist, song.cover, song.duration, song.url)
    });
  } catch (err) {
    hilog.error(DOMAIN, TAG, 'pushUrl failed: %{public}s', JSON.stringify(err));
  }
}

/**
 * 返回上一页。
 * 先调 router.back()；在 ArkUI-X 安卓宿主下 back 可能静默不弹栈，
 * 因此再用 replaceUrl 兜底回到根页 Index，保证从播放页 / 设置页能退回首页。
 */
export function goBack(): void {
  try {
    router.back();
  } catch (err) {
    hilog.error(DOMAIN, TAG, 'back failed: %{public}s', JSON.stringify(err));
  }
  try {
    router.replaceUrl({ url: 'pages/Index' });
  } catch (err) {
    hilog.error(DOMAIN, TAG, 'replaceUrl fallback failed: %{public}s', JSON.stringify(err));
  }
}
