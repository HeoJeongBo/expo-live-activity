package expo.modules.liveactivity.infrastructure.repositories

import expo.modules.liveactivity.core.models.LiveActivityInstance
import java.util.concurrent.ConcurrentHashMap

// MARK: - Repository Protocol

interface ActivityRepositoryProtocol {
    suspend fun saveActivity(activity: LiveActivityInstance)
    suspend fun getActivity(id: String): LiveActivityInstance?
    suspend fun getActiveActivities(): List<LiveActivityInstance>
    suspend fun getAllActivities(): List<LiveActivityInstance>
    suspend fun deleteActivity(id: String)
    suspend fun clear()
}

// MARK: - In-Memory Repository Implementation

class InMemoryActivityRepository : ActivityRepositoryProtocol {
    
    private val activities = ConcurrentHashMap<String, LiveActivityInstance>()
    
    override suspend fun saveActivity(activity: LiveActivityInstance) {
        activities[activity.id] = activity
    }
    
    override suspend fun getActivity(id: String): LiveActivityInstance? {
        return activities[id]
    }
    
    override suspend fun getActiveActivities(): List<LiveActivityInstance> {
        return activities.values.filter { it.isActive }
    }
    
    override suspend fun getAllActivities(): List<LiveActivityInstance> {
        return activities.values.toList()
    }
    
    override suspend fun deleteActivity(id: String) {
        activities.remove(id)
    }
    
    override suspend fun clear() {
        activities.clear()
    }
}

// MARK: - SharedPreferences Repository Implementation (Alternative)

/* 
import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class SharedPreferencesActivityRepository(
    private val context: Context
) : ActivityRepositoryProtocol {
    
    companion object {
        private const val PREFS_NAME = "expo_live_activity_prefs"
        private const val KEY_ACTIVITIES = "activities"
    }
    
    private val preferences: SharedPreferences by lazy {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    private val gson = Gson()
    private val activitiesType = object : TypeToken<Map<String, LiveActivityInstance>>() {}.type
    
    override suspend fun saveActivity(activity: LiveActivityInstance) {
        val activities = getAllActivitiesMap().toMutableMap()
        activities[activity.id] = activity
        saveActivitiesMap(activities)
    }
    
    override suspend fun getActivity(id: String): LiveActivityInstance? {
        return getAllActivitiesMap()[id]
    }
    
    override suspend fun getActiveActivities(): List<LiveActivityInstance> {
        return getAllActivitiesMap().values.filter { it.isActive }
    }
    
    override suspend fun getAllActivities(): List<LiveActivityInstance> {
        return getAllActivitiesMap().values.toList()
    }
    
    override suspend fun deleteActivity(id: String) {
        val activities = getAllActivitiesMap().toMutableMap()
        activities.remove(id)
        saveActivitiesMap(activities)
    }
    
    override suspend fun clear() {
        preferences.edit().remove(KEY_ACTIVITIES).apply()
    }
    
    private fun getAllActivitiesMap(): Map<String, LiveActivityInstance> {
        val json = preferences.getString(KEY_ACTIVITIES, null) ?: return emptyMap()
        return try {
            gson.fromJson(json, activitiesType) ?: emptyMap()
        } catch (e: Exception) {
            emptyMap()
        }
    }
    
    private fun saveActivitiesMap(activities: Map<String, LiveActivityInstance>) {
        val json = gson.toJson(activities)
        preferences.edit().putString(KEY_ACTIVITIES, json).apply()
    }
}
*/