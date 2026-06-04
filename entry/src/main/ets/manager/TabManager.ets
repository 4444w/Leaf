import { TabInfo } from '../model/TabInfo'

/**
 * 标签页管理器（单例）
 * 
 * 核心职责：
 * - 管理浏览器所有标签页的创建、切换、关闭
 * - 关闭标签页时自动切换到【前一个标签页】而非首页
 * - 无痕标签页独立分组管理
 */
export class TabManager {
  private static inst: TabManager | null = null
  private tabs: TabInfo[] = []
  private idx: number = 0
  private listener: (() => void) | null = null

  private constructor() {
    this.tabs.push(new TabInfo())
  }

  static get shared(): TabManager {
    if (!TabManager.inst) {
      TabManager.inst = new TabManager()
    }
    return TabManager.inst
  }

  /** 注册数据变化回调 */
  onChange(cb: () => void): void {
    this.listener = cb
  }

  private notify(): void {
    if (this.listener) this.listener()
  }

  // ─── 读取 ──────────────────────────────────

  all(): TabInfo[] { return this.tabs }
  count(): number { return this.tabs.length }
  current(): TabInfo { return this.tabs[this.idx] }
  index(): number { return this.idx }

  // ─── 新建 ──────────────────────────────────

  /** 新建标签页并自动切换过去 */
  add(url?: string, incognito?: boolean): TabInfo {
    const tab = new TabInfo(url, incognito)
    this.tabs.push(tab)
    this.idx = this.tabs.length - 1
    this.notify()
    return tab
  }

  // ─── 切换 ──────────────────────────────────

  /** 切换到指定索引的标签页 */
  switchTo(i: number): TabInfo | null {
    if (i < 0 || i >= this.tabs.length) return null
    this.idx = i
    this.notify()
    return this.tabs[this.idx]
  }

  // ─── 关闭（核心逻辑） ──────────────────────

  /**
   * 关闭指定索引的标签页
   * 
   * ★ 关键行为：关闭后切换到前一个标签页（idx - 1），而非返回首页
   * 
   * 如果关闭的是最后一个，索引自然减 1
   * 如果关闭的是当前或之前的标签页，索引也减 1
   * 如果只剩一个标签页，重置为新空白页
   */
  close(i: number): TabInfo | null {
    if (this.tabs.length <= 1) {
      // 最后一个标签页 → 重置为空白页
      this.tabs[0] = new TabInfo()
      this.idx = 0
      this.notify()
      return this.tabs[0]
    }

    const wasCurrent = (i === this.idx)
    this.tabs.splice(i, 1)

    if (wasCurrent) {
      // 关闭的是当前标签页 → 切到前一个
      this.idx = Math.max(0, i - 1)
    } else if (i < this.idx) {
      // 关闭的是当前之前的标签页 → 当前索引前移
      this.idx = this.idx - 1
    }
    // 关闭的是当前之后的标签页 → idx 不变

    this.notify()
    return this.tabs[this.idx]
  }

  // ─── 更新 ──────────────────────────────────

  updateUrl(i: number, url: string): void {
    if (i >= 0 && i < this.tabs.length) {
      this.tabs[i].url = url
    }
  }

  updateTitle(i: number, title: string): void {
    if (i >= 0 && i < this.tabs.length) {
      this.tabs[i].title = title
    }
  }
}
