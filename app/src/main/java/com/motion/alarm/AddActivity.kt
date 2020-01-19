package com.motion.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.NavUtils
import androidx.core.widget.doAfterTextChanged
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_add.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import ru.slybeaver.slycalendarview.SlyCalendarDialog
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class AddActivity : AppCompatActivity(), SlyCalendarDialog.Callback {
    private lateinit var type: ListFragment.ReminderType
    var reminder: Reminder? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add)

        type = intent.getSerializableExtra(REMINDER_KEY) as ListFragment.ReminderType
        reminder = intent.getSerializableExtra(DATA_KEY) as? Reminder

        reminder?.let {
            etDescription.setText(it.description)
            etDate.setText("${it.days}, setiap pukul ${it.time}")
        }

        etDescription.doAfterTextChanged {
            if (reminder == null) reminder = Reminder(type = type.toString())
            reminder = reminder?.copy(description = it.toString())
        }

        etDate.setOnClickListener {
            SlyCalendarDialog()
                .setHeaderColor(R.color.colorPrimary)
                .setSingle(false)
                .setCallback(this)
                .setStartDate(Calendar.getInstance().time)
                .show(supportFragmentManager, "tag_date")
        }

        supportActionBar?.apply {
            setHomeButtonEnabled(true)
            setDisplayHomeAsUpEnabled(true)
            title = when (type) {
                ListFragment.ReminderType.Medicine -> getString(R.string.title_medicine)
                ListFragment.ReminderType.Food -> getString(R.string.title_food)
                ListFragment.ReminderType.Bill -> getString(R.string.title_bill)
                ListFragment.ReminderType.Arisan -> getString(R.string.title_arisan)
                ListFragment.ReminderType.Other -> getString(R.string.title_other)
            }
        }

        ivIcon.setImageDrawable(
            when (type) {
                ListFragment.ReminderType.Medicine -> getDrawable(R.drawable.ic_medicine)
                ListFragment.ReminderType.Food -> getDrawable(R.drawable.ic_food)
                ListFragment.ReminderType.Bill -> getDrawable(R.drawable.ic_bill)
                ListFragment.ReminderType.Arisan -> getDrawable(R.drawable.ic_arisan)
                ListFragment.ReminderType.Other -> getDrawable(R.drawable.ic_other)
            }
        )

        btnSave.setOnClickListener {
            if (reminder?.description?.isEmpty() == true) {
                Snackbar.make(
                    btnSave,
                    "Silahkan isi deskripsi terlebih dahulu",
                    Snackbar.LENGTH_SHORT
                ).show()
                return@setOnClickListener
            }
            if (reminder?.days?.isEmpty() == true) {
                Snackbar.make(
                    btnSave,
                    "Silahkan isi jadwal tterlebih",
                    Snackbar.LENGTH_SHORT
                ).show()
                return@setOnClickListener
            }

            GlobalScope.launch(Dispatchers.IO) {
                reminder?.also {
                    AppDatabase.getDatabase(this@AddActivity)?.reminderDao()
                        ?.insertAllReminder(it)
                    saveAlarm()
                }

                withContext(Dispatchers.Main) {
                    finish()
                }
            }
        }
    }

    private fun saveAlarm() {
        reminder?.let {
            val time = it.time.split(":").map { t -> t.toInt() }
            val date = it.days.split("-").map { d -> d.trim() }

            val startDate = dateFormat.parse(date[0]).apply {
                hours = time[0]
                minutes = time[1]
            }
            var endDate: Date? = null

            if (date.size > 1) {
                endDate = dateFormat.parse(date[1].trim()).apply {
                    hours = time[0]
                    minutes = time[1]
                }
            }
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, AlarmActivity::class.java).apply {
                putExtra(REMINDER_KEY, this@AddActivity.type.toString())
                putExtra("alarmIndex", it.alarmIndex)
            }

            val pref = getSharedPreferences("reminder", Context.MODE_PRIVATE)
            var size = it.alarmIndex
            pref.edit().apply {
                putInt(REMINDER_KEY, size)
                apply()
            }
            var pendingIntent = PendingIntent.getActivity(
                this,
                size,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT
            )

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
                        this,
                        size,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT
                    )

                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        startDate.time,
                        pendingIntent
                    )
                }
                pref.edit().apply {
                    putInt(REMINDER_KEY, size)
                    apply()
                }
            }
        }
    }

    private fun deleteAlarm(reminder: Reminder) {
        GlobalScope.launch(Dispatchers.IO) {
            val time = reminder.time.split(":").map { t -> t.toInt() }
            val date = reminder.days.split("-").map { d -> d.trim() }

            val startDate = dateFormat.parse(date[0]).apply {
                hours = time[0]
                minutes = time[1]
            }
            var endDate: Date? = null

            if (date.size > 1) {
                endDate = dateFormat.parse(date[1].trim()).apply {
                    hours = time[0]
                    minutes = time[1]
                }
            }

            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this@AddActivity, AlarmActivity::class.java)
            var size = reminder.alarmIndex
            var pendingIntent = PendingIntent.getActivity(
                this@AddActivity,
                size,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT
            ).also { it.cancel() }
            alarmManager.cancel(pendingIntent)
            if (endDate != null) {
                while (startDate.before(endDate)) {
                    startDate.date += 1
                    size += 1
                    pendingIntent = PendingIntent.getActivity(
                        this@AddActivity,
                        size,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT
                    )
                        .also { it.cancel() }

                    alarmManager.cancel(pendingIntent)
                }
            }
        }

    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_delete, menu)
        return super.onCreateOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                NavUtils.navigateUpFromSameTask(this)
                true
            }
            R.id.item_delete -> {
                reminder?.also {
                    if (it.days.isEmpty() || it.time.isEmpty()) {
                        NavUtils.navigateUpFromSameTask(this)
                    } else {
                        GlobalScope.launch(Dispatchers.IO) {
                            AppDatabase.getDatabase(this@AddActivity)?.reminderDao()
                                ?.deleteReminder(it)

                            deleteAlarm(it)

                            withContext(Dispatchers.Main) {
                                finish()
                            }
                        }
                    }
                } ?: NavUtils.navigateUpFromSameTask(this)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun Int.format() = if (this > 9) this.toString() else "0$this"

    private fun Calendar.format() = dateFormat.format(time)

    override fun onDataSelected(
        firstDate: Calendar?,
        secondDate: Calendar?,
        hours: Int,
        minutes: Int
    ) {
        val time = "${hours.format()}:${minutes.format()}"

        val dateStart = firstDate?.format() ?: ""
        val dateEnd = secondDate?.format()?.let { "- $it" } ?: ""
        etDate.setText("$dateStart $dateEnd, setiap pukul $time")

        val pref = getSharedPreferences("reminder", Context.MODE_PRIVATE)
        var size = pref.getInt(REMINDER_KEY, 0) + 1

        if (reminder == null) reminder = Reminder(type = type.toString(), alarmIndex = size)
        reminder = reminder?.copy(days = "$dateStart $dateEnd", time = time)
    }

    override fun onCancelled() {
    }

    companion object {
        const val REMINDER_KEY = "REMINDER_KEY"
        const val DATA_KEY = "DATA_KEY"

        val dateFormat = SimpleDateFormat("dd MMM yyyy", Locale.US)
    }
}
