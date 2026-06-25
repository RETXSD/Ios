import Foundation

enum AppTextKey {
    case homeTab
    case lessonsTab
    case scanTab
    case dictionaryTab
    case aiTab
    case profileTab
    case moreTab
    case moreTitle
    case languageTitle
    case languageSubtitle
    case languageIndonesia
    case languageChinese
    case languageEnglish
    case aiLanguageNote
    case homeTitle
    case welcomeBack
    case continueLevel
    case daySuffix
    case todayRoute
    case xpToNextLevel
    case openLesson
    case lessonsTitle
    case completeLabel
    case lockedLevel
    case lessonDetailExam
    case showAnswer
    case nextCard
    case examTitle
    case examUnavailable
    case passed
    case tryAgain
    case score
    case nextLevelUnlocked
    case chooseRomaji
    case readingQuestion
    case matchMeaningQuestion
    case fillBlankQuestion
    case flashcardQuestion
    case matchMeaningPrompt
    case flashcardRecallPrompt
    case scanTitle
    case scanMode
    case capture
    case scanning
    case openSettings
    case lowConfidence
    case scanModelMissing
    case scanCameraDenied
    case scanGenericError
    case dictionaryTitle
    case dictionarySearchPrompt
    case detailTitle
    case aiTitle
    case aiPlaceholder
    case send
    case aiGreeting
    case aiProxyError
    case aiEmptyError
    case yourMessage
    case tutorMessage
    case profileTitle
    case xpProgress
    case completion
    case onboardingHeadline
    case onboardingBody
    case n5Unlocked
    case structuredLessons
    case deviceAudio
    case onDeviceScan
    case startLearning
}

extension AppLanguage {
    func text(_ key: AppTextKey) -> String {
        switch self {
        case .indonesia:
            return IndonesianText.value(for: key)
        case .chineseSimplified:
            return ChineseSimplifiedText.value(for: key)
        case .english:
            return EnglishText.value(for: key)
        }
    }
}

private enum IndonesianText {
    static func value(for key: AppTextKey) -> String {
        switch key {
        case .homeTab: return "Home"
        case .lessonsTab: return "Lessons"
        case .scanTab: return "Scan"
        case .dictionaryTab: return "Kamus"
        case .aiTab: return "AI"
        case .profileTab: return "Profile"
        case .moreTab: return "More"
        case .moreTitle: return "More"
        case .languageTitle: return "Bahasa"
        case .languageSubtitle: return "Pilih bahasa untuk UI, notifikasi, dan jawaban AI."
        case .languageIndonesia: return "Indonesia"
        case .languageChinese: return "China Modern"
        case .languageEnglish: return "Inggris"
        case .aiLanguageNote: return "AI Tutor akan menjawab dengan bahasa yang dipilih."
        case .homeTitle: return "Beranda"
        case .welcomeBack: return "おかえり"
        case .continueLevel: return "Lanjutkan latihan JLPT"
        case .daySuffix: return "hari"
        case .todayRoute: return "Rute hari ini"
        case .xpToNextLevel: return "XP menuju level berikutnya"
        case .openLesson: return "Buka Lesson"
        case .lessonsTitle: return "Lessons"
        case .completeLabel: return "Selesai"
        case .lockedLevel: return "Selesaikan ujian level sebelumnya"
        case .lessonDetailExam: return "Mulai Exam"
        case .showAnswer: return "Lihat Jawaban"
        case .nextCard: return "Kartu Berikutnya"
        case .examTitle: return "Exam"
        case .examUnavailable: return "Exam belum tersedia"
        case .passed: return "Lulus!"
        case .tryAgain: return "Coba Lagi"
        case .score: return "Skor"
        case .nextLevelUnlocked: return "Level berikutnya terbuka"
        case .chooseRomaji: return "Pilih romaji yang benar"
        case .readingQuestion: return "Reading"
        case .matchMeaningQuestion: return "Cocokkan arti"
        case .fillBlankQuestion: return "Isi blank"
        case .flashcardQuestion: return "Flashcard"
        case .matchMeaningPrompt: return "Cocokkan arti untuk"
        case .flashcardRecallPrompt: return "Ingat flashcard ini, lalu pilih arti yang paling tepat."
        case .scanTitle: return "Scan"
        case .scanMode: return "Mode scan"
        case .capture: return "Capture"
        case .scanning: return "Memindai..."
        case .openSettings: return "Buka Settings"
        case .lowConfidence: return "Tulisan kurang jelas, coba lagi"
        case .scanModelMissing: return "Model JapaneseCharClassifier belum tersedia."
        case .scanCameraDenied: return "Izin kamera ditolak. Aktifkan izin kamera di Settings."
        case .scanGenericError: return "Pemindaian bermasalah. Coba lagi."
        case .dictionaryTitle: return "Kamus"
        case .dictionarySearchPrompt: return "Cari English, 日本語, romaji"
        case .detailTitle: return "Detail"
        case .aiTitle: return "AI Tutor"
        case .aiPlaceholder: return "Tanya tutor Jepang"
        case .send: return "Kirim"
        case .aiGreeting: return "Halo! Tanya aku tentang kana, kanji, atau contoh kalimat Jepang."
        case .aiProxyError: return "Koneksi AI bermasalah. Pastikan proxy server berjalan."
        case .aiEmptyError: return "AI belum memberi jawaban. Coba lagi."
        case .yourMessage: return "Pesan kamu"
        case .tutorMessage: return "Pesan tutor"
        case .profileTitle: return "Profil"
        case .xpProgress: return "Progress XP"
        case .completion: return "Completion"
        case .onboardingHeadline: return "Belajar aksara Jepang dengan kamera"
        case .onboardingBody: return "Mulai dari N5, latihan flashcard, lalu pindai tulisan tangan untuk cek karakter dan kalimat."
        case .n5Unlocked: return "N5 terbuka"
        case .structuredLessons: return "Latihan terstruktur"
        case .deviceAudio: return "Audio ja-JP di perangkat"
        case .onDeviceScan: return "Pemindaian kamera on-device"
        case .startLearning: return "Mulai Belajar"
        }
    }
}

