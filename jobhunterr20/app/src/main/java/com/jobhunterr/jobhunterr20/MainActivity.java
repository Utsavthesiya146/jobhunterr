package com.jobhunterr.jobhunterr20;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.util.Log;

import androidx.activity.OnBackPressedCallback;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    // Define your domain as a constant for easy maintenance
    private static final String ALLOWED_DOMAIN = "jobhunterr.com";
    private static final String TAG = "MainActivity"; // Tag for logging

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // This enables your app to draw behind the system bars.
        EdgeToEdge.enable(this);

        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webView);

        // --- Configure WebView Settings ---
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true); // Essential for modern websites
        webSettings.setDomStorageEnabled(true);  // Required for local storage on web pages
        webSettings.setLoadWithOverviewMode(true);
        webSettings.setUseWideViewPort(true);
        webSettings.setSupportZoom(true);
        webSettings.setBuiltInZoomControls(true);
        webSettings.setDisplayZoomControls(false); // Hides the +/- zoom buttons for a cleaner look
        webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);

        // --- Security Enhancements ---
        // These are good defaults to prevent the WebView from accessing local files.
        webSettings.setAllowFileAccess(false);
        webSettings.setAllowFileAccessFromFileURLs(false);
        webSettings.setAllowUniversalAccessFromFileURLs(false);

        // --- Set WebView Clients ---
        webView.setWebViewClient(new MyWebViewClient());
        webView.setWebChromeClient(new WebChromeClient()); // Handles alerts, console messages, etc.

        // --- Modern Back Button Handling ---
        // This is the recommended way to handle back presses.
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true /* enabled by default */) {
            @Override
            public void handleOnBackPressed() {
                // If the WebView can navigate backwards, do that.
                if (webView.canGoBack()) {
                    webView.goBack();
                } else {
                    // Otherwise, disable this callback and let the system handle the back press
                    // (which will typically close the activity).
                    setEnabled(false);
                    // This is the correct, non-deprecated way to trigger the default back behavior.
                    getOnBackPressedDispatcher().onBackPressed();
                }
            }
        });

        // --- Load the Initial URL ---
        webView.loadUrl("https://" + ALLOWED_DOMAIN);
    }

    /**
     * A custom WebViewClient to control URL loading. This logic keeps users inside your app
     * for your own domain but opens external links in the user's default browser.
     */
    private static class MyWebViewClient extends WebViewClient {

        // This is the modern method for overriding URL loading.
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            final Uri uri = request.getUrl();
            final String host = uri.getHost();
            Log.d(TAG, "Loading URL: " + uri); // Log URL for easier debugging

            // If the host is null or doesn't end with your allowed domain...
            if (host == null || !host.endsWith(ALLOWED_DOMAIN)) {
                // ...it's an external link. Open it in the user's default browser.
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                view.getContext().startActivity(intent);
                // Return true to tell the WebView you've handled the URL.
                return true;
            }
            // Otherwise, it's an internal link. Let the WebView load it.
            return false;
        }

        // This is the deprecated version for older Android versions (pre-Lollipop).
        // It's good practice to include it for backward compatibility.
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            final Uri uri = Uri.parse(url);
            final String host = uri.getHost();
            Log.d(TAG, "Loading URL (deprecated method): " + url);

            if (host == null || !host.endsWith(ALLOWED_DOMAIN)) {
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                view.getContext().startActivity(intent);
                return true;
            }
            return false;
        }
    }
}
