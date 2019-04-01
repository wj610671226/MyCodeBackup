package com.san.coap.modules.tbs;

import android.graphics.PixelFormat;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.san.coap.MainApplication;
import com.san.coap.R;
import com.san.coap.modules.tbs.utils.FileUtils;
import com.san.coap.modules.tbs.utils.X5WebView;

public class TbsVideoActivity extends AppCompatActivity {

    private X5WebView webView;
    private Button backButton;
    private TextView mTextView;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tbs_video);
        webView = findViewById(R.id.video_webView);
        mTextView = findViewById(R.id.tbs_title);
        backButton = findViewById(R.id.tbs_back_button);
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        initDisplayVideoView();
    }

    private void initDisplayVideoView() {
        if (!MainApplication.getInstance().getLoadX5()) {
            Toast.makeText(TbsVideoActivity.this, "加载X5内核失败", Toast.LENGTH_SHORT).show();
            return;
        }
        String localPath = getIntent().getStringExtra("localPath");
        mTextView.setText(FileUtils.fileName(localPath));
        Log.i("TbsVideoActivity", localPath);
        if (localPath.length() == 0 || localPath == null) {
            Toast.makeText(TbsVideoActivity.this, "获取文件名失败", Toast.LENGTH_SHORT).show();
            return;
        }
        Boolean isExists = FileUtils.fileIsExists(localPath);
        if (!isExists) {
            Toast.makeText(TbsVideoActivity.this, "本地文件不存在", Toast.LENGTH_SHORT).show();
            return;
        }
        if (localPath.indexOf("file://") == -1) {
            localPath = "file://" + localPath;
        }
        webView.loadUrl(localPath);
        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        webView.getView().setOverScrollMode(View.OVER_SCROLL_ALWAYS);
        webView.setWebChromeClient(new com.tencent.smtt.sdk.WebChromeClient());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (webView != null) {
            webView.onPause();
        }
    }
}
