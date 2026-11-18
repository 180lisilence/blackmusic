/**
 * 运行时配置：服务器地址不再写死在代码里，改由「我的 → 服务器设置」填写并持久化。
 */
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export const DEFAULT_BASE_URL: string = 'http://example.com/music';
export const PREF_NAME: string = 'app_config';
export const PREF_KEY_BASE_URL: string = 'baseUrl';

/** 读取当前服务器地址（AppStorage 优先，其次默认值） */
export function getBaseUrl(): string {
  const v: string | undefined = AppStorage.get<string>('baseUrl');
  if (v !== undefined && v !== null && v.length > 0) {
    return v;
  }
  return DEFAULT_BASE_URL;
}

/** 写入当前地址（内存态，页面立即生效） */
export function setBaseUrl(url: string): void {
  AppStorage.setOrCreate('baseUrl', url);
}

/** 数据源标记：remote / mock */
export function setDataSource(source: string): void {
  AppStorage.setOrCreate('dataSource', source);
}

export function getDataSource(): string {
  const v: string | undefined = AppStorage.get<string>('dataSource');
  return v !== undefined && v !== null ? v : 'unknown';
}

/** 从持久化存储加载地址（应用启动/设置页初始化时调用） */
export async function loadBaseUrl(context: common.UIAbilityContext): Promise<string> {
  try {
    const store = await preferences.getPreferences(context, PREF_NAME);
    const saved: preferences.ValueType = await store.get(PREF_KEY_BASE_URL, DEFAULT_BASE_URL);
    const url: string = saved as string;
    setBaseUrl(url);
    return url;
  } catch (e) {
    setBaseUrl(DEFAULT_BASE_URL);
    return DEFAULT_BASE_URL;
  }
}

/** 保存地址到持久化存储 */
export async function saveBaseUrl(context: common.UIAbilityContext, url: string): Promise<void> {
  setBaseUrl(url);
  try {
    const store = await preferences.getPreferences(context, PREF_NAME);
    await store.put(PREF_KEY_BASE_URL, url);
    await store.flush();
  } catch (e) {
    // 持久化失败不影响本次会话使用
  }
}
