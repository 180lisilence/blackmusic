/**
 * 统一预加载：在入口页（Index）的生命周期里触发一次，
 * 数据写入 AppStorage，子视图用 @StorageLink 订阅（ArkUI-X 上子组件 aboutToAppear 不一定回调）。
 */
import { getDailyRecommend, getMomentList, getRecommendList, getSwiperList, getSongList } from '../api/MusicApi';
import { DailyRecommendType, MomentItemType, RecommendListType, SongItemType, SwiperItemType } from '../models/MusicModels';

export const KEY_SWIPERS: string = 'swipers';
export const KEY_DAILIES: string = 'dailies';
export const KEY_PLAYLISTS: string = 'playlists';
export const KEY_SONGS: string = 'songs';
export const KEY_MOMENTS: string = 'moments';

let started: boolean = false;

export function preloadAll(force: boolean = false): void {
  if (started && !force) {
    return;
  }
  started = true;

  getSwiperList().then((list: SwiperItemType[]) => {
    AppStorage.setOrCreate<SwiperItemType[]>(KEY_SWIPERS, list);
  });
  getDailyRecommend().then((list: DailyRecommendType[]) => {
    AppStorage.setOrCreate<DailyRecommendType[]>(KEY_DAILIES, list);
  });
  getRecommendList().then((list: RecommendListType[]) => {
    AppStorage.setOrCreate<RecommendListType[]>(KEY_PLAYLISTS, list);
  });
  getSongList().then((list: SongItemType[]) => {
    AppStorage.setOrCreate<SongItemType[]>(KEY_SONGS, list);
  });
  getMomentList().then((list: MomentItemType[]) => {
    AppStorage.setOrCreate<MomentItemType[]>(KEY_MOMENTS, list);
  });
}
