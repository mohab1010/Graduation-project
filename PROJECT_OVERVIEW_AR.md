**نظرة عامة على المشروع**
- **نوع المشروع**: تطبيق Flutter متعدد المنصات (Android / iOS / Web / Windows / macOS / Linux).
- **الهدف**: منصة "Wesal" لربط الأهالي بالأطباء، إدارة ملفات الأطفال، الدردشة (بما فيها مساعد AI)، وحجز/إجراء مكالمات صوتية ومرئية.

**المجلدات والمكونات الرئيسية**
- **`android/`، `ios/`, `windows/`, `macos/`, `linux/`**: إعدادات وبناء منصات محددة.
- **`lib/`**: كود التطبيق الرئيسي (شاشات، منطق، خدمات، state management).
- **`assets/`**: صور وملفات Lottie.
- **`build/` و `app/`**: ملفات البناء المؤقتة.

**أين يتم التعامل مع الـ API و الشبكة (ملفات رئيسية مع وصف مختصر)**
- **Supabase (قاعدة البيانات، المصادقة، التخزين)**:
  - **ملف الخدمة العام**: [lib/logic/services/supabase_services.dart](lib/logic/services/supabase_services.dart) : يحتوي على دوال تسجيل الدخول/التسجيل، استعلامات، دوال حذف/ستريم للبيانات، وتحديث tokens.
  - **تهيئة Supabase**: [lib/main.dart](lib/main.dart) : استدعاء `Supabase.initialize(...)` مع الـ `url` و `anonKey`.
  - **استعمال Supabase في الواجهات**: ملفات العرض والدالات التي تتعامل مع Supabase مثل [lib/presentation/widgets/chat/messages_list_view.dart](lib/presentation/widgets/chat/messages_list_view.dart) وملفات إضافة الطفل/النصائح التي تستخدم `Supabase.instance.client`.

- **Firebase / FCM (الإشعارات)**:
  - **ملف إشعارات FCM**: [lib/logic/services/notifications/fcm_notification.dart](lib/logic/services/notifications/fcm_notification.dart) : يستخدم `firebase_messaging` و `Dio` لإرسال رسائل عبر REST API الخاصة بـ FCM (يحتوي على استدعاءات `Dio` و `.post`).
  - **إعدادات Firebase**: [lib/firebase_options.dart](lib/firebase_options.dart) : يحتوي على مفاتيح وتهيئة Firebase للمشروع.
  - **تهيئة Firebase Messaging و background handler**: [lib/main.dart](lib/main.dart) (تعيين `FirebaseMessaging.onBackgroundMessage` وتهيئة التنبيهات المحلية).

- **AI Chat (Google Generative / Gemini)**:
  - **Cubit للدردشة مع الـ AI**: [lib/logic/cubit/chat_with_ai/cubit/chat_with_ai_cubit.dart](lib/logic/cubit/chat_with_ai/cubit/chat_with_ai_cubit.dart) : يستخدم `GenerativeModel` من مكتبة Google ويأخذ `apiKey` من متغيرات التطبيق.
  - **مكان مفتاح الـ API**: [lib/logic/services/variables_app.dart](lib/logic/services/variables_app.dart) : يحتوي على `geminiApiKey` والمتغيرات العامة.

- **خدمات الاتصالات (Zego) للمكالمات الصوت/فيديو**:
  - **ملف خدمة Zego**: [lib/logic/services/zego_services/zego_services.dart](lib/logic/services/zego_services/zego_services.dart) : إدارة تسجيل الدخول والتهيئة لـ Zego.
  - **تهيئة واستعمال**: تهيئة Zego تتم في [lib/main.dart](lib/main.dart) قبل تشغيل التطبيق.

- **رفع واسترجاع ملفات الصور (Storage)**:
  - **نموذج رفع النصائح/صورها**: [lib/logic/services/add_tips_services/add_tips_services.dart](lib/logic/services/add_tips_services/add_tips_services.dart) : يستخدم `supabase.storage` لرفع الصور والحصول على `publicUrl`.
  - **رفع صورة ملف المستخدم**: [lib/logic/services/sign_up_services/save_profile_user_data.dart](lib/logic/services/sign_up_services/save_profile_user_data.dart) : تحميل الصور إلى دلائل التخزين في Supabase ثم حفظ رابط الصورة في جدول `profiles`.

- **خدمات أخرى مهمة**:
  - **الجلسات والجدولة**: [lib/logic/services/sessions_service/sessions_service.dart](lib/logic/services/sessions_service/sessions_service.dart) و [lib/logic/services/schedule_services/schedule_service.dart](lib/logic/services/schedule_services/schedule_service.dart) — قد تحتوي على استعلامات/تعديلات عبر Supabase.
  - **DI وتهيئة الخدمات**: [lib/logic/services/di/dependancy_injection.dart](lib/logic/services/di/dependancy_injection.dart) : تسجيل الخدمات (get_it) المستخدمة في التطبيق.

**نصائح سريعة لكيفية البحث عن مكالمات الشبكة أو APIs في المشروع**
- ابحث عن السلاسل أو الاستعمالات التالية في الملفات داخل `lib/`:
  - `Supabase.instance.client` — مكالمات DB/Auth/Storage
  - `FirebaseMessaging` أو استدعاءات `Dio` أو `.post(` — استدعاءات HTTP/FCM
  - `GenerativeModel` أو `geminiApiKey` — مكالمات AI
  - `zego` أو `Zego` — مكالمات / إشارة المكالمات

**خلاصة سريعة**
- السِبابة الأساسية للـ API في المشروع هي **Supabase** (قاعدة بيانات، auth، تخزين). تليها **Firebase (FCM)** للإشعارات، ثم **Google Generative AI** للاشتقاق اللغوي/الدردشة، و**Zego** للمكالمات.

إذا تريد، أقدر:
- أضيف روابط محددة بسطور تظهر مكان الاستدعاءات (line numbers). 
- أشرح كل ملف API بالتفصيل (دوال، مدخلات/مخرجات).
- أفتح وأعرض أي ملف بالتفصيل لتوضيح نقطة معينة.

