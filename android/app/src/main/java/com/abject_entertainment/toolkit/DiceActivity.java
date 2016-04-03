package com.abject_entertainment.toolkit;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

public class DiceActivity extends AppCompatActivity {

    private Button countButton;
    private Button sizeButton;
    private String quickNotation;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dice);

        final EditText editNotation = (EditText) findViewById(R.id.editNotation);
        final TextView textResults = (TextView) findViewById(R.id.textResults);
        Button buttonRoll = (Button) findViewById(R.id.buttonRoll);

        buttonRoll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                textResults.setText(editNotation.getText());
            }
        });

        View.OnClickListener countListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                countButton = (Button)v;
                setQuickRoll(countButton, sizeButton);
            }
        };

        View.OnClickListener sizeListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sizeButton = (Button)v;
                setQuickRoll(countButton, sizeButton);
            }
        };

        LinearLayout buttons = (LinearLayout) findViewById(R.id.buttonsCount);
        int count = buttons.getChildCount();
        for (int i = 0; i < count; ++i) {
            View v = buttons.getChildAt(i);
            if (v instanceof Button)
            {
                ((Button)v).setOnClickListener(countListener);
            }
        }

        buttons = (LinearLayout) findViewById(R.id.buttonsSides);
        count = buttons.getChildCount();
        for (int i = 0; i < count; ++i)
        {
            View v = buttons.getChildAt(i);
            if (v instanceof Button)
            {
                ((Button)v).setOnClickListener(sizeListener);
            }
        }

        Button quickRoll = (Button) findViewById(R.id.buttonQuickRoll);
        quickRoll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                textResults.setText(quickNotation);
            }
        });

        setQuickRoll(countButton, sizeButton);
    }

    private void setQuickRoll(Button count, Button size)
    {
        int iCount = 3;
        if (count != null)
        { iCount = Integer.parseInt(count.getText().toString()); }

        int iSize = 6;
        if (size != null)
        {
            if (size.getText().toString().equals("%"))
            { iSize = 100; }
            else
            { iSize = Integer.parseInt(size.getText().toString()); }
        }

        quickNotation = iCount + "d" + iSize;
        Button quickRoll = (Button) findViewById(R.id.buttonQuickRoll);
        quickRoll.setText(String.format(getResources().getString(R.string.dice_roll_notation), quickNotation));
    }
}
