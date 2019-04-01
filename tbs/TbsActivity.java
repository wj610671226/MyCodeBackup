package com.san.coap.modules.tbs;

import android.content.res.Resources;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.san.coap.MainApplication;
import com.san.coap.R;
import com.san.coap.modules.tbs.utils.FileUtils;
import com.tencent.smtt.sdk.TbsReaderView;

public class TbsActivity extends AppCompatActivity {

    private TbsReaderView mTbsReaderView;
    private RelativeLayout mRelativeLayout;
    private TextView mTextView;
    private Button backButton;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tbs);
        mTbsReaderView = new TbsReaderView(this, new TbsReaderView.ReaderCallback() {
            @Override
            public void onCallBackAction(Integer integer, Object o, Object o1) {
                Log.i("onCallBackAction", "o = " + o + " o1 = " + o1);
            }
        });
        backButton = findViewById(R.id.tbs_back_button);
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mRelativeLayout = findViewById(R.id.tbsRelativeView);
        mRelativeLayout.addView(mTbsReaderView,new RelativeLayout.LayoutParams(-1,-1));
        mTextView = findViewById(R.id.tbs_title);
        String localPath = getIntent().getStringExtra("localPath");
        displayFile(localPath);
        mTextView.setText(FileUtils.fileName(localPath));
    }

    private void displayFile(String localPath) {
        if (!MainApplication.getInstance().getLoadX5()) {
            Toast.makeText(TbsActivity.this, "加载X5内核失败", Toast.LENGTH_SHORT).show();
            return;
        }

        if (localPath.length() == 0 || localPath == null) {
            Toast.makeText(TbsActivity.this, "获取文件名失败", Toast.LENGTH_SHORT).show();
            return;
        }
        Bundle bundle = new Bundle();
        String tempPath =  Environment.getExternalStorageDirectory()
                .getPath();

        String filePath = localPath;
        int index = localPath.indexOf("file:///");
        if (index != -1) {
            filePath = localPath.substring(localPath.indexOf("/") + 2);
        }
        Log.e("displayFile - filePath", filePath);
        Boolean isExists = FileUtils.fileIsExists(filePath);
        if (!isExists) {
            Toast.makeText(TbsActivity.this, "本地文件不存在", Toast.LENGTH_SHORT).show();
            return;
        }
        bundle.putString("filePath", filePath);
        bundle.putString("tempPath",tempPath);
        boolean result = mTbsReaderView.preOpen(parseFormat(localPath), false);
        if (result) {
            mTbsReaderView.openFile(bundle);
        } else {
            Toast.makeText(TbsActivity.this, "预览文件失败", Toast.LENGTH_SHORT).show();
        }
    }

    private String parseFormat(String fileName) {
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mTbsReaderView.onStop();
    }
}
