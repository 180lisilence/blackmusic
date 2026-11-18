/**
 * 黑马云音乐 —— 数据模型层
 * 与教材第 9 章「模型文件」对应：把接口抽到 models 目录，页面只依赖模型。
 */

/** 底部 Tab 数据 */
export interface TabItemType {
  name: string;
  icon: Resource;
}

/** 轮播图数据 */
export interface SwiperItemType {
  id: number;
  title: string;
  subtitle: string;
  image: ResourceStr;
}

/** 每日推荐数据 */
export interface DailyRecommendType {
  id: number;
  title: string;
  desc: string;
  cover: ResourceStr;
}

/** 推荐歌单数据 */
export interface RecommendListType {
  id: number;
  title: string;
  count: string;
  cover: ResourceStr;
}

/** 歌曲数据 */
@Observed
export class SongItemType {
  id: number;
  title: string;
  artist: string;
  cover: ResourceStr;
  duration: number;
  /** 音频地址（远程接口下发；本地样本为空字符串） */
  url: string;

  constructor(id: number, title: string, artist: string, cover: ResourceStr, duration: number, url: string = '') {
    this.id = id;
    this.title = title;
    this.artist = artist;
    this.cover = cover;
    this.duration = duration;
    this.url = url;
  }
}

/** 动态数据 */
@Observed
export class MomentItemType {
  id: number;
  avatar: ResourceStr;
  author: string;
  content: string;
  publishedAt: string;
  song: SongItemType;
  likes: number;
  comments: number;
  shares: number;
  liked: boolean;

  constructor(id: number, avatar: ResourceStr, author: string, content: string, publishedAt: string,
    song: SongItemType, likes: number, comments: number, shares: number, liked: boolean) {
    this.id = id;
    this.avatar = avatar;
    this.author = author;
    this.content = content;
    this.publishedAt = publishedAt;
    this.song = song;
    this.likes = likes;
    this.comments = comments;
    this.shares = shares;
    this.liked = liked;
  }
}

/** 我的页面 —— 数据统计项 */
export interface MineStatType {
  label: string;
  value: string;
}

/** 我的页面 —— 功能入口 */
export interface MineMenuType {
  name: string;
  desc: string;
  icon: Resource;
}

/** 播放页路由参数 */
export class PlayerParams {
  id: number;
  title: string;
  artist: string;
  cover: ResourceStr;
  duration: number;
  url: string;

  constructor(id: number, title: string, artist: string, cover: ResourceStr, duration: number, url: string = '') {
    this.id = id;
    this.title = title;
    this.artist = artist;
    this.cover = cover;
    this.duration = duration;
    this.url = url;
  }
}
