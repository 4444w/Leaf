import { preferences, Context } from '@kit.ArkData'
import { AppConst } from '../common/Constants'

/**
 * 设置管理器（单例）
 * 持久化存储暗黑模式、自定义 UA、搜索引擎等偏好
 */
export class SettingsManager {
  private static inst: SettingsManager | null = null
  private store: preferences.Preferences | null = null

  // 内存缓存，避免频繁异步读取
  darkMode: boolean = false
  customUA: string = ''
  searchEngine: string = 'Bing'

  private constructor() {}

  static get shared(): SettingsManager {
    if (!SettingsManager.inst) {
      SettingsManager.inst = new SettingsManager()
    }
    return SettingsManager.inst
  }

  /** 初始化：从持久化存储加载设置 */
  async init(ctx: Context): Promise<void> {
    try {
      this.store = await preferences.getPreferences(ctx, AppConst.PREFS_NAME)
      this.darkMode = (await this.store.get(AppConst.KEY_DARK_MODE, false)) as boolean
      this.customUA = (await this.store.get(AppConst.KEY_CUSTOM_UA, '')) as string
      this.searchEngine = (await this.store.get(AppConst.KEY_SEARCH_ENGINE, 'Bing')) as string
    } catch (e) {
      console.error('[Settings] init error:', e)
    }
  }

  /** 保存单个设置项 */
  async save(key: string, value: string | boolean | number): Promise<void> {
    if (!this.store) return
    try {
      await this.store.put(key, value)
      await this.store.flush()
      // 同步内存缓存
      if (key === AppConst.KEY_DARK_MODE) this.darkMode = value as boolean
      if (key === AppConst.KEY_CUSTOM_UA) this.customUA = value as string
      if (key === AppConst.KEY_SEARCH_ENGINE) this.searchEngine = value as string
    } catch (e) {
      console.error('[Settings] save error:', e)
    }
  }

  /** 获取当前搜索引擎的搜索前缀 URL */
  searchPrefix(): string {
    const found = AppConst.ENGINE_LIST.find(e => e.name === this.searchEngine)
    return found ? found.url : AppConst.ENGINE_LIST[0].url
  }
}
