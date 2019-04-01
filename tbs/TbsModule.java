package com.san.coap.modules.tbs;

import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.san.coap.modules.tbs.utils.FileUtils;
import com.tencent.smtt.sdk.TbsVideo;

public class TbsModule extends ReactContextBaseJavaModule {

    private ReactContext mReactContext;

    public TbsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mReactContext = reactContext;
    }

    @Override
    public String getName() {
        return "TbsModule";
    }

    /**
     * 预览 word pdf 等文件
     * @param localPath  /storage/emulated/0/coap/DownloadAttachment/c8b22b5370119c4efac9426a2bf6a8d4.doc
     */
    @ReactMethod
    public void previewFileByTBSForRN(String localPath) {
        Log.i("openTbsActivity", localPath);
        Intent intent = new Intent();
        intent.putExtra("localPath", localPath);
        intent.setClass(mReactContext, TbsActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mReactContext.startActivity(intent);
    }

    /**
     * 自定义webView播放视频
     * @param localPath
     */
    @ReactMethod
    public void previewVideoByTBSForRN(String localPath) {
        Log.i("openTbsVideoActivity", localPath);
        Intent intent = new Intent();
        intent.putExtra("localPath", localPath);
        intent.setClass(mReactContext, TbsVideoActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mReactContext.startActivity(intent);
    }

    /**
     * 利用SDK自带视图播放视频
     * @param localPath
     */
    @ReactMethod
    public void autoPreviewVideoByTBSForRN(String localPath) {
        Log.i("autoPlayVideo", localPath);
        if (localPath.length() == 0) {
            Toast.makeText(mReactContext, "获取文件名失败", Toast.LENGTH_SHORT).show();
            return;
        }
        Boolean isExists = FileUtils.fileIsExists(localPath);
        if (!isExists) {
            Toast.makeText(mReactContext, "本地文件不存在", Toast.LENGTH_SHORT).show();
            return;
        }
        if (localPath.indexOf("file://") == -1) {
            localPath = "file://" + localPath;
        }
        if (TbsVideo.canUseTbsPlayer(mReactContext)){
            //播放视频
            TbsVideo.openVideo(mReactContext, localPath);
        } else {
            Toast.makeText(mReactContext, "播放失败", Toast.LENGTH_SHORT).show();
        }
    }
}
