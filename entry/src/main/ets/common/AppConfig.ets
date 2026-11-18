/**
 * 运行时状态：数据源标记（本地内置）。
 */

/** 写入数据源标记（内存态，页面读取） */
export function setDataSource(source: string): void {
  AppStorage.setOrCreate('dataSource', source);
}

/** 读取当前数据源标记，默认本地内置 */
export function getDataSource(): string {
  const v: string | undefined = AppStorage.get<string>('dataSource');
  return v !== undefined && v !== null ? v : 'local';
}
