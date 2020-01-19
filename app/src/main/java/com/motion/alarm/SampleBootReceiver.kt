package com.motion.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.util.Date

class SampleBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            // reschedule alarm
            AppDatabase.getDatabase(context)?.reminderDao()?.loadAll()?.forEach {
                val type = when (it.type) {
                    ListFragment.ReminderType.Medicine.toString() -> ListFragment.ReminderType.Medicine
                    ListFragment.ReminderType.Food.toString() -> ListFragment.ReminderType.Food
                    ListFragment.ReminderType.Bill.toString() -> ListFragment.ReminderType.Bill
                    ListFragment.ReminderType.Arisan.toString() -> ListFragment.ReminderType.Arisan
                    else -> ListFragment.ReminderType.Other
                }

                val intent = Intent(context, AlarmActivity::class.java).apply {
                    putExtra(AddActivity.REMINDER_KEY, type)
                    putExtra(AddActivity.DATA_KEY, it)
                }
                var size = it.alarmIndex

                var pendingIntent = PendingIntent.getActivity(
                    context,
                    size,
                    intent,
                    0
                )

                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val time = it.time.split(":").map { t -> t.toInt() }
                val date = it.days.split("-").map { d -> d.trim() }

                val startDate = AddActivity.dateFormat.parse(date[0]).apply {
                    hours = time[0]
                    minutes = time[1]
                }
                var endDate: Date? = null

                if (date.size > 1) {
                    endDate = AddActivity.dateFormat.parse(date[1].trim()).apply {
                        hours = time[0]
                        minutes = time[1]
                    }
                }

                // first day
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    startDate.time,
                    pendingIntent
                )

                if (endDate != null) {
                    while (startDate.before(endDate)) {
                        startDate.date += 1
                        size += 1
                        pendingIntent = PendingIntent.getActivity(
                            context,
                            size,
                            intent,
                            0
                        )

                        alarmManager.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            startDate.time,
                            pendingIntent
                        )
                    }
                }
            }
        }
    }
}