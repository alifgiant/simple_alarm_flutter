package com.motion.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.SystemClock
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_alarm.*

class AlarmActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_alarm)
        val type = intent.getStringExtra(AddActivity.REMINDER_KEY)
        val index = intent.getIntExtra("alarmIndex", 0)

        tvTitle.text = when (type) {
            ListFragment.ReminderType.Medicine.toString() -> getString(R.string.title_medicine)
            ListFragment.ReminderType.Food.toString() -> getString(R.string.title_food)
            ListFragment.ReminderType.Bill.toString() -> getString(R.string.title_bill)
            ListFragment.ReminderType.Arisan.toString() -> getString(R.string.title_arisan)
            else -> getString(R.string.title_other)
        }

        ivIcon.setImageDrawable(
            when (type) {
                ListFragment.ReminderType.Medicine.toString() -> getDrawable(R.drawable.ic_medicine)
                ListFragment.ReminderType.Food.toString() -> getDrawable(R.drawable.ic_food)
                ListFragment.ReminderType.Bill.toString() -> getDrawable(R.drawable.ic_bill)
                ListFragment.ReminderType.Arisan.toString() -> getDrawable(R.drawable.ic_arisan)
                else -> getDrawable(R.drawable.ic_other)
            }
        )

        btnDismiss.setOnClickListener {
            finish()
        }

        btnSnooze.setOnClickListener {
            val intent = Intent(this, AlarmActivity::class.java).apply {
                putExtra(AddActivity.REMINDER_KEY, type)
            }
            val pendingIntent = PendingIntent.getActivity(
                this,
                index,
                intent,
                0
            )
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                SystemClock.elapsedRealtime() + 5 * 60 * 1000, // 5 minute
                pendingIntent
            )

            finish()
        }
    }
}