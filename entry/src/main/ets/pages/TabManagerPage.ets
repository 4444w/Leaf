import { TabManager } from '../manager/TabManager'
import { TabInfo } from '../model/TabInfo'
import { Constants } from '../common/Constants'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct TabManagerPage {
  @State tabs: TabInfo[] = []
  @State isDarkMode: boolean = false
  @State currentIndex: number = 0

  private tabManager: TabManager = TabManager.getInstance()

  async aboutToAppear() {
    const prefs = await import('@kit.ArkData').then(m => m.preferences)
    const context = getContext(this)
    const pref = await prefs.getPreferences(context, 'browser_settings')
    this.isDarkMode = (await pref.get('dark_mode', false)) as boolean

    this.tabs = this.tabManager.getAllTabs()
    this.currentIndex = this.tabManager.getCurrentIndex()

    this.tabManager.setOnTabsChanged(() => {
      this.tabs = [...this.tabManager.getAllTabs()]
      this.currentIndex = this.tabManager.getCurrentIndex()
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(15)
            .fontColor(this.isDarkMode ? '#C5D4C6' : '#4A7C59')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => { router.back() })

        Text(`${this.tabs.length} 个标签页`)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('新建')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(16)
          .height(32)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            const tab = this.tabManager.addTab(Constants.HOME_URL, false)
            this.tabs = [...this.tabManager.getAllTabs()]
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 16 })
      .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FFFFFF')

      // 标签页列表 - 左滑关闭
      List({ space: 8 }) {
        ForEach(this.tabs, (tab: TabInfo, index: number) => {
          ListItem() {
            this.TabCardBuilder(tab, index)
          }
          .swipeAction({ end: this.SwipeDeleteBuilder(index) })
        }, (tab: TabInfo) => tab.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 12 })

      // 关闭全部
      if (this.tabs.length > 1) {
        Button('关闭全部标签页')
          .width('90%')
          .height(44)
          .fontSize(14)
          .fontColor('#D94F4F')
          .backgroundColor(this.isDarkMode ? '#2A2222' : '#FFF0F0')
          .borderRadius(22)
          .margin({ top: 12, bottom: 20 })
          .onClick(() => {
            // 保留一个标签页
            while (this.tabManager.getTabCount() > 1) {
              this.tabManager.closeTab(this.tabManager.getTabCount() - 1)
            }
            this.tabs = [...this.tabManager.getAllTabs()]
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FAFDF7')
  }

  @Builder
  TabCardBuilder(tab: TabInfo, index: number) {
    Row() {
      Column() {
        Text(tab.title || '新标签页')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(tab.url)
          .fontSize(12)
          .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (tab.isIncognito) {
        Text('🛡️ 无痕')
          .fontSize(11)
          .fontColor('#4A7C59')
          .margin({ left: 8 })
      }

      if (index === this.currentIndex) {
        Text('当前')
          .fontSize(11)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(8)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(
      index === this.currentIndex
        ? (this.isDarkMode ? '#222923' : '#E8F2EB')
        : (this.isDarkMode ? '#222923' : '#FFFFFF')
    )
    .borderRadius(10)
    .shadow({ radius: index === this.currentIndex ? 8 : 2, color: '#00000010', offsetY: 2 })
    .onClick(() => {
      this.tabManager.switchToTab(index)
      router.back()
    })
  }

  @Builder
  SwipeDeleteBuilder(index: number) {
    Button('关闭')
      .fontSize(13)
      .fontColor('#FFFFFF')
      .backgroundColor('#D94F4F')
      .borderRadius(8)
      .width(64)
      .height(60)
      .onClick(() => {
        // 核心逻辑：关闭后自动切换到前一个标签页
        this.tabManager.closeTab(index)
        this.tabs = [...this.tabManager.getAllTabs()]
        this.currentIndex = this.tabManager.getCurrentIndex()
      })
  }
}
