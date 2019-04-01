package com.san.coap.modules.tbs.View;

import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.san.coap.MainApplication;
import com.san.coap.R;
import com.san.coap.modules.tbs.utils.FileUtils;
import com.tencent.smtt.sdk.TbsReaderView;

import org.apache.log4j.lf5.util.Resource;

public class TbsPreviewView extends RelativeLayout {

    private TbsReaderView mTbsReaderView;
    private RelativeLayout mRelativeLayout;
    private Context mContext;
    public String localPath;
    private EditText editText;

    public TbsPreviewView(Context context) {
        super(context);
        LayoutInflater.from(context).inflate(R.layout.tbs_preview, this);
        mContext = context;
        mRelativeLayout = findViewById(R.id.tbs_preview_relativeView);
//        mTbsReaderView = new TbsReaderView(MainApplication.getInstance().getMainActivity(), new TbsReaderView.ReaderCallback() {
//            @Override
//            public void onCallBackAction(Integer integer, Object o, Object o1) {
//                Log.i("onCallBackAction", "o = " + o + " o1 = " + o1);
//            }
//        });
        mRelativeLayout.addView(mTbsReaderView,new RelativeLayout.LayoutParams(-1,-1));

        editText = findViewById(R.id.edit_text);
    }

    public void setLocalPath(String localPath) {
        this.localPath = localPath;
        if (localPath.length() != 0) {
            Log.i("TbsReaderView", "displayFile setLocalPath = " + localPath);
            displayFile(localPath);
        }
    }

    private void displayFile(String localPath) {
        if (!MainApplication.getInstance().getLoadX5()) {
            Toast.makeText(mContext, "加载X5内核失败", Toast.LENGTH_SHORT).show();
            return;
        }

        if (localPath.length() == 0) {
            Toast.makeText(mContext, "获取文件名失败", Toast.LENGTH_SHORT).show();
            return;
        }
        Bundle bundle = new Bundle();
        String tempPath =  Environment.getExternalStorageDirectory()
                .getPath();
//        tempPath = tempPath + "/temp/";
//        if (!FileUtils.fileIsExists(tempPath)) {
//            FileUtils.createDir(tempPath);
//        }
        String filePath = localPath;
        int index = localPath.indexOf("file:///");
        if (index != -1) {
            filePath = localPath.substring(localPath.indexOf("/") + 2);
        }
        Log.i("displayFile - filePath", filePath);
        Boolean isExists = FileUtils.fileIsExists(filePath);
        if (!isExists) {
            Toast.makeText(mContext, "本地文件不存在", Toast.LENGTH_SHORT).show();
            return;
        }
        bundle.putString("filePath", filePath);
        bundle.putString("tempPath",tempPath);
        boolean result = mTbsReaderView.preOpen(parseFormat(localPath), false);
        if (result) {
            mTbsReaderView.openFile(bundle);

//            ViewGroup.LayoutParams layoutParams = mTbsReaderView.getLayoutParams();
//            layoutParams.height = 1000;
//            mTbsReaderView.setLayoutParams(layoutParams);
//            ViewGroup.LayoutParams layoutParams1 = editText.getLayoutParams();
//            layoutParams1.height = 0;
//            editText.setLayoutParams(layoutParams1);

//            new Handler().postDelayed(new Runnable() {
//                @Override
//                public void run() {
//                    ViewGroup.LayoutParams layoutParams1 = editText.getLayoutParams();
//                    layoutParams1.height = 0;
//                    editText.setLayoutParams(layoutParams1);
//                }
//            }, 1);

        } else {
            Toast.makeText(mContext, "预览文件失败", Toast.LENGTH_SHORT).show();
        }
    }

    private String parseFormat(String fileName) {
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mTbsReaderView != null) {
            Log.i("TbsPreviewView", "onDetachedFromWindow");
            mTbsReaderView.onStop();
        }
    }

    /**
     *
     * 在ReactRootView中是空实现
     * protected void onLayout(boolean changed, int left, int top, int right, int bottom) {}
     *
     */
    @Override
    public void requestLayout() {
        super.requestLayout();
        if (getWidth() > 0 && getHeight() > 0) {
//            Log.i("TbsPreviewView", "requestLayout");
            int w = MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY);
            int h = MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY);
            measure(w, h);
            layout(getPaddingLeft() + getLeft(), getPaddingTop() + getTop(), getWidth() + getPaddingLeft() + getLeft(), getHeight() + getPaddingTop() + getTop());
        }
    }
}
