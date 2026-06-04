import { router } from '@kit.ArkUI'
import { TabManager } from '../manager/TabManager'
import { SettingsManager } from '../manager/SettingsManager'
import { TabInfo } from '../model/TabInfo'
import { AppConst } from '../common/Constants'

/**
 * 标签页管理页面
 * 
 * 核心交互：
 * - 左滑关闭标签页，关闭后自动切换到前一个（不是首页）
 * - 点击标签页切换到该标签并返回浏览器
 * - 新建标签页
 */
@Entry
@Component
struct TabsPage {
  @State dark: boolean = false
  @State tabList: TabInfo[] = []
  @State curIdx: number = 0

  private tabs: TabManager = TabManager.shared
  private settings: SettingsManager = SettingsManager.shared

  async aboutToAppear() {
    this.dark = this.settings.darkMode
    this.tabList = [...this.tabs.all()]
    this.curIdx = this.tabs.index()

    this.tabs.onChange(() => {
      this.tabList = [...this.tabs.all()]
      this.curIdx = this.tabs.index()
    })
  }

  build() {
    Column() {
      // ─── 顶部栏 ────────────────────────
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(15)
            .fontColor(this.dark ? '#C5D4C6' : '#4A7C59')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Text(`${this.tabList.length} 个标签页`)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('+ 新建')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(14)
          .height(28)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.tabs.add(AppConst.HOME_URL, false)
            this.tabList = [...this.tabs.all()]
          })
      }
      .width('100%')
      .height(54)
      .padding({ left: 4, right: 12 })
      .backgroundColor(this.dark ? '#111613' : '#FFFFFF')

      // ─── 标签列表 ──────────────────────
      if (this.tabList.length === 0) {
        Column() {
          Text('没有打开的标签页')
            .fontSize(15)
            .fontColor(this.dark ? '#4F5F50' : '#8A9E8B')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.tabList, (tab: TabInfo, i: number) => {
            ListItem() {
              this.TabCard(tab, i)
            }
            // ★ 左滑关闭 — 关闭后自动切到前一个标签页
            .swipeAction({ end: this.DeleteBtn(i) })
          }, (tab: TabInfo) => tab.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 12 })
      }

      // ─── 关闭全部 ──────────────────────
      if (this.tabList.length > 1) {
        Button('关闭全部标签页')
          .width('88%')
          .height(42)
          .fontSize(14)
          .fontColor('#D94F4F')
          .backgroundColor(this.dark ? '#221616' : '#FFF0F0')
          .borderRadius(21)
          .margin({ top: 10, bottom: 18 })
          .onClick(() => {
            while (this.tabs.count() > 1) {
              this.tabs.close(this.tabs.count() - 1)
            }
            this.tabList = [...this.tabs.all()]
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
  }

  // ─── 标签卡片 ─────────────────────────────

  @Builder TabCard(tab: TabInfo, i: number) {
    Row() {
      Column() {
        Text(tab.title || '新标签页')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(tab.url)
          .fontSize(12)
          .fontColor(this.dark ? '#4F5F50' : '#8A9E8B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (tab.isIncognito) {
        Text('🛡️ 无痕')
          .fontSize(10)
          .fontColor('#4A7C59')
          .margin({ left: 6 })
      }

      if (i === this.curIdx) {
        Text('当前')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(6)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: 6 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(
      i === this.curIdx
        ? (this.dark ? '#1E2620' : '#E8F2EB')
        : (this.dark ? '#1A1F1B' : '#FFFFFF')
    )
    .borderRadius(10)
    .shadow({ radius: i === this.curIdx ? 6 : 1, color: '#00000008', offsetY: 2 })
    .onClick(() => {
      this.tabs.switchTo(i)
      router.back()
    })
  }

  /**
   * ★ 左滑关闭按钮
   * 关闭后 TabManager.close(i) 会把索引切到 i-1（前一个标签页）
   * 而非回到首页
   */
  @Builder DeleteBtn(i: number) {
    Button('关闭')
      .fontSize(13)
      .fontColor('#FFFFFF')
      .backgroundColor('#D94F4F')
      .borderRadius(8)
      .width(60)
      .height(54)
      .onClick(() => {
        this.tabs.close(i)
        this.tabList = [...this.tabs.all()]
        this.curIdx = this.tabs.index()
      })
  }
}
