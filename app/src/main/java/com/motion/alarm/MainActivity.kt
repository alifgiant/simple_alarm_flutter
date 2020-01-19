package com.motion.alarm

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {
    val fragments = listOf(
        R.id.item_medicine to ListFragment.create(ListFragment.ReminderType.Medicine),
        R.id.item_food to ListFragment.create(ListFragment.ReminderType.Food),
        R.id.item_bill to ListFragment.create(ListFragment.ReminderType.Bill),
        R.id.item_arisan to ListFragment.create(ListFragment.ReminderType.Arisan),
        R.id.item_other to ListFragment.create(ListFragment.ReminderType.Other)
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        viewPager.adapter = object :
            FragmentPagerAdapter(supportFragmentManager, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

            override fun getItem(position: Int) = fragments[position].second

            override fun getCount() = fragments.size
        }

        viewPager.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {
            }

            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {
            }

            override fun onPageSelected(position: Int) {
                bottomNavBar.selectedItemId = fragments[position].first
            }
        })

        bottomNavBar.setOnNavigationItemSelectedListener {
            viewPager.currentItem = fragments.indexOfFirst { fr -> fr.first == it.itemId }
            true
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_setting, menu)
        return super.onCreateOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        startActivityForResult(
            Intent(this, SettingActivity::class.java),
            ListFragment.SETTING_CODE
        )
        return super.onOptionsItemSelected(item)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ListFragment.SETTING_CODE) {
            fragments.forEach { it.second.reload() }
        }
    }
}
