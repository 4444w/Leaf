/**
 * 浏览器标签页数据模型
 * 每个标签页维护独立的 URL、标题、无痕状态
 */
@Observed
export class TabInfo {
  id: string = ''
  url: string = ''
  title: string = '新标签页'
  isIncognito: boolean = false
  createdAt: number = Date.now()

  constructor(url?: string, isIncognito?: boolean) {
    this.id = `tab_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`
    this.url = url || 'https://www.bing.com'
    if (isIncognito !== undefined) {
      this.isIncognito = isIncognito
    }
  }
}
