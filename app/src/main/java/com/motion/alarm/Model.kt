package com.motion.alarm

import android.content.Context
import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Delete
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import java.io.Serializable

@Entity(tableName = "reminder")
data class Reminder(
    @PrimaryKey(autoGenerate = true) var uid: Int = 0,
    @ColumnInfo(name = "description") val description: String = "",
    @ColumnInfo(name = "days") val days: String = "",
    @ColumnInfo(name = "time") val time: String = "",
    @ColumnInfo(name = "type") val type: String = "",
    @ColumnInfo(name = "alarmIndex") val alarmIndex: Int = 0
) : Serializable

@Dao
interface ReminderDao {
    @Query("SELECT * FROM reminder")
    fun loadAll(): List<Reminder>

    @Query("SELECT * FROM reminder WHERE type = :type")
    fun loadAllOfType(type: String): List<Reminder>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAllReminder(reminder: Reminder): Long

    @Delete
    fun deleteReminder(reminder: Reminder)
}

@Database(entities = [Reminder::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun reminderDao(): ReminderDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase? {
            if (INSTANCE == null) {
                synchronized(AppDatabase::class.java) {
                    if (INSTANCE == null) {
                        INSTANCE = Room.databaseBuilder<AppDatabase>(
                            context.applicationContext,
                            AppDatabase::class.java, "database-reminder"
                        ).build()
                    }
                }
            }
            return INSTANCE
        }
    }
}