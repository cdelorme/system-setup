
### windows 8.1 jis input configuration

This configuration requires Windows 8.1, with Windows 8 you can accomplish something similar but may encounter a myriad of other issues if you remove the english input device from languages.

Open up `Control Panel > Languages` and add a language.  Select `Japanese`.  Click `options` next to the Japanese language, and select to `Install the language packs`.  This can take a couple of minutes.

Next use the button to `Move Up` the japanese language to the top, and then select the `US (English)` and click `Remove`.

Now, open the `Advanced Settings` option on the top left, and the first drop down select "English" as the default display language.

Finally, open `Control Panel > Region` and select `Administration` and change the system locale to `Japanese`.

This will prompt a system reboot.

Once the system has rebooted you will have an English UI, only the Japanese IME as your input device, with alphanumeric as the default (instead of hiragana), and the Japanese system locale.

I feel it necessary to point out that Windows 8.1 is the only OS I have used that has managed to distinguish and decouple the input device, display language, and locale so cleanly, and it is truly gratifying.

**Windows 8, the previous version, does not set the default IME to alphanumeric, which leads to many problems, including applications simply ignoring input until you install the US (English) language /w input device again.**

_If the login screen for whatever reason keeps the Japanese input method as the default, you may have to fiddle with adding the English (US) input again, resetting it from region advanced, then removing it again and setting japanese as the default one more time._