private enum ChineseSimplifiedText {
    static func value(for key: AppTextKey) -> String {
        switch key {
        case .homeTab: return "首页"
        case .lessonsTab: return "课程"
        case .scanTab: return "扫描"
        case .dictionaryTab: return "词典"
        case .aiTab: return "AI"
        case .profileTab: return "个人"
        case .moreTab: return "更多"
        case .moreTitle: return "更多"
        case .languageTitle: return "语言"
        case .languageSubtitle: return "选择界面、提示和 AI 回答的语言。"
        case .languageIndonesia: return "印度尼西亚语"
        case .languageChinese: return "现代中文"
        case .languageEnglish: return "英语"
        case .aiLanguageNote: return "AI 导师会使用你选择的语言回答。"
        case .homeTitle: return "首页"
        case .welcomeBack: return "欢迎回来"
        case .continueLevel: return "继续 JLPT 练习"
        case .daySuffix: return "天"
        case .todayRoute: return "今日路线"
        case .xpToNextLevel: return "到下一级的 XP"
        case .openLesson: return "打开课程"
        case .lessonsTitle: return "课程"
        case .completeLabel: return "完成"
        case .lockedLevel: return "请先完成上一级考试"
        case .lessonDetailExam: return "开始考试"
        case .showAnswer: return "查看答案"
        case .nextCard: return "下一张卡"
        case .examTitle: return "考试"
        case .examUnavailable: return "考试暂不可用"
        case .passed: return "通过！"
        case .tryAgain: return "再试一次"
        case .score: return "分数"
        case .nextLevelUnlocked: return "下一级已解锁"
        case .chooseRomaji: return "选择正确的罗马字"
        case .readingQuestion: return "读音"
        case .matchMeaningQuestion: return "匹配意思"
        case .fillBlankQuestion: return "填空"
        case .flashcardQuestion: return "抽认卡"
        case .matchMeaningPrompt: return "选择这个词的意思"
        case .flashcardRecallPrompt: return "回忆这张抽认卡，然后选择最合适的意思。"
        case .scanTitle: return "扫描"
        case .scanMode: return "扫描模式"
        case .capture: return "拍摄"
        case .scanning: return "扫描中..."
        case .openSettings: return "打开设置"
        case .lowConfidence: return "字迹不清楚，请再试一次"
        case .scanModelMissing: return "JapaneseCharClassifier 模型尚未添加。"
        case .scanCameraDenied: return "相机权限被拒绝。请在设置中开启相机权限。"
        case .scanGenericError: return "扫描出现问题，请再试一次。"
        case .dictionaryTitle: return "词典"
        case .dictionarySearchPrompt: return "搜索英文、日本語、romaji"
        case .detailTitle: return "详情"
        case .aiTitle: return "AI 导师"
        case .aiPlaceholder: return "问日语导师"
        case .send: return "发送"
        case .aiGreeting: return "你好！可以问我假名、汉字或日语例句。"
        case .aiProxyError: return "AI 连接有问题。请确认代理服务器正在运行。"
        case .aiEmptyError: return "AI 还没有回复。请再试一次。"
        case .yourMessage: return "你的消息"
        case .tutorMessage: return "导师消息"
        case .profileTitle: return "个人资料"
        case .xpProgress: return "XP 进度"
        case .completion: return "完成度"
        case .onboardingHeadline: return "用相机学习日语文字"
        case .onboardingBody: return "从 N5 开始，用抽认卡练习，再扫描手写字符和句子。"
        case .n5Unlocked: return "N5 已解锁"
        case .structuredLessons: return "结构化课程"
        case .deviceAudio: return "设备端 ja-JP 发音"
        case .onDeviceScan: return "本机扫描识别"
        case .startLearning: return "开始学习"
        }
    }
}

