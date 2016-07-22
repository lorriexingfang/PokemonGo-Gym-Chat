package com.share.weiboShare;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.cloneboxassistant.together.R;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;

import com.sina.weibo.sdk.api.ImageObject;
import com.sina.weibo.sdk.api.TextObject;
import com.sina.weibo.sdk.api.WebpageObject;
import com.sina.weibo.sdk.api.WeiboMultiMessage;
import com.sina.weibo.sdk.api.share.IWeiboShareAPI;
import com.sina.weibo.sdk.api.share.SendMultiMessageToWeiboRequest;
import com.sina.weibo.sdk.api.share.WeiboShareSDK;
import com.sina.weibo.sdk.auth.AuthInfo;
import com.sina.weibo.sdk.auth.Oauth2AccessToken;
import com.sina.weibo.sdk.auth.WeiboAuthListener;
import com.sina.weibo.sdk.exception.WeiboException;
import com.sina.weibo.sdk.utils.Utility;

public class WeiboShare extends CordovaPlugin {
	public CallbackContext callbackContext;

	private String title;
	private String summary;
	private String target_url;
	private String image_url;

	/** 微博分享的接口实例 */
	private IWeiboShareAPI mWeiboShareAPI;

	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

		this.callbackContext = callbackContext;

		JSONObject jsonObject = args.getJSONObject(0);

		title = jsonObject.getString("title");
		summary = jsonObject.getString("summary");
		target_url = jsonObject.getString("target_url");
		image_url = jsonObject.getString("image_url");

		final Context context = this.cordova.getActivity().getApplicationContext();
		final Activity activity = this.cordova.getActivity();

		final JSONObject result = new JSONObject();
		result.put("result", true);

