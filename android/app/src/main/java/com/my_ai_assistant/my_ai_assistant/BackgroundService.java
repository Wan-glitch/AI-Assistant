package com.my_ai_assistant.my_ai_assistant;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.view.WindowManager;
import android.widget.Button;
import android.view.View;
import android.view.Gravity;
import android.widget.Toast;
import android.graphics.PixelFormat;
import android.view.LayoutInflater;

import androidx.annotation.Nullable;

public class BackgroundService extends Service {
    private WindowManager windowManager;
    private View floatingButtonView;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        showFloatingButton();
        return START_STICKY;
    }

    private void showFloatingButton() {
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        LayoutInflater inflater = LayoutInflater.from(this);
        floatingButtonView = inflater.inflate(R.layout.floating_button_layout, null);

        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
        );

        params.gravity = Gravity.TOP | Gravity.END; // Position it at the top right of the screen
        params.x = 0;
        params.y = 100;

        Button button = floatingButtonView.findViewById(R.id.floating_button);
        button.setOnClickListener(view -> Toast.makeText(BackgroundService.this, "Floating button clicked!", Toast.LENGTH_SHORT).show());

        windowManager.addView(floatingButtonView, params);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (floatingButtonView != null) {
            windowManager.removeView(floatingButtonView);
        }
    }
}
