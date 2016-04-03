package com.abject_entertainment.toolkit;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;
import android.widget.ImageButton;

public class MenuActivity extends AppCompatActivity {

    private static final String URL_HOME = "http://google.com";
    private static final String URL_FEEDBACK = "http://duckduckgo.com";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu);

        ImageButton buttonDice = (ImageButton) findViewById(R.id.buttonDice);
        buttonDice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.setClass(MenuActivity.this, DiceActivity.class);
                startActivity(i);
            }
        });

        ImageButton buttonChars = (ImageButton) findViewById(R.id.buttonChars);
        buttonChars.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.setClass(MenuActivity.this, CharacterListActivity.class);
                startActivity(i);
            }
        });

        ImageButton buttonMaps = (ImageButton) findViewById(R.id.buttonMaps);
        buttonMaps.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.setClass(MenuActivity.this, MapListActivity.class);
                startActivity(i);
            }
        });

        ImageButton buttonShop = (ImageButton) findViewById(R.id.buttonShop);
        buttonShop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.setClass(MenuActivity.this, ShopActivity.class);
                startActivity(i);
            }
        });

        WebView webView = (WebView) findViewById(R.id.webView);
        webView.loadUrl(URL_HOME);
    }
}
