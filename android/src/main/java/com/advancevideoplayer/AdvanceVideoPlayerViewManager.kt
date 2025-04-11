package com.advancevideoplayer

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AdvanceVideoPlayerViewManagerInterface
import com.facebook.react.viewmanagers.AdvanceVideoPlayerViewManagerDelegate

@ReactModule(name = AdvanceVideoPlayerViewManager.NAME)
class AdvanceVideoPlayerViewManager : SimpleViewManager<AdvanceVideoPlayerView>(),
  AdvanceVideoPlayerViewManagerInterface<AdvanceVideoPlayerView> {
  private val mDelegate: ViewManagerDelegate<AdvanceVideoPlayerView>

  init {
    mDelegate = AdvanceVideoPlayerViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<AdvanceVideoPlayerView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): AdvanceVideoPlayerView {
    return AdvanceVideoPlayerView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: AdvanceVideoPlayerView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "AdvanceVideoPlayerView"
  }
}
