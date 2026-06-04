import { UserScript } from '../model/UserScript'
import { preferences, Context } from '@kit.ArkData'
import { AppConst } from '../common/Constants'

/**
 * 油猴脚本管理器（单例）
 * 
 * 核心职责：
 * - 解析 Tampermonkey 格式脚本（==UserScript== 头部）
 * - @match URL 通配符匹配
 * - 持久化存储脚本到 Preferences
 * - 生成注入代码供 Web 组件 runJavaScript() 调用
 */
export class ScriptManager {
  private static inst: ScriptManager | null = null
  private scripts: UserScript[] = []
  private store: preferences.Preferences | null = null
  private listener: (() => void) | null = null

  private constructor() {}

  static get shared(): ScriptManager {
    if (!ScriptManager.inst) {
      ScriptManager.inst = new ScriptManager()
    }
    return ScriptManager.inst
  }

  onChange(cb: () => void): void { this.listener = cb }
  private notify(): void { if (this.listener) this.listener() }

  // ─── 初始化 ────────────────────────────────

  async init(ctx: Context): Promise<void> {
    try {
      this.store = await preferences.getPreferences(ctx, AppConst.SCRIPTS_DB)
      await this._load()
    } catch (e) {
      console.error('[ScriptManager] init error:', e)
    }
  }

  private async _load(): Promise<void> {
    if (!this.store) return
    try {
      const raw = await this.store.get('scripts', '[]') as string
      const arr = JSON.parse(raw) as Record<string, Object>[]
      this.scripts = arr.map(obj => {
        const s = new UserScript()
        Object.assign(s, obj)
        return s
      })
    } catch (e) {
      this.scripts = []
    }
  }

  private async _save(): Promise<void> {
    if (!this.store) return
    try {
      await this.store.put('scripts', JSON.stringify(this.scripts))
      await this.store.flush()
    } catch (e) {
      console.error('[ScriptManager] save error:', e)
    }
  }

  // ─── CRUD ──────────────────────────────────

  all(): UserScript[] { return this.scripts }

  enabled(): UserScript[] { return this.scripts.filter(s => s.enabled) }

  async add(s: UserScript): Promise<void> {
    this.scripts.push(s)
    await this._save()
    this.notify()
  }

  async remove(id: string): Promise<void> {
    this.scripts = this.scripts.filter(s => s.id !== id)
    await this._save()
    this.notify()
  }

  async toggle(id: string): Promise<void> {
    const s = this.scripts.find(x => x.id === id)
    if (s) {
      s.enabled = !s.enabled
      s.updatedAt = Date.now()
      await this._save()
      this.notify()
    }
  }

  async update(id: string, patch: Partial<UserScript>): Promise<void> {
    const s = this.scripts.find(x => x.id === id)
    if (s) {
      Object.assign(s, patch, { updatedAt: Date.now() })
      await this._save()
      this.notify()
    }
  }

  // ─── Tampermonkey 导入 ────────────────────

  /**
   * 解析 ==UserScript== ... ==/UserScript== 头部
   */
  parseMeta(code: string): Partial<UserScript> {
    const result: Partial<UserScript> = {}
    const m = code.match(/\/\/\s*==UserScript==([\s\S]*?)\/\/\s*==\/UserScript==/)
    if (!m) return { code }

    for (const line of m[1].split('\n')) {
      const t = line.trim()
      let r: RegExpMatchArray | null

      r = t.match(/@name\s+(.+)/);          if (r) result.name = r[1].trim()
      r = t.match(/@version\s+(.+)/);       if (r) result.version = r[1].trim()
      r = t.match(/@description\s+(.+)/);   if (r) result.description = r[1].trim()
      r = t.match(/@match\s+(.+)/);         if (r) result.match = r[1].trim()
      r = t.match(/@run-at\s+(.+)/);        if (r) result.runAt = r[1].trim()
    }
    result.code = code
    return result
  }

  /**
   * 从 Tampermonkey 格式代码创建并保存脚本
   */
  async importCode(code: string): Promise<UserScript> {
    const meta = this.parseMeta(code)
    const s = new UserScript(
      meta.name || '未命名脚本',
      code,
      meta.match || '*://*/*'
    )
    if (meta.version) s.version = meta.version
    if (meta.description) s.description = meta.description
    if (meta.runAt) s.runAt = meta.runAt
    await this.add(s)
    return s
  }

  // ─── URL 匹配 & 注入 ──────────────────────

  /**
   * 获取匹配当前 URL 的所有启用脚本
   */
  matched(url: string): UserScript[] {
    return this.enabled().filter(s => this._matchUrl(s.match, url))
  }

  /**
   * 生成注入到页面的 JavaScript 代码
   * 将所有匹配脚本包裹在 try-catch 中执行
   */
  injectCode(url: string): string {
    const list = this.matched(url)
    if (list.length === 0) return ''

    let js = ';(function(){\n'
    for (const s of list) {
      js += `/* === ${s.name} v${s.version} === */\n`
      js += `try{${s.code}}catch(e){console.error('[Leaf:${s.name}]',e);}\n\n`
    }
    js += '})();'
    return js
  }

  /**
   * Tampermonkey @match 风格的 URL 匹配
   * 
   * 支持规则：
   - *://*/*        → 匹配所有 http/https
   - *://*.b.com/*  → 匹配 b.com 子域名
   - https://a.com  → 精确匹配
   */
  private _matchUrl(pattern: string, url: string): boolean {
    // 将 @match 模式转为正则
    let re = pattern
      .replace(/[.+^${}()|[\]\\]/g, '\\$&')  // 转义特殊字符
      .replace(/\*/g, '.*')                    // * → .*
    try {
      return new RegExp('^' + re + '$').test(url)
    } catch (_) {
      return false
    }
  }
}
