/**
 * 全局常量定义
 */
export class AppConst {
  /** 默认首页 */
  static readonly HOME_URL: string = 'https://www.bing.com'

  /** 存储-设置偏好文件名 */
  static readonly PREFS_NAME: string = 'leaf_browser_prefs'

  /** 存储-脚本数据库文件名 */
  static readonly SCRIPTS_DB: string = 'leaf_scripts_db'

  /** 设置项 key：暗黑模式 */
  static readonly KEY_DARK_MODE: string = 'dark_mode'

  /** 设置项 key：自定义 UA */
  static readonly KEY_CUSTOM_UA: string = 'custom_ua'

  /** 设置项 key：搜索引擎 */
  static readonly KEY_SEARCH_ENGINE: string = 'search_engine'

  /** UA 预设列表 */
  static readonly UA_LIST: Array<{ name: string; value: string }> = [
    { name: '默认（系统UA）', value: '' },
    { name: 'Chrome 桌面', value: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36' },
    { name: 'Chrome Android', value: 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36' },
    { name: 'Safari iPhone', value: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1' },
    { name: 'Firefox 桌面', value: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0' },
    { name: 'Edge 桌面', value: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0' },
    { name: 'Googlebot', value: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' },
  ]

  /** 搜索引擎列表 */
  static readonly ENGINE_LIST: Array<{ name: string; url: string }> = [
    { name: 'Bing', url: 'https://www.bing.com/search?q=' },
    { name: 'Google', url: 'https://www.google.com/search?q=' },
    { name: '百度', url: 'https://www.baidu.com/s?wd=' },
    { name: 'DuckDuckGo', url: 'https://duckduckgo.com/?q=' },
  ]
}
