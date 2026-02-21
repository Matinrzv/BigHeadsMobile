package com.example.bighead

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Base64
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
    private val tag = "BigHeadsAuth"
    private val storageChannel = "bigheads/storage"
    private val platformChannel = "bigheads/platform"
    private val pickImageRequestCode = 1107
    private val googleSignInRequestCode = 1108
    private var pendingPickImageResult: Result? = null
    private var pendingGoogleResult: Result? = null
    private lateinit var googleClient: GoogleSignInClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleClient = GoogleSignIn.getClient(this, gso)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, storageChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAppDataPath") {
                    result.success(filesDir.absolutePath)
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, platformChannel)
            .setMethodCallHandler { call, result ->
                handlePlatformCall(call, result)
            }
    }

    private fun handlePlatformCall(call: MethodCall, result: Result) {
        when (call.method) {
            "sendEmailCode" -> {
                val email = call.argument<String>("email") ?: ""
                val code = call.argument<String>("code") ?: ""
                if (email.isBlank() || code.isBlank()) {
                    result.success(false)
                    return
                }
                try {
                    val intent = Intent(Intent.ACTION_SENDTO).apply {
                        data = Uri.parse("mailto:$email")
                        putExtra(Intent.EXTRA_SUBJECT, "BigHeads verification code")
                        putExtra(Intent.EXTRA_TEXT, "Your BigHeads code is: $code")
                    }
                    startActivity(intent)
                    result.success(true)
                } catch (_: Exception) {
                    result.success(false)
                }
            }
            "pickImageBase64" -> {
                if (pendingPickImageResult != null) {
                    result.error("IN_PROGRESS", "Image picker already active", null)
                    return
                }
                pendingPickImageResult = result
                val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    type = "image/*"
                    addCategory(Intent.CATEGORY_OPENABLE)
                }
                startActivityForResult(Intent.createChooser(intent, "Select image"), pickImageRequestCode)
            }
            "signInWithGoogle" -> {
                if (pendingGoogleResult != null) {
                    result.error("IN_PROGRESS", "Google sign-in already active", null)
                    return
                }
                pendingGoogleResult = result
                startActivityForResult(googleClient.signInIntent, googleSignInRequestCode)
            }
            "signOutGoogle" -> {
                googleClient.signOut().addOnCompleteListener {
                    result.success(null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == googleSignInRequestCode) {
            val callback = pendingGoogleResult
            pendingGoogleResult = null
            if (callback == null) return
            if (resultCode != Activity.RESULT_OK) {
                Log.w(tag, "Google sign-in canceled. resultCode=$resultCode")
                callback.success(
                    hashMapOf<String, Any?>(
                        "error" to "CANCELED"
                    )
                )
                return
            }
            if (data == null) {
                Log.w(tag, "Google sign-in returned null intent data")
                callback.success(
                    hashMapOf<String, Any?>(
                        "error" to "NO_DATA"
                    )
                )
                return
            }
            try {
                val task = GoogleSignIn.getSignedInAccountFromIntent(data)
                val account: GoogleSignInAccount = task.getResult(ApiException::class.java)
                val payload = hashMapOf<String, Any?>(
                    "email" to (account.email ?: ""),
                    "name" to (account.displayName ?: "")
                )
                Log.i(tag, "Google sign-in success for email=${account.email}")
                callback.success(payload)
            } catch (api: ApiException) {
                Log.e(tag, "Google sign-in ApiException status=${api.statusCode}", api)
                callback.success(
                    hashMapOf<String, Any?>(
                        "error" to "API_${api.statusCode}"
                    )
                )
            } catch (_: Exception) {
                Log.e(tag, "Google sign-in unknown exception")
                callback.success(
                    hashMapOf<String, Any?>(
                        "error" to "UNKNOWN"
                    )
                )
            }
            return
        }

        if (requestCode != pickImageRequestCode) return

        val callback = pendingPickImageResult
        pendingPickImageResult = null

        if (callback == null) return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            callback.success(null)
            return
        }

        try {
            val uri = data.data!!
            contentResolver.openInputStream(uri).use { stream ->
                if (stream == null) {
                    callback.success(null)
                    return
                }
                val bytes = stream.readBytes()
                val base64 = Base64.encodeToString(bytes, Base64.NO_WRAP)
                callback.success(base64)
            }
        } catch (_: Exception) {
            callback.success(null)
        }
    }
}