		Runnable runable = new Runnable() {
			Bitmap thumb = null;

			@Override
			public void run() {
				show();
				mWeiboShareAPI = WeiboShareSDK.createWeiboAPI(context, Constants.APP_KEY);
				// 获取微博客户端相关信息，如是否安装、支持 SDK 的版本
				mWeiboShareAPI.registerApp();
				sendMultiMessage();
			}

			/**
			* 第三方应用发送请求消息到微博，唤起微博分享界面。 注意：当 {@link IWeiboShareAPI#getWeiboAppSupportAPI()} >= 10351 时，支持同时分享多条消息， 同时可以分享文本、图片以及其它媒体资源（网页、音乐、视频、声音中的一种）。
			* */
			private void sendMultiMessage() {

				// 1. 初始化微博的分享消息
				WeiboMultiMessage weiboMessage = new WeiboMultiMessage();
				weiboMessage.textObject = getTextObj();

				weiboMessage.imageObject = getImageObj();

				// 用户可以分享其它媒体资源（网页、音乐、视频、声音中的一种）

				weiboMessage.mediaObject = getWebpageObj();

				// 2. 初始化从第三方到微博的消息请求
				SendMultiMessageToWeiboRequest request = new SendMultiMessageToWeiboRequest();
				// 用transaction唯一标识一个请求
				request.transaction = String.valueOf(System.currentTimeMillis());
				request.multiMessage = weiboMessage;

				// 3. 发送请求消息到微博，唤起微博分享界面
				AuthInfo authInfo = new AuthInfo(context, Constants.APP_KEY, Constants.REDIRECT_URL, Constants.SCOPE);
				Oauth2AccessToken accessToken = AccessTokenKeeper.readAccessToken(context.getApplicationContext());
				String token = "";
				if (accessToken != null) {
					token = accessToken.getToken();
				}

				mWeiboShareAPI.sendRequest(activity, request, authInfo, token, new WeiboAuthListener() {

					@Override
					public void onWeiboException(WeiboException arg0) {
						arg0.printStackTrace();
						Log.d("weibo", "onWeiboException");
					}

					@Override
					public void onComplete(Bundle bundle) {
						// TODO Auto-generated method stub
						Oauth2AccessToken newToken = Oauth2AccessToken.parseAccessToken(bundle);
						AccessTokenKeeper.writeAccessToken(context.getApplicationContext(), newToken);
						Log.d("weibo", "onComplete");
					}

					@Override
					public void onCancel() {
						Log.d("weibo", "onCancel");
					}

				});
				hidden();
			}

			private void hidden() {
				cordova.getActivity().runOnUiThread(new Runnable() {

					@Override
					public void run() {
						ViewGroup root = (ViewGroup) activity.getWindow().getDecorView().findViewById(android.R.id.content);
						root.removeViewAt(1);
					}
				});
			}

			private void show() {
				cordova.getActivity().runOnUiThread(new Runnable() {

					@Override
					public void run() {
						ViewGroup root = (ViewGroup) activity.getWindow().getDecorView().findViewById(android.R.id.content);

						RelativeLayout rl = new RelativeLayout(activity);
						rl.setBackgroundColor(0x90000000);
						RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
						params.addRule(RelativeLayout.CENTER_IN_PARENT);
						rl.setLayoutParams(params);
						root.addView(rl);

						ProgressBar dlg = new ProgressBar(activity);
						RelativeLayout.LayoutParams p = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
						p.addRule(RelativeLayout.CENTER_IN_PARENT);
						dlg.setLayoutParams(p);
						rl.addView(dlg);

					}
				});
			}

			/**
			* 创建文本消息对象。
			*
			* @return 文本消息对象。
			*/
			private TextObject getTextObj() {
				TextObject textObject = new TextObject();
				textObject.text = summary;
				return textObject;
			}

			/**
			* 创建图片消息对象。
			*
			* @return 图片消息对象。
			*/
			private ImageObject getImageObj() {
				Bitmap b = getThumbBitmap();
				if (b == null) {
					b = BitmapFactory.decodeResource(context.getResources(), R.drawable.icon);
				}
				ImageObject imageObject = new ImageObject();
				imageObject.setImageObject(b);
				return imageObject;
			}

			/**
			* 创建多媒体（网页）消息对象。
			*
			* @return 多媒体（网页）消息对象。
			*/
			private WebpageObject getWebpageObj() {
				WebpageObject mediaObject = new WebpageObject();
				mediaObject.identify = Utility.generateGUID();
				mediaObject.title = title;
				mediaObject.description = summary;

				// 设置 Bitmap 类型的图片到视频对象里
				Bitmap b = getThumbBitmap();
				if (b == null) {
					b = BitmapFactory.decodeResource(context.getResources(), R.drawable.icon);
				}
				mediaObject.setThumbImage(b);
				mediaObject.actionUrl = target_url;
				mediaObject.defaultText = "默认文案";
				return mediaObject;
			}

			public Bitmap getThumbBitmap() {
				if (thumb != null) {
					return thumb;
				}
				URL url;
				try {
					url = new URL(image_url);
					thumb = BitmapFactory.decodeStream(url.openConnection().getInputStream());
					thumb = centerSquareScaleBitmap(thumb, 200);
				} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				} finally {
					return thumb;
				}
			}

			/**
			*
			* @param bitmap
			*            原图
			* @param edgeLength
			*            希望得到的正方形部分的边长
			* @return 缩放截取正中部分后的位图。
			*/
			public Bitmap centerSquareScaleBitmap(Bitmap bitmap, int edgeLength) {
				if (null == bitmap || edgeLength <= 0) {
					return null;
				}

				Bitmap result = bitmap;
				int widthOrg = bitmap.getWidth();
				int heightOrg = bitmap.getHeight();

				if (widthOrg > edgeLength && heightOrg > edgeLength) {
					// 压缩到一个最小长度是edgeLength的bitmap
					int longerEdge = (int) (edgeLength * Math.max(widthOrg, heightOrg) / Math.min(widthOrg, heightOrg));
					int scaledWidth = widthOrg > heightOrg ? longerEdge : edgeLength;
					int scaledHeight = widthOrg > heightOrg ? edgeLength : longerEdge;
					Bitmap scaledBitmap;

					try {
						scaledBitmap = Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true);
					} catch (Exception e) {
						return null;
					}

					// 从图中截取正中间的正方形部分。
					int xTopLeft = (scaledWidth - edgeLength) / 2;
					int yTopLeft = (scaledHeight - edgeLength) / 2;

					try {
						result = Bitmap.createBitmap(scaledBitmap, xTopLeft, yTopLeft, edgeLength, edgeLength);
						scaledBitmap.recycle();
					} catch (Exception e) {
						return null;
					}
				}

				return result;
			}
		};
		cordova.getThreadPool().execute(runable);
		callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
		return true;
	}
}
