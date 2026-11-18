/**
 * 黑马云音乐 —— 本地数据层
 *
 * 数据与素材均打包在应用内，由本地样本提供，不发起网络请求。
 * 五类数据：轮播 / 每日推荐 / 推荐歌单 / 歌曲 / 动态。
 */
import {
  DailyRecommendType,
  MomentItemType,
  RecommendListType,
  SongItemType,
  SwiperItemType
} from '../models/MusicModels';
import { setDataSource } from '../common/AppConfig';

const MOCK_DELAY: number = 160;

function delay<T>(data: T): Promise<T> {
  return new Promise<T>((resolve: (value: T) => void) => {
    setTimeout(() => {
      resolve(data);
    }, MOCK_DELAY);
  });
}

// ------------------------------------------------------------------ 本地样本

const SWIPER_LIST: SwiperItemType[] = [
  { id: 1, title: '每日推荐', subtitle: '今天从《逐梦星辰》听起', image: $r('app.media.banner_1') },
  { id: 2, title: '私人漫游', subtitle: '从《彩虹之旅》开启无限漫游', image: $r('app.media.banner_2') },
  { id: 3, title: '华语流行', subtitle: '每日推荐《快乐无界》', image: $r('app.media.banner_3') }
];

const DAILY_LIST: DailyRecommendType[] = [
  { id: 1, title: '每日推荐', desc: '今天从《逐梦星辰》听起！', cover: $r('app.media.daily_1') },
  { id: 2, title: '私人漫游', desc: '从《彩虹之旅》开启无限漫游', cover: $r('app.media.daily_2') },
  { id: 3, title: '华语流行', desc: '每日推荐《快乐无界》', cover: $r('app.media.daily_3') }
];

const RECOMMEND_LIST: RecommendListType[] = [
  { id: 1, title: '深夜慢摇', count: '270.9万', cover: $r('app.media.playlist_1') },
  { id: 2, title: '星际旅途', count: '476.1万', cover: $r('app.media.playlist_2') },
  { id: 3, title: 'City Pop 夜行', count: '188.4万', cover: $r('app.media.playlist_3') },
  { id: 4, title: '启程', count: '92.6万', cover: $r('app.media.playlist_4') },
  { id: 5, title: '雨后电台', count: '133.7万', cover: $r('app.media.playlist_5') },
  { id: 6, title: '慢速呼吸', count: '61.2万', cover: $r('app.media.playlist_6') }
];

const SONG_LIST: SongItemType[] = [
  new SongItemType(1, '逐梦星辰', '云雀合唱团', $r('app.media.cover_1'), 252),
  new SongItemType(2, '彩虹之旅', '林夕', $r('app.media.cover_2'), 228),
  new SongItemType(3, '快乐无界', '黑马乐队', $r('app.media.cover_3'), 245),
  new SongItemType(4, '晚风与海', '陈一', $r('app.media.cover_4'), 212),
  new SongItemType(5, '银河列车', '苏眠', $r('app.media.cover_5'), 266),
  new SongItemType(6, '山与雾', '白昼', $r('app.media.cover_6'), 237),
  new SongItemType(7, '青柠汽水', '小满', $r('app.media.cover_7'), 198),
  new SongItemType(8, '十七号公路', '远方', $r('app.media.cover_8'), 280)
];

const MOMENT_LIST: MomentItemType[] = [
  new MomentItemType(1, $r('app.media.avatar_1'), '阿树', '今天循环了一整天，副歌一响整个人都亮了。', '2 小时前',
    SONG_LIST[0], 1286, 233, 45, false),
  new MomentItemType(2, $r('app.media.avatar_2'), '小满', '通勤路上单曲循环，地铁都坐过站了。', '5 小时前',
    SONG_LIST[6], 864, 102, 18, false),
  new MomentItemType(3, $r('app.media.avatar_3'), '云雀', '把这首放进深夜歌单，闭眼就是星空。', '昨天 22:40',
    SONG_LIST[4], 2031, 356, 88, false),
  new MomentItemType(4, $r('app.media.avatar_4'), '老马', '编曲太克制了，越听越上头。', '昨天 19:12',
    SONG_LIST[7], 512, 61, 9, false)
];

// ------------------------------------------------------------------ 对外接口

/** 轮播图数据 */
export async function getSwiperList(): Promise<SwiperItemType[]> {
  setDataSource('local');
  return delay<SwiperItemType[]>(SWIPER_LIST);
}

/** 每日推荐数据 */
export async function getDailyRecommend(): Promise<DailyRecommendType[]> {
  setDataSource('local');
  return delay<DailyRecommendType[]>(DAILY_LIST);
}

/** 推荐歌单数据 */
export async function getRecommendList(): Promise<RecommendListType[]> {
  setDataSource('local');
  return delay<RecommendListType[]>(RECOMMEND_LIST);
}

/** 歌曲列表数据 */
export async function getSongList(): Promise<SongItemType[]> {
  setDataSource('local');
  return delay<SongItemType[]>(SONG_LIST);
}

/** 动态列表数据 */
export async function getMomentList(): Promise<MomentItemType[]> {
  setDataSource('local');
  return delay<MomentItemType[]>(MOMENT_LIST);
}
