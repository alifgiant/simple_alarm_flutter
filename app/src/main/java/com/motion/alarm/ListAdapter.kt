package com.motion.alarm

import android.content.Context
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.layout_item.view.*

class ListAdapter(private val onItemClick: (reminder: Reminder) -> Unit) :
    RecyclerView.Adapter<ListAdapter.ListVH>() {
    private val listReminder: MutableList<Reminder> = mutableListOf()

    fun clear() {
        listReminder.clear()
        notifyDataSetChanged()
    }

    fun addReminder(reminder: Reminder) {
        listReminder.add(reminder)
        notifyDataSetChanged()
    }

    fun addReminders(reminders: List<Reminder>) {
        listReminder.addAll(reminders)
        notifyDataSetChanged()
    }

    class ListVH(view: View, private val onItemClick: (reminder: Reminder) -> Unit) :
        RecyclerView.ViewHolder(view) {
        private val pref = view.context.getSharedPreferences("reminder", Context.MODE_PRIVATE)

        fun bind(reminder: Reminder) {
            //size
            val size = pref.getInt(SettingActivity.SIZE_KEY, 0)
            itemView.tvTitle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f + size)
            itemView.tvDesc.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f + size)

            if (reminder.uid == -1) {
                itemView.tvTitle.text = "Belum ada jadwal"
                itemView.tvDesc.visibility = View.GONE
            } else {
                itemView.tvDesc.visibility = View.VISIBLE
                itemView.tvTitle.text = reminder.description.capitalize()
                itemView.tvDesc.text = "${reminder.days}, setiap pukul ${reminder.time}"
                itemView.setOnClickListener {
                    onItemClick(reminder)
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ListVH {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.layout_item, parent, false)


        return ListVH(view, onItemClick)
    }

    override fun getItemCount() = listReminder.size

    override fun onBindViewHolder(holder: ListVH, position: Int) {
        holder.bind(listReminder[position])
    }
}
