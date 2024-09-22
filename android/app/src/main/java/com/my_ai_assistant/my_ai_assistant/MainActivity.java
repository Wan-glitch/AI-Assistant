package com.my_ai_assistant.my_ai_assistant;

import android.content.Intent; // Import for Intent
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel; // Import for MethodChannel
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "my_ai_assistant/background";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("startBackgroundService")) {
                                startService(new Intent(this, BackgroundService.class)); // Use the correct Intent
                                result.success("Background Service Started");
                            } else if (call.method.equals("stopBackgroundService")) {
                                stopService(new Intent(this, BackgroundService.class)); // Use the correct Intent
                                result.success("Background Service Stopped");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
}
