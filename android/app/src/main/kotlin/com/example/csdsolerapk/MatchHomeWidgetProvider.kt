package com.example.csdsolerapk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONArray

class MatchHomeWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val ACTION_NEXT = "com.example.csdsolerapk.NEXT"
        private const val ACTION_PREV = "com.example.csdsolerapk.PREV"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences?
    ) {
        val prefs = widgetData ?: HomeWidgetPlugin.getData(context)
        val matchesJson = prefs.getString("matches", "[]")
        val index = prefs.getInt("match_index", 0)
        val matches = JSONArray(matchesJson)
        val match = if (matches.length() > 0) matches.getJSONObject(index % matches.length()) else null

        val views = RemoteViews(context.packageName, R.layout.match_widget)

        if (match != null) {
            views.setTextViewText(R.id.tvDay, match.optString("dia"))
            views.setTextViewText(R.id.tvOpponent, match.optString("rival"))
            views.setTextViewText(R.id.tvVenue, match.optString("localia"))

            val lat = match.optString("lat")
            val long = match.optString("long")
            if (lat.isNotEmpty() && long.isNotEmpty()) {
                val uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$long")
                val mapIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)
                views.setOnClickPendingIntent(R.id.btnMap, mapIntent)
            }
        }

        val nextIntent = HomeWidgetLaunchIntent.getBroadcast(context, ACTION_NEXT)
        views.setOnClickPendingIntent(R.id.btnNext, nextIntent)

        val prevIntent = HomeWidgetLaunchIntent.getBroadcast(context, ACTION_PREV)
        views.setOnClickPendingIntent(R.id.btnPrev, prevIntent)

        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val prefs = HomeWidgetPlugin.getData(context)
        var index = prefs.getInt("match_index", 0)
        val matches = JSONArray(prefs.getString("matches", "[]"))
        if (matches.length() == 0) return

        when (intent.action) {
            ACTION_NEXT -> index = (index + 1) % matches.length()
            ACTION_PREV -> index = if (index - 1 < 0) matches.length() - 1 else index - 1
        }
        prefs.edit().putInt("match_index", index).apply()
        HomeWidgetPlugin.updateWidget(context, MatchHomeWidgetProvider::class.java)
    }
}
