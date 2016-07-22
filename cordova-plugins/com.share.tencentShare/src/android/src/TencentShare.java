package com.share.tencentShare;

import java.util.ArrayList;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.tencent.connect.share.QQShare;
import com.tencent.connect.share.QzoneShare;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

public class TencentShare extends CordovaPlugin {
  public CallbackContext callbackContext;

  private String title;
  private String appid;
  private String summary;
  private String target_url;
  private String image_url;

  public Tencent mTencent = null;

  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    try {
      this.callbackContext = callbackContext;
      Context context = this.cordova.getActivity().getApplicationContext();
      JSONObject jsonObject = args.getJSONObject(0);

      appid = jsonObject.getString("appid");
      title = jsonObject.getString("title");
      summary = jsonObject.getString("summary");
      target_url = jsonObject.getString("target_url");
      image_url = jsonObject.getString("image_url");

      mTencent = Tencent.createInstance(appid, context);

      JSONObject result = new JSONObject();
      result.put("result", true);

      if (action.equals("qqShare")) {
        sharetoQQ(title, summary, target_url, image_url);
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
        return true;
      } else if (action.equals("qzoneShare")) {
        sharetoQzone(title, summary, target_url, image_url);
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
        return true;
      } else {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
        return false;
      }
    } catch (JSONException e) {
      e.printStackTrace();
      Log.e("Protonet", "JSON Exception Plugin... :(");
    }
    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
    return false;
  }

  public void sharetoQQ(final String title, final String summary, final String target_url, final String image_url) {
    final Activity activity = this.cordova.getActivity();
        Bundle bundle = new Bundle();
        bundle.clear();
        bundle.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
        bundle.putInt(QQShare.SHARE_TO_QQ_EXT_INT, QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);
        bundle.putString(QQShare.SHARE_TO_QQ_TITLE, title);
        bundle.putString(QQShare.SHARE_TO_QQ_SUMMARY, summary);
        bundle.putString(QQShare.SHARE_TO_QQ_TARGET_URL, target_url);
        bundle.putString(QQShare.SHARE_TO_QQ_IMAGE_URL, image_url);
        mTencent.shareToQQ(activity, bundle, new BaseUiListener());
  }

  public void sharetoQzone(final String title, final String summary, final String target_url, final String image_url) {
    final Activity activity = this.cordova.getActivity();
        Bundle bundle = new Bundle();
        bundle.clear();
        bundle.putInt(QzoneShare.SHARE_TO_QZONE_KEY_TYPE, QzoneShare.SHARE_TO_QZONE_TYPE_IMAGE_TEXT);
        bundle.putInt(QzoneShare.SHARE_TO_QQ_EXT_INT, QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);
        bundle.putString(QzoneShare.SHARE_TO_QQ_TITLE, title);
        bundle.putString(QzoneShare.SHARE_TO_QQ_SUMMARY, summary);
        bundle.putString(QzoneShare.SHARE_TO_QQ_TARGET_URL, target_url);
        ArrayList<String> imageUrls = new ArrayList<String>();
        imageUrls.add(image_url);
        bundle.putStringArrayList(QzoneShare.SHARE_TO_QQ_IMAGE_URL, imageUrls);
        mTencent.shareToQzone(activity, bundle, new BaseUiListener());
  }

  public class BaseUiListener implements IUiListener {

    @Override
    public void onCancel() {
      Log.d("TencentShare", "onCancel");
    }

    protected void doComplete(JSONObject values) {
      Log.d("TencentShare", "doComplete");
    }

    @Override
    public void onComplete(Object arg0) {
      Log.d("TencentShare", "onComplete");
    }

    @Override
    public void onError(UiError arg0) {
      Log.d("TencentShare", "onError");
    }

  }

}
