package com.motion.alarm

import android.content.Context
import android.os.Bundle
import android.util.TypedValue
import android.view.MenuItem
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.NavUtils
import kotlinx.android.synthetic.main.activity_setting.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class SettingActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportActionBar?.setHomeButtonEnabled(true)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        setContentView(R.layout.activity_setting)

        var job: Job? = null

        val pref = getSharedPreferences("reminder", Context.MODE_PRIVATE)

        val size = pref.getInt(SIZE_KEY, 0)
        tvSampleFont.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f + size)
        seekbar.progress = size

        btnSave.setOnClickListener {
            pref.edit().apply {
                putInt(SIZE_KEY, seekbar.progress)
                apply()
            }
            finish()
        }

        seekbar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                job?.cancel()
                job = GlobalScope.launch {
                    delay(300)
                    withContext(Dispatchers.Main) {
                        tvSampleFont.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f + progress)
                    }
                }
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {
            }

            override fun onStopTrackingTouch(seekBar: SeekBar?) {
            }
        })
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                NavUtils.navigateUpFromSameTask(this)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    companion object {
        const val SIZE_KEY = "text_size_add"
    }
}
