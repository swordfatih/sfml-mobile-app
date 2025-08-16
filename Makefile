CONFIG_JSON := config.json
APP_NAME    := sfml_app
APP_ID      := com.example.sfml_app
MOBILE_ICON := assets/icon.png

SDK_ROOT       ?= C:/Android
NDK_VERSION    ?= 26.1.10909125
BUILD_TOOLS    ?= $(SDK_ROOT)/build-tools/34.0.0
NDK_PATH       ?= $(SDK_ROOT)/ndk/$(NDK_VERSION)
TOOLCHAIN      := $(NDK_PATH)/build/cmake/android.toolchain.cmake
PLATFORM_TOOLS := $(SDK_ROOT)/platform-tools

KEYSTORE   ?= my-release-key.keystore
KEY_ALIAS  ?= my-key-alias
KEY_PASS   ?= password
STORE_PASS ?= password

ABIS := x86_64

all: apk

keystore:
	keytool -genkeypair -v -keystore $(KEYSTORE) -alias $(KEY_ALIAS) -keyalg RSA -keysize 2048 -validity 10000 -storepass $(STORE_PASS) -keypass $(KEY_PASS) -dname "CN=$(APP_NAME), OU=Dev, O=Example, L=City, S=State, C=US"

apk:
	for abi in $(ABIS); do \
	  cmake -Wno-deprecated -S . -B build-android-$$abi -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=$(TOOLCHAIN) -DANDROID_ABI=$$abi -DANDROID_PLATFORM=android-21 -DAPP_NAME=$(APP_NAME); \
	  cmake --build build-android-$$abi --config Release; \
	done

	rm -rf android-tmp unsigned-apk
	mkdir -p android-tmp/{res/values,assets}

	for abi in $(ABIS); do \
		mkdir -p android-tmp/lib/$$abi; \
		if [ -f build-android-$$abi/libsfml_app.so ]; then \
			cp build-android-$$abi/libsfml_app.so android-tmp/lib/$$abi/; \
		else \
			libpath=$$(find build-android-$$abi -maxdepth 3 -name libsfml_app.so | head -n1); \
			if [ -n "$$libpath" ]; then \
				cp "$$libpath" android-tmp/lib/$$abi/; \
			else \
				echo "ERROR: libsfml_app.so not found for ABI $$abi" >&2; exit 1; \
			fi; \
		fi; \
		find build-android-$$abi/_deps/sfml-build -type f -name '*.so' -exec cp {} android-tmp/lib/$$abi/ \; || true; \
	done

	cp -r assets android-tmp/assets/assets

	echo '<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="$(APP_ID)"><application android:label="$(APP_NAME)" android:hasCode="false" android:icon="@mipmap/ic_launcher" android:extractNativeLibs="true"><activity android:name="android.app.NativeActivity" android:label="$(APP_NAME)" android:configChanges="orientation|keyboardHidden" android:exported="true"><meta-data android:name="android.app.lib_name" android:value="sfml_app" /><intent-filter><action android:name="android.intent.action.MAIN" /><category android:name="android.intent.category.LAUNCHER" /></intent-filter></activity></application><uses-sdk android:minSdkVersion="21" android:targetSdkVersion="33" /></manifest>' > android-tmp/AndroidManifest.xml

	echo '<resources><string name="app_name">$(APP_NAME)</string></resources>' > android-tmp/res/values/strings.xml

	for density in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do \
	  dir="android-tmp/res/mipmap-$${density%%:*}"; \
	  size="$${density##*:}"; \
	  mkdir -p $$dir; \
	  magick "$(MOBILE_ICON)" -resize $${size}x$${size} "$$dir/ic_launcher.png"; \
	done

	mkdir -p unsigned-apk
	$(BUILD_TOOLS)/aapt package -F unsigned-apk/$(APP_NAME).apk -M android-tmp/AndroidManifest.xml -S android-tmp/res -A android-tmp/assets -I $(SDK_ROOT)/platforms/android-33/android.jar

	for abi in $(ABIS); do \
	  for sofile in android-tmp/lib/$$abi/*.so; do \
	    [ -f "$$sofile" ] && (cd android-tmp && "$(BUILD_TOOLS)/aapt" add ../unsigned-apk/$(APP_NAME).apk lib/$$abi/$$(basename $$sofile)); \
	  done; \
	done

	$(BUILD_TOOLS)/zipalign -p 4 unsigned-apk/$(APP_NAME).apk unsigned-apk/$(APP_NAME)-aligned.apk
	mv unsigned-apk/$(APP_NAME)-aligned.apk unsigned-apk/$(APP_NAME).apk

	$(BUILD_TOOLS)/apksigner sign --ks $(KEYSTORE) --ks-pass pass:$(STORE_PASS) --key-pass pass:$(KEY_PASS) --ks-key-alias $(KEY_ALIAS) unsigned-apk/$(APP_NAME).apk

	$(BUILD_TOOLS)/apksigner verify --verbose --print-certs unsigned-apk/$(APP_NAME).apk

run: apk
	$(PLATFORM_TOOLS)/adb install -r unsigned-apk/$(APP_NAME).apk
	$(PLATFORM_TOOLS)/adb shell monkey -p $(APP_ID) -c android.intent.category.LAUNCHER 1

verify-libs:
	unzip -l unsigned-apk/$(APP_NAME).apk | grep -E "lib/.*/libsfml_app\.so" || { echo "libsfml_app.so MISSING in APK" >&2; exit 1; }

clean:
	rm -rf build-android-* android-tmp unsigned-apk
