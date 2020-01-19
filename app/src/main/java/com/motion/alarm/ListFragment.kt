package com.motion.alarm

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.motion.alarm.AddActivity.Companion.DATA_KEY
import com.motion.alarm.AddActivity.Companion.REMINDER_KEY
import kotlinx.android.synthetic.main.fragment_list.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class ListFragment private constructor() : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? = inflater.inflate(R.layout.fragment_list, container, false)

    private val adapter by lazy {
        ListAdapter(onItemClick = { reminder ->
            startActivityForResult(Intent(context, AddActivity::class.java).apply {
                val type = arguments?.getSerializable(REMINDER_KEY) as ReminderType
                putExtra(REMINDER_KEY, type)
                putExtra(DATA_KEY, reminder)
            }, REQUEST_CODE)
        }).also {
            it.addReminder(Reminder(-1))
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        recyclerView.adapter = adapter
        fab.setOnClickListener {
            startActivityForResult(Intent(context, AddActivity::class.java).apply {
                val type = arguments?.getSerializable(REMINDER_KEY) as ReminderType
                putExtra(REMINDER_KEY, type)
            }, REQUEST_CODE)
        }
        reload()
    }

    fun reload() = context?.let {
        loadData(it, arguments?.getSerializable(REMINDER_KEY) as ReminderType)
    }


    private fun loadData(context: Context, type: ReminderType) {
        GlobalScope.launch {
            val data = AppDatabase.getDatabase(context)
                ?.reminderDao()?.loadAllOfType(type.toString())

            withContext(Dispatchers.Main) {
                adapter.clear()
                data?.let { adapter.addReminders(it) }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE) {
            reload()
        }
    }

    enum class ReminderType {
        Medicine, Food, Bill, Arisan, Other
    }

    companion object {
        const val REQUEST_CODE = 101
        const val SETTING_CODE = 102

        fun create(type: ReminderType): ListFragment {
            return ListFragment().apply {
                arguments = bundleOf(REMINDER_KEY to type)
            }
        }
    }
}