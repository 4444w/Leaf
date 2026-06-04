/**
 * 用户脚本数据模型 —— Tampermonkey 风格
 * 支持 @name @match @version @description @run-at 等元信息
 */
@Observed
export class UserScript {
  id: string = ''
  name: string = '未命名脚本'
  version: string = '1.0'
  description: string = ''
  /** @match URL 匹配规则，如 *://*.example.com/* */
  match: string = '*://*/*'
  /** 脚本 JavaScript 代码 */
  code: string = ''
  /** 是否启用 */
  enabled: boolean = true
  /** 运行时机: document-start | document-end | document-idle */
  runAt: string = 'document-idle'
  createdAt: number = Date.now()
  updatedAt: number = Date.now()

  constructor(name?: string, code?: string, match?: string) {
    this.id = `sc_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`
    if (name) this.name = name
    if (code) this.code = code
    if (match) this.match = match
  }
}
