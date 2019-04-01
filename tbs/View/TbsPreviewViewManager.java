package com.san.coap.modules.tbs.View;

import android.support.annotation.Nullable;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

public class TbsPreviewViewManager extends SimpleViewManager<TbsPreviewView> {

    @Override
    public String getName() {
        return "TbsPreviewView";
    }

    @Override
    protected TbsPreviewView createViewInstance(ThemedReactContext reactContext) {
        return new TbsPreviewView(reactContext);
    }

    @ReactProp(name = "localPath")
    public void setLocalPath(TbsPreviewView view, @Nullable String localPath) {
        view.setLocalPath(localPath);
    }
}