private enum EnglishText {
    static func value(for key: AppTextKey) -> String {
        switch key {
        case .homeTab: return "Home"
        case .lessonsTab: return "Lessons"
        case .scanTab: return "Scan"
        case .dictionaryTab: return "Dictionary"
        case .aiTab: return "AI"
        case .profileTab: return "Profile"
        case .moreTab: return "More"
        case .moreTitle: return "More"
        case .languageTitle: return "Language"
        case .languageSubtitle: return "Choose the language for UI, alerts, and AI replies."
        case .languageIndonesia: return "Indonesian"
        case .languageChinese: return "Modern Chinese"
        case .languageEnglish: return "English"
        case .aiLanguageNote: return "AI Tutor will reply using the selected language."
        case .homeTitle: return "Home"
        case .welcomeBack: return "Welcome back"
        case .continueLevel: return "Continue JLPT practice"
        case .daySuffix: return "days"
        case .todayRoute: return "Today's route"
        case .xpToNextLevel: return "XP to next level"
        case .openLesson: return "Open Lesson"
        case .lessonsTitle: return "Lessons"
        case .completeLabel: return "Complete"
        case .lockedLevel: return "Finish the previous level exam"
        case .lessonDetailExam: return "Start Exam"
        case .showAnswer: return "Show Answer"
        case .nextCard: return "Next Card"
        case .examTitle: return "Exam"
        case .examUnavailable: return "Exam is not available yet"
        case .passed: return "Passed!"
        case .tryAgain: return "Try Again"
        case .score: return "Score"
        case .nextLevelUnlocked: return "Next level unlocked"
        case .chooseRomaji: return "Choose the correct romaji"
        case .readingQuestion: return "Reading"
        case .matchMeaningQuestion: return "Match meaning"
        case .fillBlankQuestion: return "Fill blank"
        case .flashcardQuestion: return "Flashcard"
        case .matchMeaningPrompt: return "Match the meaning for"
        case .flashcardRecallPrompt: return "Recall this flashcard, then choose the best meaning."
        case .scanTitle: return "Scan"
        case .scanMode: return "Scan mode"
        case .capture: return "Capture"
        case .scanning: return "Scanning..."
        case .openSettings: return "Open Settings"
        case .lowConfidence: return "Writing is unclear, try again"
        case .scanModelMissing: return "JapaneseCharClassifier model is not available yet."
        case .scanCameraDenied: return "Camera permission denied. Enable camera access in Settings."
        case .scanGenericError: return "Scan failed. Try again."
        case .dictionaryTitle: return "Dictionary"
        case .dictionarySearchPrompt: return "Search English, 日本語, romaji"
        case .detailTitle: return "Detail"
        case .aiTitle: return "AI Tutor"
        case .aiPlaceholder: return "Ask the Japanese tutor"
        case .send: return "Send"
        case .aiGreeting: return "Hi! Ask me about kana, kanji, or Japanese example sentences."
        case .aiProxyError: return "AI connection problem. Make sure the proxy server is running."
        case .aiEmptyError: return "AI did not reply yet. Try again."
        case .yourMessage: return "Your message"
        case .tutorMessage: return "Tutor message"
        case .profileTitle: return "Profile"
        case .xpProgress: return "XP Progress"
        case .completion: return "Completion"
        case .onboardingHeadline: return "Learn Japanese characters with the camera"
        case .onboardingBody: return "Start from N5, practice flashcards, then scan handwriting to check characters and sentences."
        case .n5Unlocked: return "N5 unlocked"
        case .structuredLessons: return "Structured lessons"
        case .deviceAudio: return "On-device ja-JP audio"
        case .onDeviceScan: return "On-device camera scanning"
        case .startLearning: return "Start Learning"
        }
    }
}
